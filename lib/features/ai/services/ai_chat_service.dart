// AI 对话服务层
//
// 负责 AI 对话设置和会话数据的本地持久化。
// 所有数据仅保存在 SharedPreferences 中，不写入数据库，不参与云同步与备份。

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai_chat_models.dart';

// ==================== 存储键名常量 ====================

/// AI 对话设置的 SharedPreferences 键
const _kChatSettings = 'zdd_ai_chat_settings';

/// AI 会话列表的 SharedPreferences 键
const _kChatSessions = 'zdd_ai_chat_sessions';



// ==================== 对话设置服务 ====================

/// AI 对话设置服务
///
/// 管理协议、API Key、Base URL、模型、Agent 等配置的读写。
class AiChatSettingsService {
  final SharedPreferences _prefs;

  AiChatSettingsService(this._prefs);

  /// 加载对话设置，若不存在则返回默认值
  AiChatSettings load() {
    final raw = _prefs.getString(_kChatSettings);
    if (raw == null) return const AiChatSettings();
    try {
      return AiChatSettings.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const AiChatSettings();
    }
  }

  /// 保存对话设置
  Future<bool> save(AiChatSettings settings) {
    return _prefs.setString(_kChatSettings, json.encode(settings.toJson()));
  }

}

// ==================== 会话存储服务 ====================

/// AI 会话存储服务
///
/// 管理聊天会话的增删改查，数据仅保存在本地 SharedPreferences。
/// 不写入数据库，不参与云同步与备份。
class AiChatSessionService {
  final SharedPreferences _prefs;

  AiChatSessionService(this._prefs);

  /// 加载所有会话
  List<ChatSession> loadSessions() {
    final raw = _prefs.getString(_kChatSessions);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List;
      return list
          .map((s) => ChatSession.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 保存所有会话
  Future<bool> _saveAll(List<ChatSession> sessions) {
    return _prefs.setString(
      _kChatSessions,
      json.encode(sessions.map((s) => s.toJson()).toList()),
    );
  }

  /// 创建新会话
  ChatSession createSession({String title = '新对话'}) {
    final sessions = loadSessions();
    final session = ChatSession(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    sessions.insert(0, session);
    _saveAll(sessions);
    return session;
  }

  /// 获取单个会话
  ChatSession? getSession(String sessionId) {
    final sessions = loadSessions();
    for (final s in sessions) {
      if (s.id == sessionId) return s;
    }
    return null;
  }

  /// 添加消息到会话
  ///
  /// [role] 消息角色（user/assistant）
  /// [content] 消息内容
  /// [imagePaths] 附带的图片本地路径（可选）
  /// 若是第一条用户消息，自动截取前 20 字作为会话标题。
  ChatSession? addMessage(
    String sessionId,
    ChatMessageRole role,
    String content, {
    String? reasoningContent,
    List<String> imagePaths = const [],
  }) {
    final sessions = loadSessions();
    final idx = sessions.indexWhere((s) => s.id == sessionId);
    if (idx == -1) return null;

    final msg = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      role: role,
      content: content,
      reasoningContent: reasoningContent,
      imagePaths: imagePaths,
      createdAt: DateTime.now(),
    );

    final updatedMessages = [...sessions[idx].messages, msg];
    var updatedTitle = sessions[idx].title;

    // 第一条用户消息自动生成标题
    if (updatedMessages.length == 1 && role == ChatMessageRole.user) {
      final titleSource = content.isNotEmpty ? content : (imagePaths.isNotEmpty ? '[图片]' : '');
      updatedTitle = titleSource.length > 20 ? titleSource.substring(0, 20) : titleSource;
    }

    sessions[idx] = sessions[idx].copyWith(
      title: updatedTitle,
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
    _saveAll(sessions);
    return sessions[idx];
  }

  /// 删除会话中的单条消息
  Future<bool> deleteMessage(String sessionId, String messageId) async {
    final sessions = loadSessions();
    final idx = sessions.indexWhere((s) => s.id == sessionId);
    if (idx == -1) return false;

    final messages = List<ChatMessage>.from(sessions[idx].messages);
    messages.removeWhere((m) => m.id == messageId);
    sessions[idx] = sessions[idx].copyWith(
      messages: messages,
      updatedAt: DateTime.now(),
    );
    return _saveAll(sessions);
  }

  /// 删除会话
  Future<bool> deleteSession(String sessionId) {
    final sessions = loadSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    return _saveAll(sessions);
  }

  /// 清除所有会话
  Future<bool> clearAll() {
    return _prefs.remove(_kChatSessions);
  }

  /// 导出所有会话为 JSON 字符串
  String exportToJson() {
    final sessions = loadSessions();
    final export = ChatSessionsExport(
      exportedAt: DateTime.now().toIso8601String(),
      sessions: sessions,
    );
    return export.toJsonString();
  }

  /// 从 JSON 字符串导入会话（覆盖现有数据）
  List<ChatSession> importFromJson(String jsonText) {
    final export = ChatSessionsExport.fromJsonString(jsonText);
    _saveAll(export.sessions);
    return export.sessions;
  }
}

// ==================== Riverpod Provider ====================

/// SharedPreferences 实例 Provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

/// AI 对话设置服务 Provider
final aiChatSettingsServiceProvider = FutureProvider<AiChatSettingsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) throw StateError('SharedPreferences not initialized');
  return AiChatSettingsService(prefs);
});

/// AI 会话存储服务 Provider
final aiChatSessionServiceProvider = FutureProvider<AiChatSessionService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) throw StateError('SharedPreferences not initialized');
  return AiChatSessionService(prefs);
});

/// AI 对话设置 Provider（响应式）
final aiChatSettingsProvider = FutureProvider<AiChatSettings>((ref) async {
  final service = ref.watch(aiChatSettingsServiceProvider).value;
  if (service == null) return const AiChatSettings();
  return service.load();
});

/// AI 会话列表 Provider（响应式）
final aiChatSessionsProvider = FutureProvider<List<ChatSession>>((ref) async {
  final service = ref.watch(aiChatSessionServiceProvider).value;
  if (service == null) return [];
  return service.loadSessions();
});
