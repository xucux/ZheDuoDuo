// 同步元数据表定义
//
// 存储云同步的设备信息和版本号，用于增量同步判断。
// id 固定为 1，全局只有一条记录。

import 'package:drift/drift.dart';

/// 同步元数据表
class SyncMeta extends Table {
  IntColumn get id => integer()();
  TextColumn get deviceId => text()();
  IntColumn get localRevision => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPushAt => dateTime().nullable()();
  DateTimeColumn get lastPullAt => dateTime().nullable()();
  IntColumn get remoteRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
