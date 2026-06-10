// 应用数据库定义
//
// 使用 Drift（原 moor）ORM 定义数据库结构。
// 包含优惠、标签、促销、优惠券、图片、设置、同步元数据、AI 配置、密钥等表。
// 数据库文件存储在应用文档目录的 zheduoduo_data/zheduoduo.db。

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/deals.dart';
import 'tables/deal_tags.dart';
import 'tables/deal_promotions.dart';
import 'tables/coupons.dart';
import 'tables/deal_images.dart';
import 'tables/app_settings.dart';
import 'tables/sync_meta.dart';
import 'tables/sync_changelog.dart';
import 'tables/backup_records.dart';
import 'tables/ai_configs.dart';
import 'tables/secrets.dart';

part 'app_database.g.dart';

/// 折多多主数据库
///
/// 管理所有本地数据表，当前 schema 版本为 2。
/// 使用 drift_flutter 的 driftDatabase() 创建平台原生连接。
@DriftDatabase(tables: [
  Deals,
  DealTags,
  DealPromotions,
  Coupons,
  DealImages,
  AppSettings,
  SyncMeta,
  SyncChangelog,
  BackupRecords,
  AiConfigs,
  Secrets,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // v1 -> v2: 新增 AiConfigs 和 Secrets 表
          if (from < 2) {
            await m.createTable(aiConfigs);
            await m.createTable(secrets);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'zheduoduo',
      native: const DriftNativeOptions(
        databaseDirectory: _getDatabaseDirectory,
      ),
    );
  }

  static Future<String> _getDatabaseDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(appDir.path, 'zheduoduo_data'));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    return dbDir.path;
  }
}
