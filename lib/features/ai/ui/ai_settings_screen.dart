// AI 设置页面
//
// 支持管理多个服务商配置（添加/编辑/删除/激活），
// 内置预设作为快速填充模板。
// 所有数据保存至数据库 AiConfigs 表，API Key 存储在 Secrets 表。
// 同一时间只能激活一个服务商。

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/theme/antd_colors.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../mcp/providers/mcp_provider.dart';
import '../models/ai_chat_models.dart';

class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  /// 所有服务商配置列表
  List<AiProviderConfig> _configs = [];

  /// 当前选中的（正在编辑的）配置 ID
  String? _editingConfigId;

  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _modelController;
  late TextEditingController _maxTokensController;
  late TextEditingController _nameController;
  bool _apiKeyVisible = false;

  /// 当前编辑配置的 capabilities
  List<String> _capabilities = ['text'];

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _baseUrlController = TextEditingController();
    _modelController = TextEditingController();
    _maxTokensController = TextEditingController();
    _nameController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _maxTokensController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// 从数据库加载所有配置
  Future<void> _loadData() async {
    final aiConfigDao = ref.read(aiConfigDaoProvider);
    final secretsDao = ref.read(secretsDaoProvider);

    await aiConfigDao.ensureDefaultConfig();
    final configs = await aiConfigDao.getAllConfigs();

    final result = <AiProviderConfig>[];
    for (final c in configs) {
      final apiKey = await secretsDao.getValue('ai', 'api_key', entityId: c.id) ?? '';
      result.add(_toAiProviderConfig(c, apiKey));
    }

    setState(() {
      _configs = result;
      _editingConfigId = _configs.where((c) => c.isActive).firstOrNull?.id
          ?? _configs.firstOrNull?.id;
      _syncEditingControllers();
    });
  }

  /// 将数据库行转为 UI 模型
  AiProviderConfig _toAiProviderConfig(AiConfig row, String apiKey) {
    final preset = AiProviderPreset.findById(row.providerPreset);
    List<String> caps;
    try {
      final decoded = jsonDecode(row.capabilities);
      if (decoded is List) {
        caps = decoded.whereType<String>().toList();
      } else {
        caps = preset?.capabilities ?? ['text'];
      }
    } catch (_) {
      caps = preset?.capabilities ?? ['text'];
    }
    return AiProviderConfig(
      id: row.id,
      name: preset?.name ?? row.providerPreset,
      protocol: AiProtocol.fromString(row.protocol),
      apiKey: apiKey,
      baseUrl: row.baseUrl,
      model: row.model,
      agentId: row.agentRole,
      temperature: row.temperature,
      maxTokens: row.maxTokens,
      capabilities: caps,
      isActive: row.isActive == 1,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// 获取当前正在编辑的配置
  AiProviderConfig? get _editingConfig {
    if (_editingConfigId == null) return null;
    for (final c in _configs) {
      if (c.id == _editingConfigId) return c;
    }
    return null;
  }

  /// 同步控制器到当前编辑的配置
  void _syncEditingControllers() {
    final config = _editingConfig;
    if (config == null) {
      _apiKeyController.text = '';
      _baseUrlController.text = '';
      _modelController.text = '';
      _maxTokensController.text = '';
      _nameController.text = '';
      _capabilities = ['text'];
      return;
    }
    _apiKeyController.text = config.apiKey;
    _baseUrlController.text = config.baseUrl;
    _modelController.text = config.model;
    _maxTokensController.text = config.maxTokens.toString();
    _nameController.text = config.name;
    _capabilities = List<String>.from(config.capabilities);
  }

  /// 激活指定配置
  Future<void> _activateConfig(String id) async {
    final aiConfigDao = ref.read(aiConfigDaoProvider);
    await aiConfigDao.activateConfig(id);
    setState(() {
      _configs = _configs.map((c) => c.copyWith(isActive: c.id == id)).toList();
      _editingConfigId = id;
      _syncEditingControllers();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已切换服务商')),
      );
    }
  }

  /// 删除指定配置
  Future<void> _deleteConfig(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除服务商'),
        content: const Text('确定要删除此服务商配置吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
        ],
      ),
    );
    if (confirmed != true) return;

    final aiConfigDao = ref.read(aiConfigDaoProvider);
    await aiConfigDao.deleteConfig(id);
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('服务商已删除')),
      );
    }
  }

  /// 保存当前编辑的配置
  Future<void> _saveEditingConfig() async {
    final config = _editingConfig;
    if (config == null) return;

    final aiConfigDao = ref.read(aiConfigDaoProvider);
    final secretsDao = ref.read(secretsDaoProvider);
    final now = DateTime.now();

    await aiConfigDao.saveConfig(AiConfigsCompanion(
      id: Value(config.id),
      providerPreset: Value(_nameController.text),
      protocol: Value(config.protocol.toKey()),
      apiKey: const Value(''),
      baseUrl: Value(_baseUrlController.text),
      model: Value(_modelController.text),
      agentRole: Value(config.agentId),
      agentPrompt: Value(AiAgent.findById(config.agentId)?.prompt ?? ''),
      temperature: Value(config.temperature),
      maxTokens: Value(int.tryParse(_maxTokensController.text) ?? config.maxTokens),
      capabilities: Value(jsonEncode(_capabilities)),
      isActive: Value(config.isActive ? 1 : 0),
      updatedAt: Value(now),
      createdAt: Value(config.createdAt),
    ));

    // API Key 单独保存到 Secrets 表
    await secretsDao.setValue('ai', 'api_key', _apiKeyController.text, entityId: config.id);

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('服务商配置已保存')),
      );
    }
  }

  /// 从远程 API 拉取模型列表
  ///
  /// [onSelected] 选中模型后的回调，若不传则默认设置到 [_modelController]。
  Future<void> _fetchModels({
    required String baseUrl,
    required String apiKey,
    required AiProtocol protocol,
    ValueChanged<String>? onSelected,
  }) async {
    if (baseUrl.isEmpty || apiKey.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先填写 Base URL 和 API Key')),
      );
      return;
    }

    final url = switch (protocol) {
      AiProtocol.anthropic => '', // Anthropic 无公开模型列表接口
      _ => '${baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl}/models',
    };

    if (url.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('当前协议不支持拉取模型列表')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      final data = response.data;
      List<String> models = [];

      if (data is Map && data['data'] is List) {
        models = (data['data'] as List)
            .whereType<Map>()
            .map((m) => (m['id'] ?? '').toString())
            .where((id) => id.isNotEmpty)
            .toList();
      }

      if (models.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未获取到模型列表')),
        );
        return;
      }

      models.sort();

      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (sheetCtx) {
          final searchCtrl = TextEditingController();
          var filtered = models;
          return StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: '搜索模型…',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (v) {
                        setSheetState(() {
                          filtered = v.isEmpty
                              ? models
                              : models.where((m) => m.toLowerCase().contains(v.toLowerCase())).toList();
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  SizedBox(
                    height: 300,
                    child: filtered.isEmpty
                        ? Center(
                            child: Text('无匹配模型',
                              style: TextStyle(color: Theme.of(ctx).colorScheme.outline)),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => Divider(height: 1,
                              indent: 16, color: Theme.of(ctx).colorScheme.outlineVariant),
                            itemBuilder: (ctx, i) {
                              return ListTile(
                                dense: true,
                                title: Text(filtered[i], style: const TextStyle(fontSize: 13)),
                                onTap: () {
                                  if (onSelected != null) {
                                    onSelected(filtered[i]);
                                  } else {
                                    setState(() {
                                      _modelController.text = filtered[i];
                                    });
                                  }
                                  searchCtrl.dispose();
                                  Navigator.pop(sheetCtx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('拉取模型列表失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = _editingConfig;

    return Scaffold(
      appBar: AppBar(title: const Text('AI 设置')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ====== MCP 服务 ======
          _buildSectionHeader(context, 'MCP 工具服务'),
          _buildMcpToggle(context, theme),
          const Divider(height: 24),

          // ====== 服务商管理 ======
          _buildSectionHeader(context, '服务商管理'),
          _buildProviderList(context, theme),
          const SizedBox(height: 12),
          _buildAddProviderButton(context, theme),
          const Divider(height: 24),

          // ====== 当前服务商配置 ======
          if (editing != null) ...[
            _buildSectionHeader(context, 'AI 对话配置'),
            // 预设快速填充
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AiProviderPreset.builtIn
                    .where((p) => p.id != 'custom')
                    .map((preset) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _nameController.text = preset.name;
                        _baseUrlController.text = preset.baseUrl;
                        _modelController.text = preset.model;
                        _capabilities = List<String>.from(preset.capabilities);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AntdColors.primaryBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AntdColors.primary),
                      ),
                      child: Text(preset.name,
                        style: const TextStyle(fontSize: 11, color: AntdColors.primary)),
                    ),
                  );
                }).toList(),
              ),
            ),
            _buildSubHeader(context, '显示名称'),
            _buildNameField(context, theme),
            const SizedBox(height: 12),
            _buildSubHeader(context, '协议'),
            _buildProtocolSelector(context, theme, editing),
            const SizedBox(height: 12),
            _buildSubHeader(context, 'API Key'),
            _buildApiKeyField(context, theme),
            const SizedBox(height: 12),
            _buildSubHeader(context, 'Base URL（可选）'),
            _buildBaseUrlField(context, theme),
            const SizedBox(height: 12),
            _buildSubHeader(context, '模型'),
            _buildModelField(context, theme),
            const SizedBox(height: 12),
            _buildSubHeader(context, 'Agent 角色'),
            _buildAgentSelector(context, theme, editing),
            const SizedBox(height: 12),
            _buildTemperatureSlider(context, theme, editing),
            const SizedBox(height: 12),
            _buildSubHeader(context, 'Max Tokens'),
            _buildMaxTokensField(context, theme),
            const SizedBox(height: 12),
            _buildSubHeader(context, '模型能力'),
            _buildCapabilitiesEditor(context, theme),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: _saveEditingConfig,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  backgroundColor: AntdColors.primary,
                ),
                child: const Text('保存配置'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== 分区标题 ====================

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

  // ==================== MCP 服务开关 ====================

  Widget _buildMcpToggle(BuildContext context, ThemeData theme) {
    final mcpEnabled = ref.watch(mcpEnabledProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: SwitchListTile(
          secondary: Icon(
            Icons.cable,
            color: mcpEnabled ? theme.colorScheme.primary : theme.colorScheme.outline,
          ),
          title: const Text('启用 MCP 工具服务'),
          subtitle: Text(
            mcpEnabled ? 'AI 可通过 MCP 调用本地工具' : '关闭后 AI 无法调用工具',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
          ),
          value: mcpEnabled,
          onChanged: (v) => ref.read(mcpEnabledProvider.notifier).setEnabled(v),
        ),
      ),
    );
  }

  // ==================== 服务商列表 ====================

  Widget _buildProviderList(BuildContext context, ThemeData theme) {
    if (_configs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '暂无服务商配置',
          style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(_configs.length, (i) {
            final config = _configs[i];
            final isActive = config.isActive;
            final isEditing = config.id == _editingConfigId;

            return Column(
              children: [
                if (i > 0) Divider(height: 1, color: theme.colorScheme.outlineVariant),
                InkWell(
                  onTap: () {
                    if (!isActive) _activateConfig(config.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        // 激活指示器
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive ? AntdColors.primary : theme.colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: isActive
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AntdColors.primary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // 名称 + 模型
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                config.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isActive
                                      ? AntdColors.primary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  _buildProtocolBadge(context, config.protocol),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      config.model.isNotEmpty ? config.model : '未设置模型',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 编辑按钮
                        if (isEditing)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AntdColors.primaryBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '编辑中',
                              style: TextStyle(fontSize: 10, color: AntdColors.primary),
                            ),
                          )
                        else
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.outline),
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                _editingConfigId = config.id;
                                _syncEditingControllers();
                              });
                            },
                          ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          onPressed: () => _deleteConfig(config.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProtocolBadge(BuildContext context, AiProtocol protocol) {
    final label = switch (protocol) {
      AiProtocol.openaiResponses => 'Responses',
      AiProtocol.openaiChat => 'Chat',
      AiProtocol.anthropic => 'Claude',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AntdColors.primaryBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 9, color: AntdColors.primary, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ==================== 添加服务商 ====================

  Widget _buildAddProviderButton(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _showAddProviderSheet(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('添加服务商'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(40),
          side: BorderSide(color: AntdColors.primary),
        ),
      ),
    );
  }

  /// 显示添加服务商底部弹窗
  void _showAddProviderSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final apiKeyCtrl = TextEditingController();
    final baseUrlCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final maxTokensCtrl = TextEditingController(text: '4096');
    var protocol = AiProtocol.openaiChat;
    var agentId = 'default';
    var temperature = 0.7;
    var showApiKey = false;
    var sheetCapabilities = <String>['text'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 32, height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(ctx).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('添加服务商',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),

                    // 快速填充：内置预设
                    Text('快速填充',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: AiProviderPreset.builtIn
                          .where((p) => p.id != 'custom')
                          .map((preset) {
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              protocol = preset.protocol;
                              baseUrlCtrl.text = preset.baseUrl;
                              modelCtrl.text = preset.model;
                              nameCtrl.text = preset.name;
                              sheetCapabilities = List<String>.from(preset.capabilities);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AntdColors.primaryBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AntdColors.primary),
                            ),
                            child: Text(preset.name,
                              style: const TextStyle(fontSize: 12, color: AntdColors.primary)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 名称
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: '服务商名称',
                        hintText: '例如：我的代理',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 协议
                    Text('协议', style: TextStyle(fontSize: 12,
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    _buildCompactProtocolSelector(context, protocol, (p) {
                      setSheetState(() => protocol = p);
                    }),
                    const SizedBox(height: 12),

                    // API Key
                    TextField(
                      controller: apiKeyCtrl,
                      obscureText: !showApiKey,
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        labelText: 'API Key',
                        hintText: 'sk-...',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                            icon: const Icon(Icons.content_paste, size: 18),
                            tooltip: '粘贴',
                            onPressed: () async {
                              final data = await Clipboard.getData(Clipboard.kTextPlain);
                              if (data?.text != null) {
                                final text = apiKeyCtrl.text;
                                final sel = apiKeyCtrl.selection;
                                final newText = text.replaceRange(
                                  sel.isValid ? sel.start : text.length,
                                  sel.isValid ? sel.end : text.length,
                                  data!.text!,
                                );
                                apiKeyCtrl.text = newText;
                                apiKeyCtrl.selection = TextSelection.collapsed(
                                  offset: sel.isValid ? sel.start + data.text!.length : newText.length,
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(showApiKey ? Icons.visibility : Icons.visibility_off, size: 18),
                            tooltip: showApiKey ? '隐藏' : '显示',
                            onPressed: () => setSheetState(() => showApiKey = !showApiKey),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Base URL
                    TextField(
                      controller: baseUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Base URL',
                        hintText: 'https://api.openai.com/v1',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Model
                    TextField(
                      controller: modelCtrl,
                      decoration: InputDecoration(
                        labelText: '模型',
                        hintText: 'gpt-4o',
                        border: OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.cloud_sync_outlined, size: 18),
                          tooltip: '从远程拉取模型列表',
                          onPressed: () {
                            if (baseUrlCtrl.text.isEmpty || apiKeyCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('请先填写 Base URL 和 API Key')),
                              );
                              return;
                            }
                            _fetchModels(
                              baseUrl: baseUrlCtrl.text,
                              apiKey: apiKeyCtrl.text,
                              protocol: protocol,
                              onSelected: (model) {
                                setSheetState(() {
                                  modelCtrl.text = model;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Agent
                    Text('Agent 角色', style: TextStyle(fontSize: 12,
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: AiAgent.builtIn.map((agent) {
                        final sel = agentId == agent.id;
                        return GestureDetector(
                          onTap: () => setSheetState(() => agentId = agent.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: sel ? AntdColors.primary : Theme.of(ctx).colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: sel ? AntdColors.primary : Theme.of(ctx).colorScheme.outlineVariant),
                            ),
                            child: Text(agent.name,
                              style: TextStyle(fontSize: 11,
                                color: sel ? Colors.white : Theme.of(ctx).colorScheme.onSurfaceVariant)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Temperature
                    Row(children: [
                      Text('Temperature', style: TextStyle(fontSize: 12,
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                      const Spacer(),
                      Text(temperature.toStringAsFixed(1),
                        style: TextStyle(fontSize: 12,
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                    ]),
                    Slider(
                      value: temperature, min: 0, max: 2, divisions: 20,
                      activeColor: AntdColors.primary,
                      onChanged: (v) => setSheetState(() => temperature = v),
                    ),

                    // Max Tokens
                    TextField(
                      controller: maxTokensCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max Tokens',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Capabilities
                    Text('模型能力', style: TextStyle(fontSize: 12,
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _allCapabilities.map((cap) {
                        final isSelected = sheetCapabilities.contains(cap);
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              if (isSelected) {
                                if (sheetCapabilities.length > 1) {
                                  sheetCapabilities.remove(cap);
                                }
                              } else {
                                sheetCapabilities.add(cap);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected ? AntdColors.primary : Theme.of(ctx).colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AntdColors.primary : Theme.of(ctx).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(Icons.check, size: 12, color: Colors.white),
                                  ),
                                Text(
                                  _capabilityLabel(cap),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? Colors.white : Theme.of(ctx).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final aiConfigDao = ref.read(aiConfigDaoProvider);
                          final now = DateTime.now();
                          final id = 'p_${now.millisecondsSinceEpoch}';
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入服务商名称')),
                            );
                            return;
                          }

                          await aiConfigDao.saveConfig(AiConfigsCompanion(
                            id: Value(id),
                            providerPreset: Value(name),
                            protocol: Value(protocol.toKey()),
                            apiKey: const Value(''),
                            baseUrl: Value(baseUrlCtrl.text.trim()),
                            model: Value(modelCtrl.text.trim()),
                            agentRole: Value(agentId),
                            agentPrompt: Value(AiAgent.findById(agentId)?.prompt ?? ''),
                            temperature: Value(temperature),
                            maxTokens: Value(int.tryParse(maxTokensCtrl.text) ?? 4096),
                            capabilities: Value(jsonEncode(sheetCapabilities)),
                            isActive: Value(0),
                            updatedAt: Value(now),
                            createdAt: Value(now),
                          ));

                          if (apiKeyCtrl.text.trim().isNotEmpty) {
                            final secretsDao = ref.read(secretsDaoProvider);
                            await secretsDao.setValue('ai', 'api_key', apiKeyCtrl.text.trim(), entityId: id);
                          }

                          await _loadData();
                          if (!context.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('服务商已添加')),
                          );
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          backgroundColor: AntdColors.primary,
                        ),
                        child: const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompactProtocolSelector(BuildContext context, AiProtocol selected, ValueChanged<AiProtocol> onChanged) {
    const protocols = [
      (protocol: AiProtocol.openaiResponses, label: 'Responses'),
      (protocol: AiProtocol.openaiChat, label: 'Chat'),
      (protocol: AiProtocol.anthropic, label: 'Claude'),
    ];
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: protocols.map((item) {
        final sel = selected == item.protocol;
        return GestureDetector(
          onTap: () => onChanged(item.protocol),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: sel ? AntdColors.primaryBg : Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: sel ? AntdColors.primary : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Text(item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                color: sel ? AntdColors.primary : Theme.of(context).colorScheme.onSurface,
              )),
          ),
        );
      }).toList(),
    );
  }

  // ==================== 协议选择（编辑区域） ====================

  Widget _buildProtocolSelector(BuildContext context, ThemeData theme, AiProviderConfig config) {
    const protocols = [
      (protocol: AiProtocol.openaiResponses, label: 'OpenAI Responses', desc: '/v1/responses'),
      (protocol: AiProtocol.openaiChat, label: 'OpenAI Chat', desc: '/v1/chat/completions'),
      (protocol: AiProtocol.anthropic, label: 'Anthropic', desc: 'Messages API'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: protocols.map((item) {
          final isSelected = config.protocol == item.protocol;
          return GestureDetector(
            onTap: () {
              setState(() {
                final idx = _configs.indexWhere((c) => c.id == config.id);
                if (idx >= 0) {
                  _configs[idx] = config.copyWith(protocol: item.protocol);
                }
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
                  Text(item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AntdColors.primary : theme.colorScheme.onSurface,
                    )),
                  const SizedBox(height: 2),
                  Text(item.desc,
                    style: TextStyle(fontSize: 9, color: theme.colorScheme.outline)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== 输入字段 ====================

  Widget _buildNameField(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          hintText: '服务商名称',
          prefixIcon: Icon(Icons.badge_outlined, size: 18),
        ),
      ),
    );
  }

  Widget _buildApiKeyField(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextFormField(
            controller: _apiKeyController,
            obscureText: !_apiKeyVisible,
            enableInteractiveSelection: true,
            decoration: InputDecoration(
              hintText: 'sk-...',
              prefixIcon: const Icon(Icons.key, size: 18),
              suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  icon: const Icon(Icons.content_paste, size: 18),
                  tooltip: '粘贴',
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      final text = _apiKeyController.text;
                      final sel = _apiKeyController.selection;
                      final newText = text.replaceRange(
                        sel.isValid ? sel.start : text.length,
                        sel.isValid ? sel.end : text.length,
                        data!.text!,
                      );
                      _apiKeyController.text = newText;
                      _apiKeyController.selection = TextSelection.collapsed(
                        offset: sel.isValid ? sel.start + data.text!.length : newText.length,
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(_apiKeyVisible ? Icons.visibility : Icons.visibility_off, size: 18),
                  tooltip: _apiKeyVisible ? '隐藏' : '显示',
                  onPressed: () => setState(() => _apiKeyVisible = !_apiKeyVisible),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'API Key 单独保存在 Secrets 表',
              style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseUrlField(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextFormField(
            controller: _baseUrlController,
            decoration: const InputDecoration(
              hintText: 'https://api.openai.com/v1',
              prefixIcon: Icon(Icons.link, size: 18),
            ),
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

  Widget _buildModelField(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: _modelController,
        decoration: InputDecoration(
          hintText: 'gpt-4o / claude-3-5-sonnet',
          prefixIcon: const Icon(Icons.psychology, size: 18),
          suffixIcon: IconButton(
            icon: const Icon(Icons.cloud_sync_outlined, size: 18),
            tooltip: '从远程拉取模型列表',
            onPressed: () {
              final config = _editingConfig;
              if (config == null) return;
              _fetchModels(
                baseUrl: _baseUrlController.text,
                apiKey: _apiKeyController.text,
                protocol: config.protocol,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMaxTokensField(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: _maxTokensController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: '4096',
          prefixIcon: Icon(Icons.data_array, size: 18),
        ),
      ),
    );
  }

  // ==================== Capabilities 编辑器 ====================

  static const List<String> _allCapabilities = [
    'text', 'image', 'multimodal', 'reasoning', 'code',
    'vision', 'audio', 'video', 'file', 'tool', 'search',
  ];

  static String _capabilityLabel(String cap) {
    return switch (cap) {
      'text' => '文本',
      'image' => '图片',
      'multimodal' => '多模态',
      'reasoning' => '推理',
      'code' => '代码',
      'vision' => '视觉',
      'audio' => '音频',
      'video' => '视频',
      'file' => '文件',
      'tool' => '工具调用',
      'search' => '联网搜索',
      _ => cap,
    };
  }

  Widget _buildCapabilitiesEditor(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _allCapabilities.map((cap) {
          final isSelected = _capabilities.contains(cap);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  if (_capabilities.length > 1) {
                    _capabilities.remove(cap);
                  }
                } else {
                  _capabilities.add(cap);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? AntdColors.primary : theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AntdColors.primary : theme.colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    ),
                  Text(
                    _capabilityLabel(cap),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
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

  // ==================== Agent 角色 ====================

  Widget _buildAgentSelector(BuildContext context, ThemeData theme, AiProviderConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8, runSpacing: 8,
            children: AiAgent.builtIn.map((agent) {
              final isSelected = config.agentId == agent.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    final idx = _configs.indexWhere((c) => c.id == config.id);
                    if (idx >= 0) {
                      _configs[idx] = config.copyWith(agentId: agent.id);
                    }
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
            AiAgent.findById(config.agentId)?.prompt ?? '',
            style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  // ==================== Temperature 滑块 ====================

  Widget _buildTemperatureSlider(BuildContext context, ThemeData theme, AiProviderConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text('Temperature',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant)),
              const Spacer(),
              Text(config.temperature.toStringAsFixed(1),
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          Slider(
            value: config.temperature,
            min: 0, max: 2, divisions: 20,
            activeColor: AntdColors.primary,
            onChanged: (v) {
              setState(() {
                final idx = _configs.indexWhere((c) => c.id == config.id);
                if (idx >= 0) {
                  _configs[idx] = config.copyWith(temperature: v);
                }
              });
            },
          ),
        ],
      ),
    );
  }

}
