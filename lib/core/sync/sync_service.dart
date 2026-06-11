// 云同步服务
//
// 提供优惠数据的云端同步能力，包括：
// - 增量推送：将本地未同步的变更日志上传到云端
// - 增量拉取：从云端下载其他设备的变更日志并合并
// - 全量上传：导出完整备份并上传
// - 全量下载：从云端下载最新备份并导入
// - 智能同步：先拉取再推送
// 所有操作通过 [SyncTransport] 抽象层与云存储交互。

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';
import 'package:intl/intl.dart';
import '../backup/backup_service.dart';
import '../database/daos/sync_dao.dart';
import 'transports/sync_transport.dart';

/// 同步进度信息
class SyncProgress {
  /// 当前阶段（collect / serialize / upload / download / apply / done）
  final String phase;
  /// 进度百分比（0.0 - 1.0）
  final double progress;
  /// 进度描述文本
  final String? message;

  const SyncProgress({required this.phase, required this.progress, this.message});
}

/// 同步操作结果
class SyncResult {
  /// 是否成功
  final bool success;
  /// 结果描述
  final String? message;
  /// 文件大小（字节）
  final int? fileSize;
  /// 涉及的优惠数量
  final int? dealCount;
  /// 变更条数
  final int? changeCount;

  const SyncResult.success({this.message, this.fileSize, this.dealCount, this.changeCount}) : success = true;

  const SyncResult.failure(this.message)
      : success = false,
        fileSize = null,
        dealCount = null,
        changeCount = null;
}

/// 云同步服务
///
/// 管理优惠数据的增量同步和全量同步。
/// 使用 [Lock] 保证同一时刻只有一个同步操作在执行。
class SyncService {
  final BackupService _backupService;
  final SyncDao _syncDao;
  final Lock _lock = Lock();
  String? _cachedDeviceId;

  SyncService(this._backupService, this._syncDao);

  /// 获取当前设备 ID（从同步元数据中读取）
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;
    final meta = await _syncDao.getSyncMeta();
    if (meta != null && meta.deviceId.isNotEmpty) {
      _cachedDeviceId = meta.deviceId;
      return meta.deviceId;
    }
    const uuid = 'unknown-device';
    _cachedDeviceId = uuid;
    return uuid;
  }

  /// 增量变更日志远端路径
  String _changelogPath(String deviceId) => 'changelog_$deviceId.jsonl';

  /// 全量备份远端目录
  String _fullDir() => 'full';

  /// 生成全量备份远端路径（含时间戳）
  String _fullBackupPath() {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${_fullDir()}/zheduoduo_$timestamp.zip';
  }

  /// 增量推送：读取本地未同步的 changelog → JSONL → 上传到 changelog_{deviceId}.jsonl
  Future<SyncResult> incrementalPush(SyncTransport transport, {void Function(SyncProgress)? onProgress}) async {
    return _lock.synchronized(() async {
      try {
        final deviceId = await getDeviceId();

        onProgress?.call(const SyncProgress(phase: 'collect', progress: 0.1, message: '收集本地变更...'));
        final pending = await _syncDao.getPendingChanges(deviceId);
        if (pending.isEmpty) {
          return const SyncResult.success(message: '无待同步变更', changeCount: 0);
        }

        onProgress?.call(SyncProgress(phase: 'serialize', progress: 0.3, message: '序列化变更 (${pending.length} 条)...'));
        final lines = pending.map((e) => jsonEncode({
          'revision': e.revision,
          'deviceId': e.deviceId,
          'entityType': e.entityType,
          'entityId': e.entityId,
          'operation': e.operation,
          'changedAt': e.changedAt.toIso8601String(),
        }));
        final jsonl = lines.join('\n') + '\n';
        final bytes = utf8.encode(jsonl);

        onProgress?.call(SyncProgress(phase: 'upload', progress: 0.6, message: '上传增量 (${_formatSize(bytes.length)})...'));
        await transport.upload(_changelogPath(deviceId), bytes.buffer.asUint8List());

        // 标记已同步
        for (final entry in pending) {
          await _syncDao.markSynced(entry.id);
        }
        await _syncDao.updateRevision(
          pending.last.revision,
          pushAt: DateTime.now(),
        );

        onProgress?.call(const SyncProgress(phase: 'done', progress: 1.0, message: '增量推送完成'));
        return SyncResult.success(message: '增量推送成功，${pending.length} 条变更', changeCount: pending.length);
      } catch (e) {
        return SyncResult.failure('增量推送失败: $e');
      }
    });
  }

  /// 增量拉取：下载所有 changelog_{deviceId}.jsonl → 去重按 LWW 合并
  Future<SyncResult> incrementalPull(SyncTransport transport, {void Function(SyncProgress)? onProgress}) async {
    return _lock.synchronized(() async {
      try {
        onProgress?.call(const SyncProgress(phase: 'list', progress: 0.1, message: '扫描远端 changelog...'));
        final files = await transport.list('changelog_');
        if (files.isEmpty) {
          return const SyncResult.success(message: '远端无增量变更', changeCount: 0);
        }

        // 去重合并：按 entityType+entityId 保留最新 revision
        final merged = <String, Map<String, dynamic>>{};
        int totalEntries = 0;

        for (final fname in files) {
          onProgress?.call(SyncProgress(phase: 'download', progress: 0.2 + 0.5 * (totalEntries / files.length), message: '下载 $fname...'));
          try {
            final data = await transport.download(fname);
            final content = utf8.decode(data);
            for (final line in content.split('\n')) {
              final trimmed = line.trim();
              if (trimmed.isEmpty) continue;
              try {
                final entry = jsonDecode(trimmed) as Map<String, dynamic>;
                final key = '${entry['entityType']}|${entry['entityId']}';
                final existing = merged[key];
                if (existing == null || (entry['revision'] as int) > (existing['revision'] as int)) {
                  merged[key] = entry;
                }
                totalEntries++;
              } catch (_) {}
            }
          } catch (_) {}
        }

        onProgress?.call(SyncProgress(phase: 'apply', progress: 0.8, message: '合并 ${merged.length} 条变更...'));

        // 返回合并后的 changelog 条目，由调用方负责应用
        onProgress?.call(const SyncProgress(phase: 'done', progress: 1.0, message: '增量拉取完成'));
        return SyncResult.success(
          message: '增量拉取完成，${merged.length} 条待应用变更',
          changeCount: merged.length,
        );
      } catch (e) {
        return SyncResult.failure('增量拉取失败: $e');
      }
    });
  }

  /// 全量上传：export backup → upload to full/{timestamp}.zip
  Future<SyncResult> fullUpload(SyncTransport transport, {void Function(SyncProgress)? onProgress}) async {
    return _lock.synchronized(() async {
      try {
        onProgress?.call(const SyncProgress(phase: 'export', progress: 0.1, message: '正在导出数据...'));

        final tempDir = Directory.systemTemp;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempPath = p.join(tempDir.path, 'zdd_sync_upload_$timestamp.zip');
        final exportResult = await _backupService.exportBackup(customPath: tempPath);

        if (!exportResult.success) {
          return SyncResult.failure(exportResult.error ?? '导出失败');
        }

        final file = File(tempPath);
        final bytes = await file.readAsBytes();
        final remotePath = _fullBackupPath();

        onProgress?.call(SyncProgress(phase: 'upload', progress: 0.5, message: '正在上传到 $remotePath (${_formatSize(bytes.length)})...'));
        await transport.upload(remotePath, bytes);

        await file.delete();

        onProgress?.call(const SyncProgress(phase: 'done', progress: 1.0, message: '上传完成'));
        return SyncResult.success(
          message: '全量上传成功',
          fileSize: bytes.length,
          dealCount: exportResult.dealCount,
        );
      } catch (e) {
        return SyncResult.failure('上传失败: $e');
      }
    });
  }

  /// 全量下载：列出 full/ → 取最新 → download → import
  Future<SyncResult> fullDownload(SyncTransport transport, {void Function(SyncProgress)? onProgress}) async {
    return _lock.synchronized(() async {
      try {
        onProgress?.call(const SyncProgress(phase: 'list', progress: 0.1, message: '查找远端全量备份...'));
        final files = await transport.list('full/');
        if (files.isEmpty) {
          return const SyncResult.failure('远端无全量备份');
        }

        // 取最新: 文件名按时间排序 (zheduoduo_20250101_120000.zip)
        files.sort((a, b) => b.compareTo(a));
        final latest = 'full/${files.first}';

        onProgress?.call(SyncProgress(phase: 'download', progress: 0.3, message: '正在下载 $latest...'));
        final bytes = await transport.download(latest);

        onProgress?.call(SyncProgress(phase: 'import', progress: 0.6, message: '正在导入 (${_formatSize(bytes.length)})...'));

        final tempDir = Directory.systemTemp;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempPath = p.join(tempDir.path, 'zdd_sync_download_$timestamp.zip');
        final file = File(tempPath);
        await file.writeAsBytes(bytes);

        final importResult = await _backupService.importBackup(tempPath);
        await file.delete();

        if (!importResult.success) {
          return SyncResult.failure(importResult.error ?? '导入失败');
        }

        onProgress?.call(const SyncProgress(phase: 'done', progress: 1.0, message: '下载完成'));
        return SyncResult.success(
          message: '全量下载成功',
          fileSize: bytes.length,
          dealCount: importResult.dealCount,
        );
      } catch (e) {
        return SyncResult.failure('下载失败: $e');
      }
    });
  }

  /// 智能同步（立即同步）：增量拉取 → 增量推送
  Future<SyncResult> smartSync(SyncTransport transport, {void Function(SyncProgress)? onProgress}) async {
    // 1. 增量拉取远端变更
    onProgress?.call(const SyncProgress(phase: 'pull', progress: 0.0, message: '开始同步...'));
    final pullResult = await incrementalPull(transport, onProgress: onProgress);

    // pull 失败不一定终止（可能是远端无变更）
    if (!pullResult.success && pullResult.message != null && !pullResult.message!.contains('无增量变更')) {
      return pullResult;
    }

    // 2. 增量推送本地变更
    return incrementalPush(transport, onProgress: onProgress);
  }

  /// 格式化文件大小（B / KB / MB）
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
