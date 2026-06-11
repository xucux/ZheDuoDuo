// 同步数据访问对象（DAO）
//
// 提供云同步相关的数据库操作，包括：
// - 读取/更新同步元数据（设备 ID、版本号、推送/拉取时间）
// - 读取未同步的变更日志
// - 标记变更日志为已同步
// - 记录新的数据变更

import 'package:drift/drift.dart';
import '../app_database.dart';

/// 同步数据访问对象
///
/// 管理同步元数据和变更日志的数据库操作。
class SyncDao extends DatabaseAccessor<AppDatabase> {
  SyncDao(super.db);

  /// 获取同步元数据（全局唯一，id=1）
  Future<SyncMetaData?> getSyncMeta() async {
    return (select(attachedDatabase.syncMeta)..where((t) => t.id.equals(1))).getSingleOrNull();
  }

  /// 更新或插入同步元数据
  Future<void> upsertSyncMeta(SyncMetaData data) async {
    await into(attachedDatabase.syncMeta).insertOnConflictUpdate(data);
  }

  /// 更新版本号和推送/拉取时间
  ///
  /// [revision] 新版本号，[pushAt] 推送时间，[pullAt] 拉取时间。
  Future<void> updateRevision(int revision, {DateTime? pushAt, DateTime? pullAt}) async {
    final now = DateTime.now();
    await (update(attachedDatabase.syncMeta)..where((t) => t.id.equals(1))).write(
      SyncMetaCompanion(
        localRevision: Value(revision),
        lastPushAt: Value(pushAt ?? now),
        remoteRevision: Value(revision),
        lastPullAt: Value(pullAt ?? now),
      ),
    );
  }

  /// 获取指定设备未同步的变更日志
  Future<List<SyncChangelogData>> getPendingChanges(String deviceId) async {
    return (select(attachedDatabase.syncChangelog)..where((t) => t.deviceId.equals(deviceId) & t.syncedAt.isNull())).get();
  }

  /// 标记指定变更日志为已同步
  Future<void> markSynced(int id) async {
    await (update(attachedDatabase.syncChangelog)..where((t) => t.id.equals(id))).write(
      SyncChangelogCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  /// 记录一条新的数据变更日志
  ///
  /// [deviceId] 设备 ID，[entityType] 实体类型（如 deal），
  /// [entityId] 实体 ID，[operation] 操作类型（insert/update/delete），
  /// [revision] 变更版本号。
  Future<void> logChange(String deviceId, String entityType, String entityId, String operation, int revision) async {
    await into(attachedDatabase.syncChangelog).insert(SyncChangelogCompanion.insert(
      deviceId: deviceId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      revision: revision,
      changedAt: DateTime.now(),
    ));
  }
}
