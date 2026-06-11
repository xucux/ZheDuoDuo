// 图片压缩配置表定义
//
// 按原始文件大小分档存储压缩质量配置。
// 每档记录最小文件大小阈值和对应压缩质量（0-100）。
// 压缩时按 minSize 升序匹配，取第一个满足 fileSize >= minSize 的档位。

import 'package:drift/drift.dart';

/// 图片压缩配置表
///
/// 示例数据：
/// | minSize | quality | label    |
/// | 0       | 85      | 小文件    |
/// | 524288  | 70      | 中文件    |
/// | 1048576 | 50      | 大文件    |
/// | 10485760| 30      | 超大文件  |
class ImageCompressSettings extends Table {
  /// 文件大小阈值（字节），作为主键
  IntColumn get minSize => integer()();
  /// 压缩质量（0-100），数值越低压缩率越高
  IntColumn get quality => integer()();
  /// 档位显示名称
  TextColumn get label => text()();
  /// 最大宽度（像素），超过此宽度会等比缩放，0 表示不限制
  IntColumn get maxWidth => integer().withDefault(const Constant(1600))();

  @override
  Set<Column> get primaryKey => {minSize};
}
