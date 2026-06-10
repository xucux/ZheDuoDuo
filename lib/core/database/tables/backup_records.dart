// 备份记录表定义
//
// 记录每次备份操作的元信息，包括文件路径、大小、优惠数量和来源。
// source 字段标识备份来源（manual/auto/import）。

import 'package:drift/drift.dart';

/// 备份记录表
class BackupRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text()();
  IntColumn get fileSize => integer().nullable()();
  IntColumn get dealCount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
}
