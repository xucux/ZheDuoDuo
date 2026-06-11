// 全局 Provider 定义
//
// 提供 Riverpod Provider 用于：
// - AppDatabase 单例管理（databaseProvider）
// - SettingsDao / AiConfigDao / SecretsDao / ImageCompressSettingsDao 实例的依赖注入
// - 主题模式状态管理（themeModeProvider / ThemeModeNotifier）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/settings_dao.dart';
import '../../core/database/daos/ai_config_dao.dart';
import '../../core/database/daos/secrets_dao.dart';
import '../../core/database/daos/image_compress_settings_dao.dart';

/// 设置 DAO Provider
final settingsDaoProvider = Provider<SettingsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsDao(db);
});

/// AI 配置 DAO Provider
final aiConfigDaoProvider = Provider<AiConfigDao>((ref) {
  final db = ref.watch(databaseProvider);
  return AiConfigDao(db);
});

/// 密钥密码 DAO Provider
final secretsDaoProvider = Provider<SecretsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return SecretsDao(db);
});

/// 图片压缩配置 DAO Provider
final imageCompressSettingsDaoProvider = Provider<ImageCompressSettingsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return ImageCompressSettingsDao(db);
});

/// 数据库实例 Provider（单例，自动关闭）
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// 主题模式 Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final settingsDao = ref.watch(settingsDaoProvider);
  return ThemeModeNotifier(settingsDao);
});

/// 主题模式状态管理器
///
/// 从数据库加载主题偏好，并提供切换主题的方法。
/// 主题设置持久化到 AppSettings 表的 'theme' 键。
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsDao _settingsDao;

  ThemeModeNotifier(this._settingsDao) : super(ThemeMode.system) {
    _loadTheme();
  }

  /// 从数据库加载主题偏好
  Future<void> _loadTheme() async {
    final theme = await _settingsDao.getValue('theme');
    switch (theme) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  /// 设置主题模式并持久化
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _settingsDao.setValue('theme', value);
  }
}
