// AI 配置数据访问对象（DAO）
//
// 提供 AI 对话配置的数据库操作，包括：
// - 获取/监听当前激活的 AI 配置
// - 保存/更新 AI 配置
// - 列出所有 AI 配置方案
// - 切换激活的配置方案

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/ai_configs.dart';

part 'ai_config_dao.g.dart';

/// AI 配置数据访问对象
///
/// 管理 AI 对话配置方案的 CRUD 操作。
@DriftAccessor(tables: [AiConfigs])
class AiConfigDao extends DatabaseAccessor<AppDatabase> with _$AiConfigDaoMixin {
  AiConfigDao(super.db);

  /// 获取当前激活的 AI 配置
  ///
  /// 返回 isActive=1 的配置，若无则返回 null。
  Future<AiConfig?> getActiveConfig() async {
    final query = select(aiConfigs)..where((t) => t.isActive.equals(1))..limit(1);
    return query.getSingleOrNull();
  }

  /// 监听当前激活的 AI 配置变化
  Stream<AiConfig?> watchActiveConfig() {
    final query = select(aiConfigs)..where((t) => t.isActive.equals(1))..limit(1);
    return query.watchSingleOrNull();
  }

  /// 获取所有 AI 配置方案
  Future<List<AiConfig>> getAllConfigs() async {
    return (select(aiConfigs)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
  }

  /// 保存 AI 配置（upsert）
  ///
  /// 如果 [isActive] 为 true，会先将其他配置的 isActive 设为 0。
  Future<void> saveConfig(AiConfigsCompanion config) async {
    if (config.isActive.present && config.isActive.value == 1) {
      // 取消其他配置的激活状态
      await (update(aiConfigs)..where((t) => t.isActive.equals(1)))
          .write(const AiConfigsCompanion(isActive: Value(0)));
    }
    await into(aiConfigs).insertOnConflictUpdate(config);
  }

  /// 激活指定配置
  ///
  /// 将指定 ID 的配置设为激活，其他配置取消激活。
  Future<void> activateConfig(String id) async {
    await transaction(() async {
      await (update(aiConfigs)..where((t) => t.isActive.equals(1)))
          .write(const AiConfigsCompanion(isActive: Value(0)));
      await (update(aiConfigs)..where((t) => t.id.equals(id)))
          .write(const AiConfigsCompanion(isActive: Value(1)));
    });
  }

  /// 删除指定配置
  Future<void> deleteConfig(String id) async {
    await (delete(aiConfigs)..where((t) => t.id.equals(id))).go();
  }

  /// 获取指定 ID 的配置
  Future<AiConfig?> getConfig(String id) async {
    final query = select(aiConfigs)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  /// 确保至少有一个默认配置
  ///
  /// 如果没有任何配置，创建一个默认配置并激活。
  Future<AiConfig> ensureDefaultConfig() async {
    final existing = await getActiveConfig();
    if (existing != null) return existing;

    final allConfigs = await getAllConfigs();
    if (allConfigs.isNotEmpty) {
      await activateConfig(allConfigs.first.id);
      return (await getActiveConfig())!;
    }

    final now = DateTime.now();
    final defaultConfig = AiConfigsCompanion.insert(
      id: 'default',
      providerPreset: const Value('DeepSeek'),
      protocol: const Value('openaiChat'),
      apiKey: const Value(''),
      baseUrl: const Value('https://api.deepseek.com/v1'),
      model: const Value('deepseek-chat'),
      agentRole: const Value('default'),
      agentPrompt: const Value(''),
      temperature: const Value(0.7),
      maxTokens: const Value(4096),
      isActive: const Value(1),
      createdAt: now,
      updatedAt: now,
    );
    await into(aiConfigs).insert(defaultConfig);
    return (await getActiveConfig())!;
  }
}
