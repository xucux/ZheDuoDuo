// 图片压缩配置数据访问对象（DAO）
//
// 提供图片压缩配置的数据库操作，包括：
// - 获取所有压缩档位配置
// - 根据文件大小匹配压缩质量
// - 更新/重置压缩档位配置

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/image_compress_settings.dart';
import '../../sync/change_logger.dart';

part 'image_compress_settings_dao.g.dart';

/// 图片压缩配置数据访问对象
///
/// 管理按文件大小分档的压缩质量配置。
/// 压缩时按 minSize 升序匹配，取第一个满足 fileSize >= minSize 的档位。
@DriftAccessor(tables: [ImageCompressSettings])
class ImageCompressSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$ImageCompressSettingsDaoMixin {
  final ChangeLogger? _changeLogger;

  ImageCompressSettingsDao(super.db, [this._changeLogger]);

  /// 获取所有压缩档位配置（按 minSize 升序）
  Future<List<ImageCompressSetting>> getAllSettings() async {
    return (select(imageCompressSettings)
          ..orderBy([(t) => OrderingTerm.asc(t.minSize)]))
        .get();
  }

  /// 监听所有压缩档位配置变化
  Stream<List<ImageCompressSetting>> watchAllSettings() {
    return (select(imageCompressSettings)
          ..orderBy([(t) => OrderingTerm.asc(t.minSize)]))
        .watch();
  }

  /// 根据文件大小匹配压缩配置
  ///
  /// 按 minSize 升序查找第一个满足 [fileSize] >= minSize 的档位。
  /// 若无匹配则返回默认配置（quality=70, maxWidth=1600）。
  Future<ImageCompressSetting> getSettingForSize(int fileSize) async {
    final settings = await getAllSettings();
    // 从大到小匹配，找到第一个 minSize <= fileSize 的档位
    for (final setting in settings.reversed) {
      if (fileSize >= setting.minSize) {
        return setting;
      }
    }
    // 兜底返回最小档位
    if (settings.isNotEmpty) return settings.first;
    // 无任何配置时返回默认值
    return ImageCompressSetting(
      minSize: 0,
      quality: 70,
      label: '默认',
      maxWidth: 1600,
    );
  }

  /// 更新指定档位的压缩质量
  Future<void> updateQuality(int minSize, int quality) async {
    await (update(imageCompressSettings)
          ..where((t) => t.minSize.equals(minSize)))
        .write(ImageCompressSettingsCompanion(
      quality: Value(quality),
    ));
    await _changeLogger?.logImageCompressSetting(minSize, 'update', payload: {'quality': quality});
  }

  /// 更新指定档位的最大宽度
  Future<void> updateMaxWidth(int minSize, int maxWidth) async {
    await (update(imageCompressSettings)
          ..where((t) => t.minSize.equals(minSize)))
        .write(ImageCompressSettingsCompanion(
      maxWidth: Value(maxWidth),
    ));
    await _changeLogger?.logImageCompressSetting(minSize, 'update', payload: {'maxWidth': maxWidth});
  }

  /// 静默 upsert（从 ImageCompressSetting 模型，不记录 changelog，用于同步服务应用远端变更）
  Future<void> upsertFromModelSilent(ImageCompressSetting setting) async {
    await into(imageCompressSettings).insertOnConflictUpdate(setting);
  }

  /// 静默删除指定档位（不记录 changelog，用于同步服务应用远端变更）
  Future<void> deleteSettingSilent(int minSize) async {
    await (delete(imageCompressSettings)
          ..where((t) => t.minSize.equals(minSize)))
        .go();
  }

  /// 重置为默认压缩配置
  ///
  /// 清空现有配置并插入默认分档：
  /// - 小文件 (<500KB): quality=85, maxWidth=1600
  /// - 中文件 (500KB~1MB): quality=70, maxWidth=1600
  /// - 大文件 (1MB~10MB): quality=50, maxWidth=1200
  /// - 超大文件 (>10MB): quality=30, maxWidth=800
  Future<void> resetToDefaults() async {
    await delete(imageCompressSettings).go();
    await batch((b) {
      b.insertAll(imageCompressSettings, [
        ImageCompressSettingsCompanion.insert(
          minSize: const Value(0),
          quality: 85,
          label: '小文件 (<500KB)',
          maxWidth: const Value(1600),
        ),
        ImageCompressSettingsCompanion.insert(
          minSize: const Value(524288),
          quality: 70,
          label: '中文件 (500KB~1MB)',
          maxWidth: const Value(1600),
        ),
        ImageCompressSettingsCompanion.insert(
          minSize: const Value(1048576),
          quality: 50,
          label: '大文件 (1MB~10MB)',
          maxWidth: const Value(1200),
        ),
        ImageCompressSettingsCompanion.insert(
          minSize: const Value(10485760),
          quality: 30,
          label: '超大文件 (>10MB)',
          maxWidth: const Value(800),
        ),
      ]);
    });
    // 重置操作记录为批量 insert
    await _changeLogger?.logImageCompressSetting(0, 'insert');
    await _changeLogger?.logImageCompressSetting(524288, 'insert');
    await _changeLogger?.logImageCompressSetting(1048576, 'insert');
    await _changeLogger?.logImageCompressSetting(10485760, 'insert');
  }
}
