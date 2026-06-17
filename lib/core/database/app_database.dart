// 应用数据库定义
//
// 使用 Drift（原 moor）ORM 定义数据库结构。
// 包含优惠、标签、促销、优惠券、图片、设置、同步元数据、AI 配置、密钥等表。
// 数据库文件存储在外部存储（Android）或应用文档目录的 zheduoduo_data/zheduoduo.db。

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
import 'tables/prompts.dart';
import 'tables/image_compress_settings.dart';

part 'app_database.g.dart';

/// 折多多主数据库
///
/// 管理所有本地数据表，当前 schema 版本为 6。
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
  Prompts,
  ImageCompressSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(aiConfigs);
            await m.createTable(secrets);
          }
          if (from < 3) {
            await m.createTable(prompts);
          }
          if (from < 4) {
            await m.addColumn(deals, deals.isLowestPrice);
          }
          if (from < 5) {
            await m.createTable(imageCompressSettings);
            // 插入默认压缩配置
            await customStatement(
              'INSERT INTO image_compress_settings (min_size, quality, label, max_width) VALUES '
              '(0, 85, \'小文件 (<500KB)\', 1600), '
              '(524288, 70, \'中文件 (500KB~1MB)\', 1600), '
              '(1048576, 50, \'大文件 (1MB~10MB)\', 1200), '
              '(10485760, 30, \'超大文件 (>10MB)\', 800)',
            );
          }
          if (from < 6) {
            await m.addColumn(dealImages, dealImages.deleted);
          }
          if (from < 7) {
            try {
              await m.addColumn(aiConfigs, aiConfigs.capabilities);
            } catch (_) {
              // 列已存在时忽略（如数据库通过其他方式已更新）
            }
          }
          if (from < 8) {
            try {
              await m.addColumn(deals, deals.sourceJson);
            } catch (_) {
              // 列已存在时忽略
            }
          }
          if (from < 9) {
            // 扩展 sync_changelog 表：新增附件标记和数据快照字段
            await customStatement('ALTER TABLE sync_changelog ADD COLUMN has_attachment INTEGER NOT NULL DEFAULT 0');
            await customStatement('ALTER TABLE sync_changelog ADD COLUMN attachment_paths TEXT');
            await customStatement('ALTER TABLE sync_changelog ADD COLUMN payload TEXT');
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
    final dir = await _getDataDirectory();
    final dbDir = Directory(p.join(dir.path, 'zheduoduo_data'));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    return dbDir.path;
  }

  static Future<Directory> _getDataDirectory() async {
    if (Platform.isAndroid) {
      // getExternalStorageDirectory() 已返回 /storage/emulated/0/Android/data/<package>/files/
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return externalDir;
      }
    }
    return getApplicationDocumentsDirectory();
  }
}
