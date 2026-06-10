// 优惠促销权益表定义
//
// 存储优惠记录的促销权益信息，每条记录对应一条促销文案。
// sortOrder 用于保持促销权益的原始顺序。

import 'package:drift/drift.dart';

/// 优惠促销权益表
class DealPromotions extends Table {
  TextColumn get dealId => text()();
  IntColumn get sortOrder => integer()();
  TextColumn get textContent => text()();

  @override
  Set<Column> get primaryKey => {dealId, sortOrder};
}
