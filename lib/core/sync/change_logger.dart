// 变更日志记录器
//
// 中间件：拦截所有业务 DAO 的写操作，在云同步总开关开启时记录变更日志。
// 统一封装在业务 DAO 中调用，避免分散逻辑。

import 'dart:convert';
import '../database/app_database.dart';
import '../database/daos/sync_dao.dart';
import '../database/daos/settings_dao.dart';

class ChangeLogger {
  final AppDatabase _db;
  final SyncDao _syncDao;
  late final SettingsDao _settingsDao;

  ChangeLogger(this._db, this._syncDao) {
    _settingsDao = SettingsDao(_db);
  }

  /// 检查云同步总开关是否开启
  Future<bool> _isEnabled() async {
    final value = await _settingsDao.getValue('cloud.enabled');
    return value == 'true';
  }

  /// 获取设备 ID
  Future<String?> _getDeviceId() async {
    return _syncDao.getDeviceIdOrNull();
  }

  /// 获取下一个 revision
  Future<int> _nextRevision() async {
    return _syncDao.nextRevision();
  }

  /// 记录一次变更（通用入口）
  Future<void> log({
    required String tableName,
    required String primaryKey,
    required String operation, // INSERT / UPDATE / DELETE
    int hasAttachment = 0,
    List<String>? attachmentPaths,
    Map<String, dynamic>? payload,
  }) async {
    if (!await _isEnabled()) return;

    final deviceId = await _getDeviceId();
    if (deviceId == null || deviceId.isEmpty) return;

    final revision = await _nextRevision();

    await _syncDao.logChange(
      deviceId: deviceId,
      entityType: tableName,
      entityId: primaryKey,
      operation: operation,
      revision: revision,
      hasAttachment: hasAttachment,
      attachmentPaths: attachmentPaths != null ? jsonEncode(attachmentPaths) : null,
      payload: payload != null ? jsonEncode(payload) : null,
    );
  }

  /// 快捷方法：记录 deal 变更
  Future<void> logDeal(String dealId, String operation, {List<String>? imagePaths}) async {
    await log(
      tableName: 'deals',
      primaryKey: dealId,
      operation: operation,
      hasAttachment: (imagePaths != null && imagePaths.isNotEmpty) ? 1 : 0,
      attachmentPaths: imagePaths,
    );
  }

  /// 快捷方法：记录 deal_images 变更
  Future<void> logDealImages(String dealId, List<String> imagePaths) async {
    await log(
      tableName: 'deal_images',
      primaryKey: dealId,
      operation: 'UPDATE',
      hasAttachment: 1,
      attachmentPaths: imagePaths,
    );
  }

  /// 快捷方法：记录 app_settings 变更
  Future<void> logSetting(String key, String operation, {Map<String, dynamic>? payload}) async {
    await log(
      tableName: 'app_settings',
      primaryKey: key,
      operation: operation,
      payload: payload,
    );
  }

  /// 快捷方法：记录 ai_configs 变更
  Future<void> logAiConfig(String configId, String operation, {Map<String, dynamic>? payload}) async {
    await log(
      tableName: 'ai_configs',
      primaryKey: configId,
      operation: operation,
      payload: payload,
    );
  }

  /// 快捷方法：记录 secrets 变更
  Future<void> logSecret(String compositeKey, String operation, {Map<String, dynamic>? payload}) async {
    await log(
      tableName: 'secrets',
      primaryKey: compositeKey,
      operation: operation,
      payload: payload,
    );
  }

  /// 快捷方法：记录 prompts 变更
  Future<void> logPrompt(String promptId, String operation, {Map<String, dynamic>? payload}) async {
    await log(
      tableName: 'prompts',
      primaryKey: promptId,
      operation: operation,
      payload: payload,
    );
  }

  /// 快捷方法：记录 image_compress_settings 变更
  Future<void> logImageCompressSetting(int minSize, String operation, {Map<String, dynamic>? payload}) async {
    await log(
      tableName: 'image_compress_settings',
      primaryKey: minSize.toString(),
      operation: operation,
      payload: payload,
    );
  }
}
