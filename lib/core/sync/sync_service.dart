// 云同步服务
//
// 提供优惠数据的云端同步能力，包括：
// - 增量推送：将本地未同步的变更日志上传到云端
// - 增量拉取：从云端下载其他设备的变更日志并合并
// - 全量上传：导出完整备份并上传
// - 全量下载：从云端下载最新备份并导入
// - 智能同步：先拉取再推送
// 所有操作通过 [SyncTransport] 抽象层与云存储交互。

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../utils/logger_util.dart';
import '../backup/backup_service.dart';
import '../database/app_database.dart';
import '../database/daos/deal_dao.dart';
import '../database/daos/sync_dao.dart';
import 'transports/sync_transport.dart';
import 'incremental_sync_service.dart';
import 'models/sync_result.dart' as incremental;

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
  final DealDao _dealDao;
  final IncrementalSyncService _incremental;
  final Lock _lock = Lock();
  String? _cachedDeviceId;

  SyncService(this._backupService, this._syncDao, this._dealDao, this._incremental);

  /// 获取当前设备 ID（从同步元数据中读取，不存在则生成 UUID 并保存）
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;
    final meta = await _syncDao.getSyncMeta();
    if (meta != null && meta.deviceId.isNotEmpty && meta.deviceId != 'unknown-device') {
      _cachedDeviceId = meta.deviceId;
      return meta.deviceId;
    }
    // 生成真正的设备 UUID
    final uuid = const Uuid().v4();
    _cachedDeviceId = uuid;
    if (meta == null) {
      await _syncDao.upsertSyncMeta(SyncMetaData(
        id: 1,
        deviceId: uuid,
        localRevision: 0,
        remoteRevision: 0,
      ));
    } else {
      await _syncDao.upsertSyncMeta(meta.copyWith(deviceId: uuid));
    }
    return uuid;
  }

  /// 全量备份远端目录
  String _fullDir({String dirPrefix = 'zheduoduo'}) => '$dirPrefix/full';

  /// 生成全量备份远端路径（含时间戳）
  String _fullBackupPath({String dirPrefix = 'zheduoduo'}) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${_fullDir(dirPrefix: dirPrefix)}/zheduoduo_$timestamp.zip';
  }

  /// 增量推送（委托给 IncrementalSyncService）
  Future<SyncResult> incrementalPush(SyncTransport transport, {void Function(SyncProgress)? onProgress, String dirPrefix = 'zheduoduo'}) async {
    return _lock.synchronized(() async {
      try {
        final result = await _incremental.push(
          transport,
          onProgress: (phase, progress, message) {
            onProgress?.call(SyncProgress(phase: phase, progress: progress, message: message));
          },
          dirPrefix: dirPrefix,
        );
        if (result.isSuccess) {
          return SyncResult.success(message: result.message, changeCount: result.changeCount);
        } else if (result.isConflict) {
          return SyncResult.failure(result.message ?? '版本冲突');
        } else if (result.isNoChanges) {
          return SyncResult.success(message: result.message, changeCount: 0);
        } else {
          return SyncResult.failure(result.message ?? '增量推送失败');
        }
      } catch (e) {
        return SyncResult.failure('增量推送失败: $e');
      }
    });
  }

  /// 增量拉取（委托给 IncrementalSyncService）
  Future<SyncResult> incrementalPull(SyncTransport transport, {void Function(SyncProgress)? onProgress, String dirPrefix = 'zheduoduo'}) async {
    return _lock.synchronized(() async {
      try {
        final result = await _incremental.pull(
          transport,
          onProgress: (phase, progress, message) {
            onProgress?.call(SyncProgress(phase: phase, progress: progress, message: message));
          },
          dirPrefix: dirPrefix,
        );
        if (result.isSuccess) {
          return SyncResult.success(message: result.message, changeCount: result.changeCount);
        } else if (result.isNoChanges) {
          return SyncResult.success(message: result.message, changeCount: 0);
        } else {
          return SyncResult.failure(result.message ?? '增量拉取失败');
        }
      } catch (e) {
        return SyncResult.failure('增量拉取失败: $e');
      }
    });
  }

  /// 全量上传：export backup → upload to full/{timestamp}.zip → 清空本地 changelog
  Future<SyncResult> fullUpload(SyncTransport transport, {void Function(SyncProgress)? onProgress, String dirPrefix = 'zheduoduo'}) async {
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
        final remotePath = _fullBackupPath(dirPrefix: dirPrefix);

        onProgress?.call(SyncProgress(phase: 'upload', progress: 0.5, message: '正在上传到 $remotePath (${_formatSize(bytes.length)})...'));
        await transport.upload(remotePath, bytes);

        await file.delete();

        // 清理远端未被引用的图片
        onProgress?.call(const SyncProgress(phase: 'cleanup', progress: 0.9, message: '清理远端废弃图片...'));
        await _cleanupOrphanRemoteImages(transport, dirPrefix: dirPrefix);

        // 全量上传成功后清空本地 changelog（表示其他设备以本次全量备份为基线）
        await _syncDao.purgeAllChanges();

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

  /// 清理远端 images/ 目录下不再被本地 deal 引用的图片
  Future<void> _cleanupOrphanRemoteImages(SyncTransport transport, {String dirPrefix = 'zheduoduo'}) async {
    try {
      final activeDealIds = await _dealDao.getAllImageDealIds();
      final imageFiles = await transport.list('$dirPrefix/images/');
      for (final fname in imageFiles) {
        final dealId = fname.replaceAll('.jpg', '');
        if (!activeDealIds.contains(dealId)) {
          await transport.delete('$dirPrefix/images/$fname');
          AppLogger.instance.i('[Sync] 清理远端废弃图片: $fname');
        }
      }
    } catch (e) {
      AppLogger.instance.e('[Sync] 清理远端图片失败', e);
    }
  }

  /// 列出远端全量备份
  Future<List<RemoteFileInfo>> listFullBackups(SyncTransport transport, {String dirPrefix = 'zheduoduo'}) async {
    final files = await transport.listDetails('${_fullDir(dirPrefix: dirPrefix)}/');
    files.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return files;
  }

  /// 删除远端指定全量备份
  Future<SyncResult> deleteFullBackup(SyncTransport transport, String filename, {String dirPrefix = 'zheduoduo'}) async {
    return _lock.synchronized(() async {
      try {
        final remotePath = '${_fullDir(dirPrefix: dirPrefix)}/$filename';
        await transport.delete(remotePath);
        return SyncResult.success(message: '删除成功: $filename');
      } catch (e) {
        return SyncResult.failure('删除失败: $e');
      }
    });
  }

  /// 全量下载：列出 full/ → 取最新 → download → import
  /// 如果指定了 [filename]，则直接下载该文件，否则取最新的一份。
  /// [force] 为 true 时跳过本地 changelog 检查，直接覆盖。
  Future<SyncResult> fullDownload(
    SyncTransport transport, {
    void Function(SyncProgress)? onProgress,
    String dirPrefix = 'zheduoduo',
    String? filename,
    bool force = false,
  }) async {
    return _lock.synchronized(() async {
      try {
        // 检查本地是否有未同步的 changelog
        if (!force) {
          final deviceId = await getDeviceId();
          final pending = await _syncDao.getPendingChanges(deviceId);
          if (pending.isNotEmpty) {
            return const SyncResult.failure('本地存在未同步的变更，请先推送或确认覆盖');
          }
        }

        final String targetFile;
        if (filename != null && filename.isNotEmpty) {
          targetFile = '${_fullDir(dirPrefix: dirPrefix)}/$filename';
        } else {
          onProgress?.call(const SyncProgress(phase: 'list', progress: 0.1, message: '查找远端全量备份...'));
          final files = await transport.list('${_fullDir(dirPrefix: dirPrefix)}/');
          if (files.isEmpty) {
            return const SyncResult.failure('远端无全量备份');
          }

          // 取最新: 文件名按时间排序 (zheduoduo_20250101_120000.zip)
          files.sort((a, b) => b.compareTo(a));
          targetFile = '${_fullDir(dirPrefix: dirPrefix)}/${files.first}';
        }

        onProgress?.call(SyncProgress(phase: 'download', progress: 0.3, message: '正在下载 $targetFile...'));
        final bytes = await transport.download(targetFile);

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

        // 全量下载成功后清空本地 changelog（与远端基线对齐）
        await _syncDao.purgeAllChanges();

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
  Future<SyncResult> smartSync(SyncTransport transport, {void Function(SyncProgress)? onProgress, String dirPrefix = 'zheduoduo'}) async {
    // 1. 增量拉取远端变更（已包含应用变更）
    onProgress?.call(const SyncProgress(phase: 'pull', progress: 0.0, message: '开始同步...'));
    final pullResult = await incrementalPull(transport, onProgress: onProgress, dirPrefix: dirPrefix);

    // pull 失败不一定终止（可能是远端无变更）
    if (!pullResult.success && pullResult.message != null && !pullResult.message!.contains('无增量变更')) {
      return pullResult;
    }

    // 2. 增量推送本地变更
    return incrementalPush(transport, onProgress: onProgress, dirPrefix: dirPrefix);
  }

  /// 格式化文件大小（B / KB / MB）
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
