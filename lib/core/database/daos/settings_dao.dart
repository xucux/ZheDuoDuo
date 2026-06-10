// 应用设置数据访问对象（DAO）
//
// 提供键值对形式的应用设置存取，包括：
// - 获取/设置/删除/监听单个设置项
// - 获取所有设置项
// 设置项存储在 AppSettings 表中，以 key 为主键。

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_settings.dart';

part 'settings_dao.g.dart';

/// 应用设置数据访问对象
///
/// 以键值对形式存取应用配置，如主题、排序、货币等。
@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  /// Get a setting value by key
  Future<String?> getValue(String key) async {
    final query = select(appSettings)..where((t) => t.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  /// Set a setting value
  Future<void> setValue(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSetting(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Remove a setting
  Future<void> removeValue(String key) async {
    await (delete(appSettings)..where((t) => t.key.equals(key))).go();
  }

  /// Watch a setting value
  Stream<String?> watchValue(String key) {
    final query = select(appSettings)..where((t) => t.key.equals(key));
    return query.watchSingleOrNull().map((result) => result?.value);
  }

  /// Get all settings
  Future<Map<String, String>> getAllSettings() async {
    final results = await select(appSettings).get();
    return {for (final r in results) r.key: r.value};
  }
}
