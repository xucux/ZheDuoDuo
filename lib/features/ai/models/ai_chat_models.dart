// AI 对话模型定义
//
// 包含协议类型、服务商预设、Agent 角色、会话与消息的数据模型。
// 会话数据仅保存在本地 SharedPreferences，不写入数据库，不参与云同步与备份。

import 'dart:convert';

// ==================== 协议类型 ====================

/// AI 协议类型枚举
enum AiProtocol {
  /// OpenAI Responses API（/v1/responses）
  openaiResponses,

  /// OpenAI Chat Completions（/v1/chat/completions）
  openaiChat,

  /// Anthropic Messages API
  anthropic,

  /// GitHub Copilot API
  githubCopilot;

  /// 从字符串解析协议类型
  static AiProtocol fromString(String value) {
    switch (value) {
      case 'openaiResponses':
        return AiProtocol.openaiResponses;
      case 'openaiChat':
        return AiProtocol.openaiChat;
      case 'anthropic':
        return AiProtocol.anthropic;
      case 'githubCopilot':
        return AiProtocol.githubCopilot;
      default:
        return AiProtocol.openaiChat;
    }
  }

  /// 转为存储用字符串
  String toKey() => name;
}

// ==================== 服务商预设 ====================

/// AI 服务商预设配置
///
/// 每个预设包含协议类型、Base URL 和默认模型，方便用户快速切换。
class AiProviderPreset {
  final String id;
  final String name;
  final AiProtocol protocol;
  final String baseUrl;
  final String model;

  const AiProviderPreset({
    required this.id,
    required this.name,
    required this.protocol,
    required this.baseUrl,
    required this.model,
  });

  /// 内置服务商预设列表
  static const List<AiProviderPreset> builtIn = [
    AiProviderPreset(
      id: 'deepseek',
      name: 'DeepSeek',
      protocol: AiProtocol.openaiChat,
      baseUrl: 'https://api.deepseek.com/v1',
      model: 'deepseek-chat',
    ),
    AiProviderPreset(
      id: 'siliconflow',
      name: '硅基流动',
      protocol: AiProtocol.openaiChat,
      baseUrl: 'https://api.siliconflow.cn/v1',
      model: 'Qwen/Qwen2.5-72B-Instruct',
    ),
    AiProviderPreset(
      id: 'openai',
      name: 'OpenAI',
      protocol: AiProtocol.openaiChat,
      baseUrl: 'https://api.openai.com/v1',
      model: 'gpt-4o',
    ),
    AiProviderPreset(
      id: 'claude',
      name: 'Claude',
      protocol: AiProtocol.anthropic,
      baseUrl: 'https://api.anthropic.com',
      model: 'claude-3-5-sonnet-20241022',
    ),
    AiProviderPreset(
      id: 'githubCopilot',
      name: 'GitHub Copilot',
      protocol: AiProtocol.githubCopilot,
      baseUrl: 'https://api.githubcopilot.com',
      model: 'gpt-4o-copilot',
    ),
    AiProviderPreset(
      id: 'custom',
      name: '自定义',
      protocol: AiProtocol.openaiChat,
      baseUrl: '',
      model: '',
    ),
  ];

  /// 根据 ID 查找预设
  static AiProviderPreset? findById(String id) {
    for (final p in builtIn) {
      if (p.id == id) return p;
    }
    return null;
  }
}

// ==================== Agent 角色 ====================

/// AI Agent 角色预设
///
/// 定义不同的系统提示词角色，用于控制 AI 的行为风格。
class AiAgent {
  final String id;
  final String name;
  final String prompt;

  const AiAgent({
    required this.id,
    required this.name,
    required this.prompt,
  });

  /// 内置 Agent 列表
  static const List<AiAgent> builtIn = [
    AiAgent(
      id: 'default',
      name: '默认助手',
      prompt: '你是一个 helpful 的助手。',
    ),
    AiAgent(
      id: 'shopping',
      name: '购物参谋',
      prompt: '你是购物比价专家，擅长分析商品优惠、优惠券叠加、历史价格走势。',
    ),
    AiAgent(
      id: 'yaml',
      name: 'YAML 解析器',
      prompt: '你专注于把商品截图或文案解析成结构化 YAML 数据。',
    ),
  ];

  /// 根据 ID 查找 Agent
  static AiAgent? findById(String id) {
    for (final a in builtIn) {
      if (a.id == id) return a;
    }
    return null;
  }
}

// ==================== 对话设置 ====================

/// AI 对话配置
///
/// 包含协议、API Key、Base URL、模型、Agent 等设置项。
/// 通过 [AiChatSettingsService] 持久化到 SharedPreferences。
class AiChatSettings {
  /// 当前选中的服务商预设 ID
  final String providerPreset;

  /// 协议类型
  final AiProtocol protocol;

  /// API Key（仅保存在本地，不上传）
  final String apiKey;

  /// Base URL（可选，留空使用官方地址）
  final String baseUrl;

  /// 模型名称
  final String model;

  /// Agent 角色 ID
  final String agentId;

  /// 温度参数（0.0 ~ 2.0）
  final double temperature;

  /// 最大 Token 数
  final int maxTokens;

  const AiChatSettings({
    this.providerPreset = 'deepseek',
    this.protocol = AiProtocol.openaiChat,
    this.apiKey = '',
    this.baseUrl = '',
    this.model = '',
    this.agentId = 'default',
    this.temperature = 0.7,
    this.maxTokens = 2048,
  });

  /// 从 JSON Map 创建
  factory AiChatSettings.fromJson(Map<String, dynamic> json) {
    return AiChatSettings(
      providerPreset: json['providerPreset'] as String? ?? 'deepseek',
      protocol: AiProtocol.fromString(json['protocol'] as String? ?? 'openai'),
      apiKey: json['apiKey'] as String? ?? '',
      baseUrl: json['baseUrl'] as String? ?? '',
      model: json['model'] as String? ?? '',
      agentId: json['agentId'] as String? ?? 'default',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 2048,
    );
  }

  /// 转为 JSON Map
  Map<String, dynamic> toJson() => {
        'providerPreset': providerPreset,
        'protocol': protocol.toKey(),
        'apiKey': apiKey,
        'baseUrl': baseUrl,
        'model': model,
        'agentId': agentId,
        'temperature': temperature,
        'maxTokens': maxTokens,
      };

  /// 复制并修改部分字段
  AiChatSettings copyWith({
    String? providerPreset,
    AiProtocol? protocol,
    String? apiKey,
    String? baseUrl,
    String? model,
    String? agentId,
    double? temperature,
    int? maxTokens,
  }) {
    return AiChatSettings(
      providerPreset: providerPreset ?? this.providerPreset,
      protocol: protocol ?? this.protocol,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      agentId: agentId ?? this.agentId,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }

  /// 应用服务商预设，自动填充协议、Base URL 和模型
  AiChatSettings applyPreset(String presetId) {
    final preset = AiProviderPreset.findById(presetId);
    if (preset == null) return this;
    return copyWith(
      providerPreset: presetId,
      protocol: preset.protocol,
      baseUrl: preset.baseUrl,
      model: preset.model,
    );
  }
}

// ==================== 消息模型 ====================

/// 聊天消息角色
enum ChatMessageRole {
  /// 用户消息
  user,

  /// AI 助手消息
  assistant;

  String toKey() => name;

  static ChatMessageRole fromString(String value) {
    switch (value) {
      case 'assistant':
        return ChatMessageRole.assistant;
      default:
        return ChatMessageRole.user;
    }
  }
}

/// 单条聊天消息
class ChatMessage {
  final String id;
  final ChatMessageRole role;
  final String content;
  final List<String> imagePaths;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.imagePaths = const [],
    required this.createdAt,
  });

  /// 从 JSON Map 创建
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: ChatMessageRole.fromString(json['role'] as String),
      content: json['content'] as String,
      imagePaths: (json['imagePaths'] as List?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 转为 JSON Map
  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.toKey(),
        'content': content,
        if (imagePaths.isNotEmpty) 'imagePaths': imagePaths,
        'createdAt': createdAt.toIso8601String(),
      };
}

// ==================== 会话模型 ====================

/// 聊天会话
///
/// 包含会话标题、消息列表和时间戳。会话数据仅保存在本地，
/// 不写入数据库，不参与云同步与备份。
class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 JSON Map 创建
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 转为 JSON Map
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// 复制并修改部分字段
  ChatSession copyWith({
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ==================== 导入导出格式 ====================

/// 会话导出文件格式
class ChatSessionsExport {
  final int version;
  final String exportedAt;
  final List<ChatSession> sessions;

  const ChatSessionsExport({
    this.version = 1,
    required this.exportedAt,
    required this.sessions,
  });

  /// 从 JSON 字符串导入
  factory ChatSessionsExport.fromJsonString(String jsonText) {
    final data = json.decode(jsonText) as Map<String, dynamic>;
    final sessionsList = (data['sessions'] ?? data) as List;
    return ChatSessionsExport(
      version: data['version'] as int? ?? 1,
      exportedAt: data['exportedAt'] as String? ?? '',
      sessions: sessionsList
          .map((s) => ChatSession.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 导出为 JSON 字符串
  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert({
      'version': version,
      'exportedAt': exportedAt,
      'sessions': sessions.map((s) => s.toJson()).toList(),
    });
  }
}
