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
import 'package:uuid/uuid.dart';
import '../utils/logger_util.dart';
import '../utils/image_compress.dart';
import '../backup/backup_service.dart';
import '../database/app_database.dart';
import '../database/daos/deal_dao.dart';
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

/// 增量变更条目（从远端 changelog 解析）
class SyncChangeEntry {
  final int revision;
  final String deviceId;
  final String entityType;
  final String entityId;
  final String operation;
  final DateTime changedAt;
  final Map<String, dynamic>? payload;

  SyncChangeEntry({
    required this.revision,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.changedAt,
    this.payload,
  });

  factory SyncChangeEntry.fromJson(Map<String, dynamic> json) {
    return SyncChangeEntry(
      revision: json['revision'] as int,
      deviceId: json['deviceId'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      operation: json['operation'] as String,
      changedAt: DateTime.parse(json['changedAt'] as String),
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }
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
  /// 增量拉取合并后的变更列表（仅 incrementalPull 返回）
  final List<SyncChangeEntry>? changes;

  const SyncResult.success({this.message, this.fileSize, this.dealCount, this.changeCount, this.changes}) : success = true;

  const SyncResult.failure(this.message)
      : success = false,
        fileSize = null,
        dealCount = null,
        changeCount = null,
        changes = null;
}

/// 云同步服务
///
/// 管理优惠数据的增量同步和全量同步。
/// 使用 [Lock] 保证同一时刻只有一个同步操作在执行。
class SyncService {
  final BackupService _backupService;
  final SyncDao _syncDao;
  final DealDao _dealDao;
  final Lock _lock = Lock();
  String? _cachedDeviceId;

  SyncService(this._backupService, this._syncDao, this._dealDao);

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

  /// 增量变更日志远端路径
  String _changelogPath(String deviceId, {String dirPrefix = 'zheduoduo'}) =>
      '$dirPrefix/changelog_$deviceId.jsonl';

  /// 全量备份远端目录
  String _fullDir({String dirPrefix = 'zheduoduo'}) => '$dirPrefix/full';

  /// 生成全量备份远端路径（含时间戳）
  String _fullBackupPath({String dirPrefix = 'zheduoduo'}) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${_fullDir(dirPrefix: dirPrefix)}/zheduoduo_$timestamp.zip';
  }

  /// 图片远端路径
  String _imagePath(String dealId, {String dirPrefix = 'zheduoduo'}) =>
      '$dirPrefix/images/$dealId.jpg';

  /// 增量推送：读取本地未同步的 changelog → 上传关联图片 → JSONL → 上传到 changelog_{deviceId}.jsonl
  Future<SyncResult> incrementalPush(SyncTransport transport, {void Function(SyncProgress)? onProgress, String dirPrefix = 'zheduoduo'}) async {
    return _lock.synchronized(() async {
      try {
        final deviceId = await getDeviceId();

        onProgress?.call(const SyncProgress(phase: 'collect', progress: 0.1, message: '收集本地变更...'));
        final pending = await _syncDao.getPendingChanges(deviceId);
        if (pending.isEmpty) {
          return const SyncResult.success(message: '无待同步变更', changeCount: 0);
        }

        // 1. 先上传关联图片（upsert 的 deal）
        final imageEntries = pending.where((e) => e.entityType == 'deal' && e.operation == 'upsert');
        if (imageEntries.isNotEmpty) {
          onProgress?.call(SyncProgress(phase: 'upload_images', progress: 0.2, message: '上传关联图片...'));
          final db = _syncDao.attachedDatabase;
          for (final entry in imageEntries) {
            final img = await (db.select(db.dealImages)
                  ..where((t) => t.dealId.equals(entry.entityId))
                  ..where((t) => t.deleted.equals(0)))
                .getSingleOrNull();
            if (img != null) {
              final resolved = await ImageUtils.resolveImagePath(img.imagePath);
              final file = File(resolved);
              if (file.existsSync()) {
                await transport.upload(
                  _imagePath(entry.entityId, dirPrefix: dirPrefix),
                  await file.readAsBytes(),
                );
              }
            }
          }
        }

        onProgress?.call(SyncProgress(phase: 'serialize', progress: 0.5, message: '序列化变更 (${pending.length} 条)...'));
        final db = _syncDao.attachedDatabase;
        final lines = <String>[];
        for (final e in pending) {
          final map = <String, dynamic>{
            'revision': e.revision,
            'deviceId': e.deviceId,
            'entityType': e.entityType,
            'entityId': e.entityId,
            'operation': e.operation,
            'changedAt': e.changedAt.toIso8601String(),
          };
          // upsert 的 deal 附加完整 payload，便于远端直接应用
          if (e.entityType == 'deal' && e.operation == 'upsert') {
            final deal = await (db.select(db.deals)..where((t) => t.id.equals(e.entityId))).getSingleOrNull();
            if (deal != null) {
              final tags = await (db.select(db.dealTags)..where((t) => t.dealId.equals(e.entityId))).get();
              final promos = await (db.select(db.dealPromotions)..where((t) => t.dealId.equals(e.entityId))).get();
              final coupons = await (db.select(db.coupons)..where((t) => t.dealId.equals(e.entityId))).get();
              final img = await (db.select(db.dealImages)..where((t) => t.dealId.equals(e.entityId))).getSingleOrNull();
              map['payload'] = {
                'deal': deal.toJson(),
                'tags': tags.map((t) => t.tag).toList(),
                'promotions': promos.map((p) => p.textContent).toList(),
                'coupons': coupons.map((c) => c.toJson()).toList(),
                'image': img?.toJson(),
              };
            }
          }
          lines.add(jsonEncode(map));
        }
        final jsonl = lines.join('\n') + '\n';
        final bytes = utf8.encode(jsonl);

        onProgress?.call(SyncProgress(phase: 'upload', progress: 0.8, message: '上传增量 (${_formatSize(bytes.length)})...'));
        await transport.upload(_changelogPath(deviceId, dirPrefix: dirPrefix), bytes.buffer.asUint8List());

        // 标记已同步并清理已同步记录
        for (final entry in pending) {
          await _syncDao.markSynced(entry.id);
        }
        await _syncDao.purgeSyncedChanges();
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
  Future<SyncResult> incrementalPull(SyncTransport transport, {void Function(SyncProgress)? onProgress, String dirPrefix = 'zheduoduo'}) async {
    return _lock.synchronized(() async {
      try {
        onProgress?.call(const SyncProgress(phase: 'list', progress: 0.1, message: '扫描远端 changelog...'));
        final files = await transport.list('$dirPrefix/changelog_');
        if (files.isEmpty) {
          return const SyncResult.success(message: '远端无增量变更', changeCount: 0);
        }

        // 去重合并：按 entityType+entityId 保留最新 revision
        final merged = <String, Map<String, dynamic>>{};
        int totalEntries = 0;

        for (final fname in files) {
          onProgress?.call(SyncProgress(phase: 'download', progress: 0.2 + 0.5 * (totalEntries / files.length), message: '下载 $fname...'));
          try {
            final data = await transport.download('$dirPrefix/$fname');
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

        final changes = merged.values.map((e) => SyncChangeEntry.fromJson(e)).toList();

        onProgress?.call(const SyncProgress(phase: 'done', progress: 1.0, message: '增量拉取完成'));
        return SyncResult.success(
          message: '增量拉取完成，${merged.length} 条待应用变更',
          changeCount: merged.length,
          changes: changes,
        );
      } catch (e) {
        return SyncResult.failure('增量拉取失败: $e');
      }
    });
  }

  /// 全量上传：export backup → upload to full/{timestamp}.zip
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
  Future<SyncResult> fullDownload(SyncTransport transport, {void Function(SyncProgress)? onProgress, String dirPrefix = 'zheduoduo', String? filename}) async {
    return _lock.synchronized(() async {
      try {
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

  /// 应用拉取到的增量变更到本地数据库
  Future<void> _applyChanges(
    List<SyncChangeEntry> changes,
    SyncTransport transport, {
    String dirPrefix = 'zheduoduo',
  }) async {
    final imgDir = await ImageUtils.getImagesDirectory();
    for (final change in changes) {
      try {
        if (change.entityType == 'deal') {
          switch (change.operation) {
            case 'upsert':
              final payload = change.payload;
              if (payload == null) continue;
              final deal = Deal.fromJson(payload['deal'] as Map<String, dynamic>);
              final tags = (payload['tags'] as List<dynamic>?)?.cast<String>() ?? [];
              final promotions = (payload['promotions'] as List<dynamic>?)?.cast<String>() ?? [];
              final coupons = (payload['coupons'] as List<dynamic>?)
                      ?.map((c) => Coupon.fromJson(c as Map<String, dynamic>))
                      .toList() ??
                  [];
              final imageJson = payload['image'] as Map<String, dynamic>?;
              DealImage? image;
              if (imageJson != null) {
                // 从远端下载图片到本地
                try {
                  final remoteImgPath = _imagePath(deal.id, dirPrefix: dirPrefix);
                  final imgData = await transport.download(remoteImgPath);
                  final absPath = p.join(imgDir.path, '${deal.id}.jpg');
                  await File(absPath).writeAsBytes(imgData);
                  image = DealImage.fromJson(imageJson).copyWith(imagePath: '${deal.id}.jpg');
                } catch (e) {
                  AppLogger.instance.e('[Sync] 下载图片失败: ${deal.id}', e);
                  // 图片下载失败仍继续保存 deal，只是没有图片
                }
              }
              await _dealDao.saveDeal(DealWithDetails(
                deal: deal,
                tags: tags,
                promotions: promotions,
                coupons: coupons,
                image: image,
              ));
            case 'pending_delete':
              await _dealDao.softDeleteDeal(change.entityId);
            case 'delete':
              await _dealDao.hardDeleteDeal(change.entityId);
            default:
              break;
          }
        }
      } catch (e) {
        AppLogger.instance.e('[Sync] 应用变更失败: ${change.entityId} ${change.operation}', e);
      }
    }
  }

  /// 智能同步（立即同步）：增量拉取 → 应用变更 → 增量推送
  Future<SyncResult> smartSync(SyncTransport transport, {void Function(SyncProgress)? onProgress, String dirPrefix = 'zheduoduo'}) async {
    // 1. 增量拉取远端变更
    onProgress?.call(const SyncProgress(phase: 'pull', progress: 0.0, message: '开始同步...'));
    final pullResult = await incrementalPull(transport, onProgress: onProgress, dirPrefix: dirPrefix);

    // pull 失败不一定终止（可能是远端无变更）
    if (!pullResult.success && pullResult.message != null && !pullResult.message!.contains('无增量变更')) {
      return pullResult;
    }

    // 2. 应用拉取到的变更
    if (pullResult.changes != null && pullResult.changes!.isNotEmpty) {
      onProgress?.call(SyncProgress(phase: 'apply', progress: 0.4, message: '应用 ${pullResult.changes!.length} 条变更...'));
      await _applyChanges(pullResult.changes!, transport, dirPrefix: dirPrefix);
    }

    // 3. 增量推送本地变更
    return incrementalPush(transport, onProgress: onProgress, dirPrefix: dirPrefix);
  }

  /// 格式化文件大小（B / KB / MB）
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
