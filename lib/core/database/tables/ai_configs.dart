// AI 对话配置表定义
//
// 存储 AI 对话的所有配置信息，包括服务商、协议、API Key、模型参数等。
// 每条记录对应一个 AI 配置方案，id 为主键。
// API Key 等敏感信息以明文存储，不进行加密。

import 'package:drift/drift.dart';

/// AI 对话配置表
class AiConfigs extends Table {
  /// 配置唯一标识
  TextColumn get id => text()();
  /// 服务商预设 ID（deepseek / siliconflow / openai / claude / custom）
  TextColumn get providerPreset => text().withDefault(const Constant('custom'))();
  /// 协议类型（openaiResponses / openaiChat / anthropic / githubCopilot）
  TextColumn get protocol => text().withDefault(const Constant('openaiChat'))();
  /// API Key（明文存储）
  TextColumn get apiKey => text().withDefault(const Constant(''))();
  /// Base URL
  TextColumn get baseUrl => text().withDefault(const Constant(''))();
  /// 模型名称
  TextColumn get model => text().withDefault(const Constant(''))();
  /// Agent 角色 ID（default / shopping / yaml_parser）
  TextColumn get agentRole => text().withDefault(const Constant('default'))();
  /// Agent 系统提示词
  TextColumn get agentPrompt => text().withDefault(const Constant(''))();
  /// 温度参数（0.0 - 2.0）
  RealColumn get temperature => real().withDefault(const Constant(0.7))();
  /// 最大输出 token 数
  IntColumn get maxTokens => integer().withDefault(const Constant(4096))();
  /// 是否为当前激活的配置
  IntColumn get isActive => integer().withDefault(const Constant(0))();
  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();
  /// 更新时间
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
