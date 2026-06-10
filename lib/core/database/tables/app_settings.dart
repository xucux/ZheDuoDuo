// 应用设置表定义
//
// 以键值对形式存储应用配置，如主题、排序、货币等。
// key 为主键，value 为字符串形式的配置值。

import 'package:drift/drift.dart';

/// 应用设置表
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
