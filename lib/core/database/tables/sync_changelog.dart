// 同步变更日志表定义
//
// 记录所有业务表的数据变更，用于增量同步。
// 覆盖 deals、app_settings、ai_configs、secrets、prompts 等全部业务表。
// entityType 视为 tableName，entityId 视为 primaryKey。

import 'package:drift/drift.dart';

/// 同步变更日志表
class SyncChangelog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  TextColumn get entityType => text()(); // 语义：变更表名（如 deals、app_settings）
  TextColumn get entityId => text()();   // 语义：主键值（联合主键用 JSON 数组）
  TextColumn get operation => text()();
  IntColumn get revision => integer()();
  DateTimeColumn get changedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  /// 是否涉及附件（1=是，0=否）
  IntColumn get hasAttachment => integer().withDefault(const Constant(0))();

  /// 附件本地路径列表，JSON 数组格式
  TextColumn get attachmentPaths => text().nullable()();

  /// 变更后数据快照（JSON）。DELETE 时可为空
  TextColumn get payload => text().nullable()();
}
