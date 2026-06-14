// 优惠记录表定义
//
// 存储优惠商品的核心信息，包括标题、价格、平台、分类、折扣等。
// deleted 字段用于软删除：0=正常，2=待删除。
// revision 字段用于云同步的版本控制。
// isLowestPrice 字段标识当前价格是否为历史最低：0=否，1=是。

import 'package:drift/drift.dart';

/// 优惠记录表
class Deals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get platform => text().withDefault(const Constant('其他'))();
  TextColumn get category => text().withDefault(const Constant('其他'))();
  RealColumn get currentPrice => real()();
  RealColumn get originalPrice => real().nullable()();
  RealColumn get displayPrice => real().nullable()();
  TextColumn get currency => text().withDefault(const Constant('¥'))();
  TextColumn get discount => text().nullable()();
  TextColumn get logistics => text().nullable()();
  TextColumn get link => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get visualType => text().withDefault(const Constant('none'))();
  TextColumn get asciiArt => text().nullable()();
  TextColumn get salesJson => text().nullable()();
  TextColumn get sourceJson => text().nullable()();
  IntColumn get isLowestPrice => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  IntColumn get deleted => integer().withDefault(const Constant(0))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
