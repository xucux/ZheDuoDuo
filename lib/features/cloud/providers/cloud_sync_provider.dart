// 云同步 Provider
//
// 提供 Riverpod Provider 用于：
// - 同步数据访问对象（syncDaoProvider）
// - 备份服务（backupServiceProvider）
// - 同步服务（syncServiceProvider）

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/backup/backup_service.dart';
import '../../../core/database/daos/sync_dao.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/theme/theme_provider.dart';

/// 同步数据访问对象 Provider
final syncDaoProvider = Provider<SyncDao>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncDao(db);
});

/// 备份服务 Provider
final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(db);
});

/// 同步服务 Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final backupService = ref.watch(backupServiceProvider);
  final syncDao = ref.watch(syncDaoProvider);
  return SyncService(backupService, syncDao);
});
