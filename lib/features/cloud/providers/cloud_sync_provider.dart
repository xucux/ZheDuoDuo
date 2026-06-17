// 云同步 Provider
//
// 提供 Riverpod Provider 用于：
// - 同步数据访问对象（syncDaoProvider）
// - 备份服务（backupServiceProvider）
// - 同步服务（syncServiceProvider）

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/backup/backup_service.dart';
import '../../../core/database/daos/deal_dao.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/sync/incremental_sync_service.dart';
import '../../../core/sync/sync_state_manager.dart';
import '../../../shared/theme/theme_provider.dart';

/// 备份服务 Provider
final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(db);
});

/// DealDao Provider（只读，用于同步服务应用远端变更）
final syncDealDaoProvider = Provider<DealDao>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = ref.watch(changeLoggerProvider);
  return DealDao(db, ref.watch(syncDaoProvider), logger);
});

/// 同步状态管理器 Provider
final syncStateManagerProvider = Provider<SyncStateManager>((ref) {
  return SyncStateManager(remoteStatePath: 'zheduoduo/synccloud.json');
});

/// 增量同步服务 Provider
final incrementalSyncServiceProvider = Provider<IncrementalSyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final syncDao = ref.watch(syncDaoProvider);
  final dealDao = ref.watch(syncDealDaoProvider);
  final stateManager = ref.watch(syncStateManagerProvider);
  return IncrementalSyncService(db, syncDao, dealDao, stateManager);
});

/// 同步服务 Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final backupService = ref.watch(backupServiceProvider);
  final syncDao = ref.watch(syncDaoProvider);
  final dealDao = ref.watch(syncDealDaoProvider);
  final incremental = ref.watch(incrementalSyncServiceProvider);
  return SyncService(backupService, syncDao, dealDao, incremental);
});
