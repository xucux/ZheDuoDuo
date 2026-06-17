// 增量同步服务
//
// 核心逻辑：
// 1. 组装增量包：读取本地 changelog → JSONL + 附件 → ZIP
// 2. 推送：上传到远端 changelog 目录 → 更新 synclocal.json / synccloud.json
// 3. 拉取：从远端 changelog 目录下载其他设备的 ZIP → 解压 → 应用变更

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import '../database/app_database.dart';
import '../database/daos/sync_dao.dart';
import '../database/daos/deal_dao.dart';
import '../utils/image_compress.dart';
import '../utils/logger_util.dart';
import 'models/sync_result.dart';
import 'models/sync_state.dart';
import 'sync_state_manager.dart';
import 'transports/sync_transport.dart';

class IncrementalSyncService {
  final AppDatabase _db;
  final SyncDao _syncDao;
  final DealDao _dealDao;
  final SyncStateManager _stateManager;
  String? _cachedDeviceId;

  IncrementalSyncService(
    this._db,
    this._syncDao,
    this._dealDao,
    this._stateManager,
  );

  Future<String> _getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;
    final meta = await _syncDao.getSyncMeta();
    if (meta != null && meta.deviceId.isNotEmpty && meta.deviceId != 'unknown-device') {
      _cachedDeviceId = meta.deviceId;
      return meta.deviceId;
    }
    final id = _generateShortDeviceId();
    _cachedDeviceId = id;
    if (meta == null) {
      await _syncDao.upsertSyncMeta(SyncMetaData(
        id: 1,
        deviceId: id,
        localRevision: 0,
        remoteRevision: 0,
      ));
    } else {
      await _syncDao.upsertSyncMeta(meta.copyWith(deviceId: id));
    }
    return id;
  }

  static String _generateShortDeviceId() {
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  }

  String _changelogDir({String dirPrefix = 'zheduoduo'}) => '$dirPrefix/changelog';

  /// 组装增量包：读取未同步 changelog → 生成 JSONL + 收集附件 → ZIP
  Future<_IncrementalPackage?> _buildPackage(String deviceId) async {
    final pending = await _syncDao.getPendingChanges(deviceId);
    if (pending.isEmpty) return null;

    final lines = <String>[];
    final attachmentSet = <String>{};

    for (final e in pending) {
      final map = <String, dynamic>{
        'revision': e.revision,
        'deviceId': e.deviceId,
        'entityType': e.entityType,
        'entityId': e.entityId,
        'operation': e.operation,
        'changedAt': e.changedAt.toIso8601String(),
        'hasAttachment': e.hasAttachment,
      };

      // upsert 的 deal 附加完整 payload
      if (e.entityType == 'deals' && e.operation == 'upsert') {
        final deal = await (_db.select(_db.deals)..where((t) => t.id.equals(e.entityId))).getSingleOrNull();
        if (deal != null) {
          final tags = await (_db.select(_db.dealTags)..where((t) => t.dealId.equals(e.entityId))).get();
          final promos = await (_db.select(_db.dealPromotions)..where((t) => t.dealId.equals(e.entityId))).get();
          final coupons = await (_db.select(_db.coupons)..where((t) => t.dealId.equals(e.entityId))).get();
          final img = await (_db.select(_db.dealImages)..where((t) => t.dealId.equals(e.entityId))).getSingleOrNull();
          map['payload'] = {
            'deal': deal.toJson(),
            'tags': tags.map((t) => t.tag).toList(),
            'promotions': promos.map((p) => p.textContent).toList(),
            'coupons': coupons.map((c) => c.toJson()).toList(),
            'image': img?.toJson(),
          };
        }
      } else if (e.payload != null) {
        try {
          map['payload'] = jsonDecode(e.payload!);
        } catch (_) {}
      }

      // 收集附件路径
      if (e.hasAttachment == 1 && e.attachmentPaths != null) {
        try {
          final paths = jsonDecode(e.attachmentPaths!) as List<dynamic>;
          for (final path in paths.cast<String>()) {
            final resolved = await ImageUtils.resolveImagePath(path);
            if (File(resolved).existsSync()) {
              attachmentSet.add(resolved);
            }
          }
        } catch (_) {}
      }

      lines.add(jsonEncode(map));
    }

    final jsonl = lines.join('\n') + '\n';
    final archive = Archive();
    final jsonlBytes = utf8.encode(jsonl);
    archive.addFile(ArchiveFile('changelog.jsonl', jsonlBytes.length, jsonlBytes));

    for (final path in attachmentSet) {
      final file = File(path);
      if (file.existsSync()) {
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile(p.basename(path), bytes.length, bytes));
      }
    }

    final zipBytes = ZipEncoder().encode(archive);
    return _IncrementalPackage(
      zipData: Uint8List.fromList(zipBytes ?? []),
      changeIds: pending.map((e) => e.id).toList(),
      changeCount: pending.length,
    );
  }

  /// 增量推送
  Future<SyncResult> push(
    SyncTransport transport, {
    void Function(String phase, double progress, String? message)? onProgress,
    String dirPrefix = 'zheduoduo',
    int maxRetries = 3,
  }) async {
    onProgress?.call('build', 0.1, '组装增量包...');

    final deviceId = await _getDeviceId();
    final pkg = await _buildPackage(deviceId);
    if (pkg == null) {
      return const SyncResult.noChanges(message: '无待同步变更');
    }

    _stateManager.setTransport(transport);

    // 读取本地状态
    var localState = await _stateManager.readLocalState(deviceId);
    localState = await _stateManager.ensureDeviceLog(localState, deviceId);

    final zipName = 'changelog_${deviceId}_${DateTime.now().millisecondsSinceEpoch}.zip';
    final remoteZipPath = '${_changelogDir(dirPrefix: dirPrefix)}/$zipName';

    onProgress?.call('upload', 0.4, '上传增量包 (${pkg.changeCount} 条变更)...');
    await transport.upload(remoteZipPath, pkg.zipData);

    // 乐观锁更新 synccloud.json
    onProgress?.call('commit', 0.7, '更新同步状态...');
    var success = false;
    for (var i = 0; i < maxRetries; i++) {
      final remoteState = await _stateManager.readRemoteState();
      final baseState = remoteState ?? localState;

      final newState = _stateManager.bumpVersion(baseState, deviceId, zipName);

      if (await _stateManager.writeRemoteState(newState, expected: remoteState)) {
        await _stateManager.writeLocalState(newState);
        success = true;
        break;
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (!success) {
      // 回滚：删除已上传的 ZIP
      try {
        await transport.delete(remoteZipPath);
      } catch (_) {}
      return const SyncResult.conflict(message: '同步状态版本冲突，请稍后重试');
    }

    // 标记已同步并清理
    await _syncDao.markSyncedBatch(pkg.changeIds);
    await _syncDao.purgeSyncedChanges();
    await _syncDao.updateRevision(
      await _syncDao.nextRevision(),
      pushAt: DateTime.now(),
    );

    onProgress?.call('done', 1.0, '增量推送完成');
    return SyncResult.success(
      message: '增量推送成功，${pkg.changeCount} 条变更',
      changeCount: pkg.changeCount,
    );
  }

  /// 增量拉取：下载其他设备的 changelog ZIP → 解压 → 应用变更
  Future<SyncResult> pull(
    SyncTransport transport, {
    void Function(String phase, double progress, String? message)? onProgress,
    String dirPrefix = 'zheduoduo',
  }) async {
    onProgress?.call('list', 0.1, '扫描远端增量包...');

    final deviceId = await _getDeviceId();
    _stateManager.setTransport(transport);

    final localState = await _stateManager.readLocalState(deviceId);
    final remoteState = await _stateManager.readRemoteState();

    if (remoteState == null) {
      return const SyncResult.noChanges(message: '远端无同步状态');
    }

    // 计算需要拉取的 ZIP 列表
    final remoteZips = remoteState.changelogZip;
    final localZips = localState.changelogZip.toSet();
    final toPull = remoteZips.where((z) => !localZips.contains(z)).toList();

    if (toPull.isEmpty) {
      // 本地状态已是最新，写入本地
      await _stateManager.writeLocalState(remoteState);
      return const SyncResult.noChanges(message: '无新增量变更');
    }

    final allChanges = <Map<String, dynamic>>[];
    final imgDir = await ImageUtils.getImagesDirectory();

    for (var i = 0; i < toPull.length; i++) {
      final zipName = toPull[i];
      onProgress?.call('download', 0.2 + 0.5 * (i / toPull.length), '下载 $zipName...');

      try {
        final data = await transport.download('${dirPrefix}/changelog/$zipName');
        final archive = ZipDecoder().decodeBytes(data);

        // 读取 JSONL
        final jsonlFile = archive.findFile('changelog.jsonl');
        if (jsonlFile != null) {
          final content = utf8.decode(jsonlFile.content as List<int>);
          for (final line in content.split('\n')) {
            final trimmed = line.trim();
            if (trimmed.isEmpty) continue;
            try {
              final entry = jsonDecode(trimmed) as Map<String, dynamic>;
              allChanges.add(entry);
            } catch (_) {}
          }
        }

        // 解压附件到本地
        for (final file in archive.files) {
          if (file.name == 'changelog.jsonl') continue;
          final outPath = p.join(imgDir.path, file.name);
          await File(outPath).writeAsBytes(file.content as List<int>);
        }
      } catch (e) {
        AppLogger.instance.e('[IncrementalSync] 下载/解压失败: $zipName', e);
      }
    }

    // 去重合并：按 entityType+entityId 保留最新 revision
    final merged = <String, Map<String, dynamic>>{};
    for (final entry in allChanges) {
      final key = '${entry['entityType']}|${entry['entityId']}';
      final existing = merged[key];
      if (existing == null || (entry['revision'] as int) > (existing['revision'] as int)) {
        merged[key] = entry;
      }
    }

    final changes = merged.values.toList();
    onProgress?.call('apply', 0.9, '应用 ${changes.length} 条变更...');
    await _applyChanges(changes);

    // 更新本地状态
    await _stateManager.writeLocalState(remoteState);

    onProgress?.call('done', 1.0, '增量拉取完成');
    return SyncResult.success(
      message: '增量拉取完成，${changes.length} 条变更已应用',
      changeCount: changes.length,
    );
  }

  /// 应用变更到本地数据库
  Future<void> _applyChanges(List<Map<String, dynamic>> changes) async {
    for (final change in changes) {
      try {
        final entityType = change['entityType'] as String?;
        final operation = change['operation'] as String?;
        final entityId = change['entityId'] as String?;
        final payload = change['payload'] as Map<String, dynamic>?;

        if (entityType == null || operation == null || entityId == null) continue;

        if (entityType == 'deals') {
          await _applyDealChange(entityId, operation, payload);
        } else if (entityType == 'app_settings') {
          await _applySettingChange(entityId, operation, payload);
        } else if (entityType == 'ai_configs') {
          await _applyAiConfigChange(entityId, operation, payload);
        } else if (entityType == 'secrets') {
          await _applySecretChange(entityId, operation, payload);
        } else if (entityType == 'prompts') {
          await _applyPromptChange(entityId, operation, payload);
        } else if (entityType == 'image_compress_settings') {
          await _applyImageCompressChange(entityId, operation, payload);
        }
      } catch (e) {
        AppLogger.instance.e('[IncrementalSync] 应用变更失败', e);
      }
    }
  }

  Future<void> _applyDealChange(String dealId, String operation, Map<String, dynamic>? payload) async {
    switch (operation) {
      case 'upsert':
        if (payload == null) return;
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
          image = DealImage.fromJson(imageJson);
        }
        await _dealDao.saveDeal(DealWithDetails(
          deal: deal,
          tags: tags,
          promotions: promotions,
          coupons: coupons,
          image: image,
        ));
      case 'pending_delete':
        await _dealDao.softDeleteDeal(dealId);
      case 'delete':
        await _dealDao.hardDeleteDeal(dealId);
    }
  }

  Future<void> _applySettingChange(String key, String operation, Map<String, dynamic>? payload) async {
    if (operation == 'upsert' || operation == 'insert' || operation == 'update') {
      if (payload != null && payload['value'] != null) {
        await _db.into(_db.appSettings).insertOnConflictUpdate(AppSetting(
          key: key,
          value: payload['value'] as String,
          updatedAt: DateTime.now(),
        ));
      }
    } else if (operation == 'delete') {
      await (_db.delete(_db.appSettings)..where((t) => t.key.equals(key))).go();
    }
  }

  Future<void> _applyAiConfigChange(String id, String operation, Map<String, dynamic>? payload) async {
    if (operation == 'upsert' || operation == 'insert' || operation == 'update') {
      if (payload != null) {
        await _db.into(_db.aiConfigs).insertOnConflictUpdate(AiConfig.fromJson(payload));
      }
    } else if (operation == 'delete') {
      await (_db.delete(_db.aiConfigs)..where((t) => t.id.equals(id))).go();
    }
  }

  Future<void> _applySecretChange(String compositeKey, String operation, Map<String, dynamic>? payload) async {
    if (operation == 'upsert' || operation == 'insert' || operation == 'update') {
      if (payload != null) {
        await _db.into(_db.secrets).insertOnConflictUpdate(Secret.fromJson(payload));
      }
    } else if (operation == 'delete') {
      // compositeKey 格式：category|keyName|entityId 或 category|keyName
      final parts = compositeKey.split('|');
      var query = _db.delete(_db.secrets)
        ..where((t) => t.category.equals(parts[0]) & t.keyName.equals(parts[1]));
      if (parts.length > 2) {
        query = _db.delete(_db.secrets)
          ..where((t) =>
              t.category.equals(parts[0]) &
              t.keyName.equals(parts[1]) &
              t.entityId.equals(parts[2]));
      }
      await query.go();
    }
  }

  Future<void> _applyPromptChange(String id, String operation, Map<String, dynamic>? payload) async {
    if (operation == 'upsert' || operation == 'insert' || operation == 'update') {
      if (payload != null) {
        await _db.into(_db.prompts).insertOnConflictUpdate(Prompt.fromJson(payload));
      }
    } else if (operation == 'delete') {
      await (_db.delete(_db.prompts)..where((t) => t.id.equals(id))).go();
    }
  }

  Future<void> _applyImageCompressChange(String minSizeStr, String operation, Map<String, dynamic>? payload) async {
    if (operation == 'upsert' || operation == 'insert' || operation == 'update') {
      if (payload != null) {
        await _db.into(_db.imageCompressSettings).insertOnConflictUpdate(
              ImageCompressSetting.fromJson(payload),
            );
      }
    } else if (operation == 'delete') {
      final minSize = int.tryParse(minSizeStr) ?? 0;
      await (_db.delete(_db.imageCompressSettings)
            ..where((t) => t.minSize.equals(minSize)))
          .go();
    }
  }
}

class _IncrementalPackage {
  final Uint8List zipData;
  final List<int> changeIds;
  final int changeCount;

  _IncrementalPackage({
    required this.zipData,
    required this.changeIds,
    required this.changeCount,
  });
}
