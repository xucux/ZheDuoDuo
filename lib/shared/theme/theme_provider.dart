// 全局 Provider 定义
//
// 提供 Riverpod Provider 用于：
// - AppDatabase 单例管理（databaseProvider）
// - SettingsDao / AiConfigDao / SecretsDao / ImageCompressSettingsDao 实例的依赖注入
// - ChangeLogger / SyncDao 实例的依赖注入
// - 主题模式状态管理（themeModeProvider / ThemeModeNotifier）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/settings_dao.dart';
import '../../core/database/daos/ai_config_dao.dart';
import '../../core/database/daos/secrets_dao.dart';
import '../../core/database/daos/image_compress_settings_dao.dart';
import '../../core/database/daos/sync_dao.dart';
import '../../core/sync/change_logger.dart';

/// 数据库实例 Provider（单例，自动关闭）
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// 同步数据访问对象 Provider
final syncDaoProvider = Provider<SyncDao>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncDao(db);
});

/// ChangeLogger Provider
final changeLoggerProvider = Provider<ChangeLogger>((ref) {
  final db = ref.watch(databaseProvider);
  final syncDao = ref.watch(syncDaoProvider);
  return ChangeLogger(db, syncDao);
});

/// 设置 DAO Provider
final settingsDaoProvider = Provider<SettingsDao>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = ref.watch(changeLoggerProvider);
  return SettingsDao(db, logger);
});

/// AI 配置 DAO Provider
final aiConfigDaoProvider = Provider<AiConfigDao>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = ref.watch(changeLoggerProvider);
  return AiConfigDao(db, logger);
});

/// 密钥密码 DAO Provider
final secretsDaoProvider = Provider<SecretsDao>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = ref.watch(changeLoggerProvider);
  return SecretsDao(db, logger);
});

/// 图片压缩配置 DAO Provider
final imageCompressSettingsDaoProvider = Provider<ImageCompressSettingsDao>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = ref.watch(changeLoggerProvider);
  return ImageCompressSettingsDao(db, logger);
});

/// 主题模式 Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final settingsDao = ref.watch(settingsDaoProvider);
  return ThemeModeNotifier(settingsDao);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsDao _dao;

  ThemeModeNotifier(this._dao) : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    try {
      final value = await _dao.getValue('themeMode');
      if (value != null) {
        final index = int.tryParse(value);
        if (index != null && index >= 0 && index < ThemeMode.values.length) {
          state = ThemeMode.values[index];
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> setThemeMode(ThemeMode mode, {bool silent = false}) async {
    state = mode;
    if (silent) {
      await _dao.setValueSilent('themeMode', mode.index.toString());
    } else {
      await _dao.setValue('themeMode', mode.index.toString());
    }
  }
}
