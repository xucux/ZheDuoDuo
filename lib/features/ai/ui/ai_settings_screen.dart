// AI 设置页面
//
// 支持配置：
// - 服务商快速选择（DeepSeek、硅基流动、OpenAI、Claude、自定义）
// - 协议选择（OpenAI 兼容 / Claude 协议）
// - API Key（明文保存至数据库 Secrets 表）
// - Base URL（可选，支持第三方代理）
// - 模型名称
// - Agent 角色选择（默认助手、购物参谋、YAML 解析器）
// - Temperature 和 Max Tokens 参数
// - 图片解析提示词编辑
// 所有配置保存在本地数据库中，API Key 等密钥明文存储在 Secrets 表。

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/theme/antd_colors.dart';
import '../../../shared/theme/theme_provider.dart';
import '../models/ai_chat_models.dart';

/// 默认 AI 提示词：图片商品信息解析
const _defaultAiPrompt = '''你是一个专业的电商图片解析引擎。

## 任务
分析输入图片中的所有商品信息，并严格按照指定 YAML 格式输出。

输出内容必须来源于图片中的可见信息，不允许编造数据。

---

## 字段映射规则

| 图片信息 | YAML路径 |
|---------|---------|
| 商品名称 | product.title |
| 到手价 | prices.discounted_price |
| 原价 | prices.original_price |
| 展示价/活动价 | prices.current_display_price |
| 平台 | source.platform |
| 物流 | source.logistics |
| 商品分类 | product.category |
| 商品链接 | source.link |
| 标签 | tags[] |
| 促销权益 | promotions[] |
| 优惠券 | coupons[] |
| 30天销量 | sales.sold_30_days |
| 备注 | note |''';

class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  /// AI 对话设置
  AiChatSettings _settings = const AiChatSettings();

  /// 图片解析提示词
  String _promptPrefix = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 从数据库加载 AI 配置
  Future<void> _loadData() async {
    final aiConfigDao = ref.read(aiConfigDaoProvider);
    final secretsDao = ref.read(secretsDaoProvider);

    // 确保至少有一个默认配置
    final config = await aiConfigDao.ensureDefaultConfig();

    // 从 Secrets 表加载 API Key
    final apiKey = await secretsDao.getValue('ai', 'api_key') ?? '';

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
    });

    // 加载图片解析提示词
    final prompt = await secretsDao.getValue('ai', 'prompt_prefix') ?? '';
    setState(() => _promptPrefix = prompt);
  }

  /// 保存对话配置到数据库
  Future<void> _saveChatSettings() async {
    final aiConfigDao = ref.read(aiConfigDaoProvider);
    final secretsDao = ref.read(secretsDaoProvider);
    final now = DateTime.now();

    // 保存 AI 配置到 AiConfigs 表
    await aiConfigDao.saveConfig(AiConfigsCompanion(
      id: const Value('default'),
      providerPreset: Value(_settings.providerPreset),
      protocol: Value(_settings.protocol.toKey()),
      baseUrl: Value(_settings.baseUrl),
      model: Value(_settings.model),
      agentRole: Value(_settings.agentId),
      agentPrompt: Value(AiAgent.findById(_settings.agentId)?.prompt ?? ''),
      temperature: Value(_settings.temperature),
      maxTokens: Value(_settings.maxTokens),
      isActive: const Value(1),
      updatedAt: Value(now),
      createdAt: Value(now),
    ));

    // 保存 API Key 到 Secrets 表
    await secretsDao.setValue('ai', 'api_key', _settings.apiKey, entityId: 'default');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 对话配置已保存')),
      );
    }
  }

  /// 保存提示词到数据库
  Future<void> _savePrompt() async {
    final secretsDao = ref.read(secretsDaoProvider);
    await secretsDao.setValue('ai', 'prompt_prefix', _promptPrefix, entityId: 'default');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AI 设置')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ====== 图片解析提示词 ======
          _buildSectionHeader(context, '图片解析提示词'),
          _buildPromptSection(context, theme),
          const Divider(height: 24),

          // ====== AI 对话配置 ======
          _buildSectionHeader(context, 'AI 对话配置'),

          // 服务商快速选择
          _buildSubHeader(context, '服务商'),
          _buildProviderPresets(context, theme),
          const SizedBox(height: 12),

          // 协议选择
          _buildSubHeader(context, '协议'),
          _buildProtocolSelector(context, theme),
          const SizedBox(height: 12),

          // API Key
          _buildSubHeader(context, 'API Key'),
          _buildApiKeyField(context, theme),
          const SizedBox(height: 12),

          // Base URL
          _buildSubHeader(context, 'Base URL（可选）'),
          _buildBaseUrlField(context, theme),
          const SizedBox(height: 12),

          // 模型
          _buildSubHeader(context, '模型'),
          _buildModelField(context, theme),
          const SizedBox(height: 12),

          // Agent 角色
          _buildSubHeader(context, 'Agent 角色'),
          _buildAgentSelector(context, theme),
          const SizedBox(height: 12),

          // Temperature
          _buildTemperatureSlider(context, theme),
          const SizedBox(height: 12),

          // Max Tokens
          _buildSubHeader(context, 'Max Tokens'),
          _buildMaxTokensField(context, theme),
          const SizedBox(height: 16),

          // 保存对话配置按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              onPressed: _saveChatSettings,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                backgroundColor: AntdColors.primary,
              ),
              child: const Text('保存对话配置'),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 分区标题构建 ====================

  /// 构建一级分区标题
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// 构建二级子标题
  Widget _buildSubHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  // ==================== 服务商预设 ====================

  /// 构建服务商快速选择网格
  Widget _buildProviderPresets(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: AiProviderPreset.builtIn.map((preset) {
          final isSelected = _settings.providerPreset == preset.id;
          return GestureDetector(
            onTap: () {
              setState(() {
                _settings = _settings.applyPreset(preset.id);
              });
            },
            child: Container(
              width: (MediaQuery.of(context).size.width - 48) / 3,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AntdColors.primaryBg : theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AntdColors.primary : theme.colorScheme.outlineVariant,
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    preset.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AntdColors.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preset.model.isEmpty ? '自定义' : preset.model,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== 协议选择 ====================

  /// 构建协议选择按钮组
  Widget _buildProtocolSelector(BuildContext context, ThemeData theme) {
    const protocols = [
      (protocol: AiProtocol.openaiResponses, label: 'OpenAI Responses', desc: '/v1/responses'),
      (protocol: AiProtocol.openaiChat, label: 'OpenAI Chat', desc: '/v1/chat/completions'),
      (protocol: AiProtocol.anthropic, label: 'Anthropic', desc: 'Messages API'),
      (protocol: AiProtocol.githubCopilot, label: 'GitHub Copilot', desc: 'Copilot API'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: protocols.map((item) {
          final isSelected = _settings.protocol == item.protocol;
          return GestureDetector(
            onTap: () {
              setState(() {
                _settings = _settings.copyWith(protocol: item.protocol);
              });
            },
            child: Container(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AntdColors.primaryBg : theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AntdColors.primary : theme.colorScheme.outlineVariant,
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AntdColors.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.desc,
                    style: TextStyle(fontSize: 9, color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== 输入字段 ====================

  /// 构建 API Key 输入框
  Widget _buildApiKeyField(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextFormField(
            initialValue: _settings.apiKey,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'sk-...',
              prefixIcon: Icon(Icons.key, size: 18),
            ),
            onChanged: (v) => _settings = _settings.copyWith(apiKey: v),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '仅保存在本地 SharedPreferences，不会上传',
              style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建 Base URL 输入框
  Widget _buildBaseUrlField(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextFormField(
            initialValue: _settings.baseUrl,
            decoration: const InputDecoration(
              hintText: 'https://api.openai.com/v1',
              prefixIcon: Icon(Icons.link, size: 18),
            ),
            onChanged: (v) => _settings = _settings.copyWith(baseUrl: v),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '留空使用官方地址；支持第三方代理',
              style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建模型名称输入框
  Widget _buildModelField(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        initialValue: _settings.model,
        decoration: const InputDecoration(
          hintText: 'gpt-4o / claude-3-5-sonnet',
          prefixIcon: Icon(Icons.psychology, size: 18),
        ),
        onChanged: (v) => _settings = _settings.copyWith(model: v),
      ),
    );
  }

  /// 构建 Max Tokens 输入框
  Widget _buildMaxTokensField(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        initialValue: _settings.maxTokens.toString(),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: '2048',
          prefixIcon: Icon(Icons.data_array, size: 18),
        ),
        onChanged: (v) {
          final val = int.tryParse(v);
          if (val != null) _settings = _settings.copyWith(maxTokens: val);
        },
      ),
    );
  }

  // ==================== Agent 角色 ====================

  /// 构建 Agent 角色选择器
  Widget _buildAgentSelector(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AiAgent.builtIn.map((agent) {
              final isSelected = _settings.agentId == agent.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _settings = _settings.copyWith(agentId: agent.id);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AntdColors.primary : theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AntdColors.primary : theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    agent.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            AiAgent.findById(_settings.agentId)?.prompt ?? '',
            style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  // ==================== Temperature 滑块 ====================

  /// 构建 Temperature 滑块
  Widget _buildTemperatureSlider(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Temperature',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                _settings.temperature.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Slider(
            value: _settings.temperature,
            min: 0,
            max: 2,
            divisions: 20,
            activeColor: AntdColors.primary,
            onChanged: (v) {
              setState(() {
                _settings = _settings.copyWith(temperature: v);
              });
            },
          ),
        ],
      ),
    );
  }

  // ==================== 提示词编辑 ====================

  /// 构建提示词编辑区
  Widget _buildPromptSection(BuildContext context, ThemeData theme) {
    final hasPrompt = _promptPrefix.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.text_snippet_outlined,
                        size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      '当前提示词',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (hasPrompt)
                      TextButton(
                        onPressed: () => _copyPrompt(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('复制', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  hasPrompt ? _promptPrefix : '未设置（使用默认提示词）',
                  style: TextStyle(
                    fontSize: 13,
                    color: hasPrompt
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.outline,
                    height: 1.5,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editPrompt(context),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('编辑提示词'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _resetPrompt(context),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('恢复默认'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '提示词前缀会在 AI 页面一键复制，粘贴到聊天框后发送商品图片即可解析。',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline, height: 1.4),
          ),
        ),
      ],
    );
  }

  // ==================== 提示词操作 ====================

  /// 复制提示词到剪贴板
  void _copyPrompt(BuildContext context) {
    final text = _promptPrefix.isNotEmpty ? _promptPrefix : _defaultAiPrompt;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('提示词已复制到剪贴板')),
    );
  }

  /// 编辑提示词弹窗
  void _editPrompt(BuildContext context) {
    final controller = TextEditingController(text: _promptPrefix);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑提示词前缀'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 12,
            decoration: const InputDecoration(
              hintText: '输入 AI 提示词前缀...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _promptPrefix = controller.text);
              _savePrompt();
              Navigator.pop(ctx);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 恢复默认提示词
  void _resetPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复默认提示词'),
        content: const Text('确定要恢复为默认提示词吗？当前自定义内容将被替换。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _promptPrefix = _defaultAiPrompt);
              _savePrompt();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已恢复默认提示词')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
