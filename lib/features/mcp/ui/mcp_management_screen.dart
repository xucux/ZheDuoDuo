import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mcp_tool.dart';
import '../providers/mcp_provider.dart';

class McpManagementScreen extends ConsumerStatefulWidget {
  const McpManagementScreen({super.key});

  @override
  ConsumerState<McpManagementScreen> createState() => _McpManagementScreenState();
}

class _McpManagementScreenState extends ConsumerState<McpManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = ref.watch(mcpEnabledProvider);
    final toolConfigs = ref.watch(mcpToolSettingsProvider);
    final serverStatus = ref.watch(mcpServerStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MCP 管理')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _buildSectionHeader(context, 'MCP 服务器'),
          _buildServerToggle(context, theme, enabled),
          const SizedBox(height: 8),
          _buildServerStatus(context, theme, enabled, serverStatus),
          const Divider(height: 24),
          _buildSectionHeader(context, '工具管理'),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              '启用或禁用各个 MCP 工具，禁用的工具不会被 AI 调用。',
              style: TextStyle(fontSize: 12),
            ),
          ),
          _buildToolList(context, theme, toolConfigs),
          const Divider(height: 24),
          _buildSectionHeader(context, '使用说明'),
          _buildHelpSection(context, theme),
        ],
      ),
    );
  }

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

  Widget _buildServerToggle(BuildContext context, ThemeData theme, bool enabled) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SwitchListTile(
        secondary: Icon(
          Icons.dns_outlined,
          color: enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
        ),
        title: const Text('MCP 服务器'),
        subtitle: Text(enabled ? '运行中' : '已关闭'),
        value: enabled,
        onChanged: (value) {
          ref.read(mcpEnabledProvider.notifier).setEnabled(value);
        },
      ),
    );
  }

  Widget _buildServerStatus(
    BuildContext context,
    ThemeData theme,
    bool enabled,
    AsyncValue<McpServerInfo> serverStatus,
  ) {
    if (!enabled) return const SizedBox.shrink();

    return serverStatus.when(
      data: (info) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: info.running ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        info.running ? '服务器运行中' : '服务器未启动',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: info.running ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '地址: ${info.address}',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                  ),
                  if (info.tools.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '启用工具: ${info.tools.length} 个',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Card(child: Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            height: 20,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        )),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text('服务器错误: $e',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.error)),
          ),
        ),
      ),
    );
  }

  Widget _buildToolList(BuildContext context, ThemeData theme, List<McpToolConfig> tools) {
    if (tools.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '暂无可用工具',
          style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(tools.length, (i) {
            final tool = tools[i];

            return Column(
              children: [
                if (i > 0) Divider(height: 1, color: theme.colorScheme.outlineVariant),
                SwitchListTile(
                  secondary: Icon(
                    tool.enabled
                        ? Icons.build_outlined
                        : Icons.build_circle_outlined,
                    color: tool.enabled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                  title: Text(
                    tool.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tool.functionName,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  value: tool.enabled,
                  onChanged: (value) {
                    ref.read(mcpToolSettingsProvider.notifier)
                        .setToolEnabled(tool.toolId, value);
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '关于 MCP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'MCP（Model Context Protocol）是一种开放的协议，允许 AI 应用通过标准化的接口调用本地工具。'
                '启用后，AI 可以调用以下工具：',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.outline, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildToolHelpItem(theme, 'OCR 文字识别', '识别图片中的文字（Google ML Kit 本地方案）'),
              const SizedBox(height: 4),
              _buildToolHelpItem(theme, '商品截图解析', '将商品截图中的价格、促销等信息自动录入为折扣记录'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolHelpItem(ThemeData theme, String name, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              )),
            Text(desc,
              style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
          ],
        ),
      ],
    );
  }
}
