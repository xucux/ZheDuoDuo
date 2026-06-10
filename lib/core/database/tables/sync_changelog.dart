// 同步变更日志表定义
//
// 记录每次数据变更的操作类型和版本号，用于增量同步。
// 包含实体类型、实体ID、操作类型（insert/update/delete）和同步状态。

import 'package:drift/drift.dart';

/// 同步变更日志表
class SyncChangelog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  IntColumn get revision => integer()();
  DateTimeColumn get changedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  TextColumn get payloadHash => text().nullable()();
}
