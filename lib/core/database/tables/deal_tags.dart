// 优惠标签关联表定义
//
// 存储优惠记录与标签的多对多关系。
// 联合主键 (dealId, tag) 确保同一优惠下标签不重复。

import 'package:drift/drift.dart';

/// 优惠标签关联表
class DealTags extends Table {
  TextColumn get dealId => text()();
  TextColumn get tag => text()();

  @override
  Set<Column> get primaryKey => {dealId, tag};
}
