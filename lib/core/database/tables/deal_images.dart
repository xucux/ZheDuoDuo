// 优惠图片表定义
//
// 存储优惠记录关联的图片信息，包括原图/缩略图路径、尺寸、压缩参数等。
// dealId 为主键，每条优惠最多关联一张图片。

import 'package:drift/drift.dart';

/// 优惠图片表
class DealImages extends Table {
  TextColumn get dealId => text()();
  TextColumn get imagePath => text()();
  TextColumn get thumbPath => text().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get quality => integer().nullable()();
  IntColumn get originalSize => integer().nullable()();
  IntColumn get compressedSize => integer().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {dealId};
}
