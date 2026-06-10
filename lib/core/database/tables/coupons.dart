// 优惠券表定义
//
// 存储优惠记录关联的优惠券信息，包括数量、来源、优惠力度和备注。
// sortOrder 用于保持优惠券的原始顺序。

import 'package:drift/drift.dart';

/// 优惠券表
class Coupons extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dealId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get count => integer().withDefault(const Constant(1))();
  TextColumn get source => text().withDefault(const Constant(''))();
  TextColumn get strength => text().withDefault(const Constant(''))();
  TextColumn get note => text().nullable()();
}
