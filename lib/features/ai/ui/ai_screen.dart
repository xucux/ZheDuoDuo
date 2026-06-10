// AI 对话页面
//
// 改造为对话窗口 UI，支持：
// - 消息气泡展示（用户/AI）
// - 历史会话切换
// - 新建/删除会话
// - 模拟发送消息（原型演示）
// - AI 配置从数据库加载，会话数据保存在 SharedPreferences

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/theme/antd_colors.dart';
import '../../../shared/theme/theme_provider.dart';
import '../models/ai_chat_models.dart';
import '../services/ai_chat_service.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  /// 当前选中的会话 ID
  String _currentSessionId = '';

  /// 会话列表
  List<ChatSession> _sessions = [];

  /// 输入框控制器
  final _inputController = TextEditingController();

  /// 滚动控制器
  final _scrollController = ScrollController();

  /// 是否正在发送消息
  bool _sending = false;

  /// 是否显示历史会话面板
  bool _showHistory = false;

  /// AI 对话设置
  AiChatSettings _settings = const AiChatSettings();

  /// 图片选择器
  final _imagePicker = ImagePicker();

  /// 已选择的待发送图片路径列表
  final List<String> _pendingImages = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 从数据库和 SharedPreferences 加载会话和设置
  Future<void> _loadData() async {
    // 从数据库加载 AI 配置
    final aiConfigDao = ref.read(aiConfigDaoProvider);
    final secretsDao = ref.read(secretsDaoProvider);
    final config = await aiConfigDao.ensureDefaultConfig();
    final apiKey = await secretsDao.getValue('ai', 'api_key') ?? '';

    // 从 SharedPreferences 加载会话数据
    final prefs = await SharedPreferences.getInstance();
    final sessionService = AiChatSessionService(prefs);

    final sessions = sessionService.loadSessions();

    setState(() {
      _settings = AiChatSettings(
        providerPreset: config.providerPreset,
        protocol: AiProtocol.fromString(config.protocol),
        apiKey: apiKey,
        baseUrl: config.baseUrl,
        model: config.model,
        agentId: config.agentRole,
        temperature: config.temperature,
        maxTokens: config.maxTokens,
      );
      _sessions = sessions;
      // 若无会话则自动创建一个
      if (_sessions.isEmpty) {
        final s = sessionService.createSession();
        _sessions = [s];
      }
      _currentSessionId = _sessions.first.id;
    });
  }

  /// 获取当前会话
  ChatSession? get _currentSession {
    for (final s in _sessions) {
      if (s.id == _currentSessionId) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = _currentSession;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏
            _buildTopBar(context, theme),

            // 历史会话面板（展开时）
            if (_showHistory) _buildHistoryPanel(context, theme),

            // 消息列表
            Expanded(
              child: session == null || session.messages.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildMessageList(context, theme, session),
            ),

            // 输入区
            _buildInputArea(context, theme),
          ],
        ),
      ),
    );
  }

  /// 构建顶部栏
  Widget _buildTopBar(BuildContext context, ThemeData theme) {
    final session = _currentSession;
    final protocolLabel = switch (_settings.protocol) {
      AiProtocol.openaiResponses => 'OpenAI Responses',
      AiProtocol.openaiChat => 'OpenAI Chat',
      AiProtocol.anthropic => 'Anthropic',
      AiProtocol.githubCopilot => 'GitHub Copilot',
    };
    final modelLabel =
        _settings.model.isNotEmpty ? '· ${_settings.model}' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // 历史会话按钮
          IconButton(
            onPressed: () => setState(() => _showHistory = !_showHistory),
            icon: Icon(
              Icons.history,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            tooltip: '历史会话',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          // 标题和协议信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session?.title ?? 'AI 对话',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$protocolLabel$modelLabel',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          // 新建对话
          IconButton(
            onPressed: _startNewChat,
            icon: Icon(
              Icons.add,
              size: 20,
              color: AntdColors.primary,
            ),
            tooltip: '新对话',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
          // 设置入口
          IconButton(
            onPressed: () => context.push('/profile/ai-settings'),
            icon: Icon(
              Icons.tune,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            tooltip: 'AI 设置',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  /// 构建历史会话面板
  Widget _buildHistoryPanel(BuildContext context, ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Icon(Icons.history, size: 12, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  '历史会话',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _exportSessions,
                  child: Text(
                    '导出',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AntdColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 会话列表
          Expanded(
            child: _sessions.isEmpty
                ? Center(
                    child: Text(
                      '暂无会话',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    itemCount: _sessions.length,
                    itemBuilder: (ctx, idx) {
                      final s = _sessions[idx];
                      final isSelected = s.id == _currentSessionId;
                      return _buildSessionTile(context, theme, s, isSelected);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 构建单个会话条目
  Widget _buildSessionTile(
    BuildContext context,
    ThemeData theme,
    ChatSession session,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSessionId = session.id;
          _showHistory = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AntdColors.primaryBg
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AntdColors.primaryBorder
                : theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? AntdColors.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 14,
                color: isSelected ? Colors.white : theme.colorScheme.outline,
              ),
            ),
            const SizedBox(width: 8),
            // 标题和副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AntdColors.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${session.messages.length} 条 · ${_formatDateTime(session.updatedAt)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            // 删除按钮
            GestureDetector(
              onTap: () => _deleteSession(session.id),
              child: Icon(
                Icons.delete_outline,
                size: 16,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态（无消息时）
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AntdColors.primaryBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              size: 28,
              color: AntdColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '开始对话',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '输入问题，AI 将基于你配置的协议回复',
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建消息列表
  Widget _buildMessageList(
    BuildContext context,
    ThemeData theme,
    ChatSession session,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: session.messages.length + (_sending ? 1 : 0),
      itemBuilder: (ctx, idx) {
        // 正在发送时显示加载指示器
        if (idx == session.messages.length) {
          return _buildTypingIndicator(theme);
        }
        final msg = session.messages[idx];
        return _buildMessageBubble(context, theme, msg);
      },
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble(
    BuildContext context,
    ThemeData theme,
    ChatMessage msg,
  ) {
    final isUser = msg.role == ChatMessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? AntdColors.primary : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: isUser
                    ? const Radius.circular(14)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(14),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 图片（如果有）
                if (msg.imagePaths.isNotEmpty) ...[
                  ...msg.imagePaths.map((path) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 160,
                        errorBuilder: (_, __, ___) => Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.white.withValues(alpha: 0.2)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(Icons.broken_image_outlined,
                                color: theme.colorScheme.outline),
                          ),
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: 4),
                ],
                // 消息内容
                if (msg.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      msg.content,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isUser ? Colors.white : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                // 时间戳
                Text(
                  _formatTime(msg.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.6)
                        : theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建"正在输入"指示器
  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(theme, 0),
              const SizedBox(width: 4),
              _buildDot(theme, 150),
              const SizedBox(width: 4),
              _buildDot(theme, 300),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建跳动圆点
  Widget _buildDot(ThemeData theme, int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (ctx, value, child) {
        return Opacity(
          opacity: 0.4 + (value * 0.6),
          child: child,
        );
      },
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// 构建输入区
  Widget _buildInputArea(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 待发送图片预览
          if (_pendingImages.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 4),
                itemCount: _pendingImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (ctx, idx) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_pendingImages[idx]),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () => setState(() => _pendingImages.removeAt(idx)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 图片选择按钮
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: _pickImage,
                  icon: Icon(
                    Icons.image_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // 输入框
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: TextField(
                    controller: _inputController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: '输入消息…',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.outline,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AntdColors.primary),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLow,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // 发送按钮
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton.filled(
                  onPressed: (_sending || (_inputController.text.trim().isEmpty && _pendingImages.isEmpty))
                      ? null
                      : _sendMessage,
                  icon: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, size: 16),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: AntdColors.primary,
                    disabledBackgroundColor:
                        AntdColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 隐私提示
          Text(
            '数据仅保存在本地，不会上传至云端或备份',
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  /// 选择图片
  Future<void> _pickImage() async {
    final xFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (xFile != null) {
      setState(() => _pendingImages.add(xFile.path));
    }
  }

  /// 压缩图片并返回 base64 字符串
  Future<String> _compressAndEncode(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();

    final compressedBytes = await FlutterImageCompressPlatform.instance.compressWithList(
      bytes,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );

    final mimeType = _getMimeType(imagePath);
    return 'data:$mimeType;base64,${base64Encode(compressedBytes)}';
  }

  /// 根据文件扩展名获取 MIME 类型
  String _getMimeType(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.png')) return 'image/png';
    if (ext.endsWith('.webp')) return 'image/webp';
    if (ext.endsWith('.gif')) return 'image/gif';
    if (ext.endsWith('.bmp')) return 'image/bmp';
    return 'image/jpeg';
  }

  // ==================== 操作方法 ====================

  /// 发送消息
  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if ((text.isEmpty && _pendingImages.isEmpty) || _sending) return;

    final sessionService = AiChatSessionService(await _getPrefs());

    // 确保有当前会话
    if (_currentSessionId.isEmpty) {
      final s = sessionService.createSession();
      setState(() {
        _currentSessionId = s.id;
        _sessions = sessionService.loadSessions();
      });
    }

    // 添加用户消息（含图片路径）
    final imagePaths = List<String>.from(_pendingImages);
    sessionService.addMessage(
      _currentSessionId,
      ChatMessageRole.user,
      text,
      imagePaths: imagePaths,
    );
    _inputController.clear();
    _pendingImages.clear();
    setState(() {
      _sessions = sessionService.loadSessions();
      _sending = true;
    });
    _scrollToBottom();

    // 模拟 AI 回复（原型演示）
    await Future.delayed(Duration(milliseconds: 600 + DateTime.now().millisecond % 800));
    const replies = [
      '收到，这是一个模拟回复。正式版本将调用你配置的 API 进行真实对话。',
      '好的，我理解了。当前为原型演示，未接入真实 AI 服务。',
      '这是一个占位回复。你可以在 AI 设置中配置 OpenAI 兼容或 Claude 协议的 API Key。',
      '（模拟）根据你的描述，建议关注优惠券叠加和满减活动。',
    ];
    final reply = replies[DateTime.now().millisecond % replies.length];

    sessionService.addMessage(_currentSessionId, ChatMessageRole.assistant, reply);
    setState(() {
      _sessions = sessionService.loadSessions();
      _sending = false;
    });
    _scrollToBottom();
  }

  /// 新建对话
  Future<void> _startNewChat() async {
    final sessionService = AiChatSessionService(await _getPrefs());
    final s = sessionService.createSession();
    setState(() {
      _sessions = sessionService.loadSessions();
      _currentSessionId = s.id;
      _showHistory = false;
    });
  }

  /// 删除会话
  Future<void> _deleteSession(String sessionId) async {
    final sessionService = AiChatSessionService(await _getPrefs());
    await sessionService.deleteSession(sessionId);
    setState(() {
      _sessions = sessionService.loadSessions();
      if (_currentSessionId == sessionId) {
        _currentSessionId = _sessions.isNotEmpty ? _sessions.first.id : '';
      }
    });
    if (_currentSessionId.isEmpty) {
      _startNewChat();
    }
  }

  /// 导出会话
  Future<void> _exportSessions() async {
    final sessionService = AiChatSessionService(await _getPrefs());
    final json = sessionService.exportToJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('会话数据已复制到剪贴板')),
      );
    }
  }

  /// 滚动到底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ==================== 工具方法 ====================

  /// 格式化时间（HH:mm）
  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化日期时间（YYYY-MM-DD HH:mm）
  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// 获取 SharedPreferences 实例
  Future<SharedPreferences> _getPrefs() async {
    // 使用 shared_preferences 包
    // 这里暂时用简单方式获取
    return SharedPreferences.getInstance();
  }
}
