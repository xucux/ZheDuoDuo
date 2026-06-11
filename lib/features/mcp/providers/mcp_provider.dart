// MCP 功能 Provider
//
// 提供 Riverpod Provider 用于：
// - MCP 工具注册表实例（mcpToolRegistryProvider）
// - MCP HTTP 服务实例（mcpServerServiceProvider）
// - MCP 启用状态管理（mcpEnabledProvider）
// - MCP 工具启用/禁用设置（mcpToolSettingsProvider）
// - MCP 服务器运行状态（mcpServerStatusProvider）

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/settings_dao.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../ocr/services/ocr_service.dart';
import '../models/mcp_tool.dart';
import '../services/mcp_server_service.dart';
import '../services/mcp_tool_registry.dart';

/// MCP 工具注册表 Provider
final mcpToolRegistryProvider = Provider<McpToolRegistry>((ref) {
  final db = ref.watch(databaseProvider);
  final ocrService = OcrService();
  return McpToolRegistry(db, ocrService: ocrService);
});

/// MCP HTTP 服务 Provider
final mcpServerServiceProvider = Provider<McpServerService>((ref) {
  final registry = ref.watch(mcpToolRegistryProvider);
  return McpServerService(registry);
});

/// MCP 启用状态 Provider
final mcpEnabledProvider = StateNotifierProvider<McpEnabledNotifier, bool>((ref) {
  final settingsDao = ref.watch(settingsDaoProvider);
  return McpEnabledNotifier(settingsDao);
});

/// MCP 工具启用/禁用设置 Provider
final mcpToolSettingsProvider = StateNotifierProvider<McpToolSettingsNotifier, List<McpToolConfig>>((ref) {
  final settingsDao = ref.watch(settingsDaoProvider);
  return McpToolSettingsNotifier(settingsDao);
});

/// MCP 服务器运行状态 Provider
///
/// 自动根据启用状态启动/停止服务器，返回服务器地址和工具列表。
final mcpServerStatusProvider = FutureProvider.autoDispose<McpServerInfo>((ref) async {
  final enabled = ref.watch(mcpEnabledProvider);
  final service = ref.watch(mcpServerServiceProvider);
  final toolConfigs = ref.watch(mcpToolSettingsProvider);

  if (!enabled) {
    if (service.isRunning) {
      await service.stop();
    }
    return McpServerInfo(running: false, port: 0, address: '');
  }

  if (!service.isRunning) {
    await service.start();
  }

  return McpServerInfo(
    running: service.isRunning,
    port: service.port,
    address: service.address,
    tools: toolConfigs.where((t) => t.enabled).map((t) => t.toJson()).toList(),
  );
});

/// MCP 服务器信息
class McpServerInfo {
  /// 是否正在运行
  final bool running;
  /// 监听端口
  final int port;
  /// 服务器地址
  final String address;
  /// 已启用的工具列表
  final List<Map<String, dynamic>> tools;

  const McpServerInfo({
    required this.running,
    required this.port,
    required this.address,
    this.tools = const [],
  });
}

/// MCP 启用状态管理器
///
/// 从设置中读取/写入 MCP 启用状态。
class McpEnabledNotifier extends StateNotifier<bool> {
  final SettingsDao _settingsDao;

  McpEnabledNotifier(this._settingsDao) : super(false) {
    _load();
  }

  /// 从数据库加载启用状态
  Future<void> _load() async {
    final val = await _settingsDao.getValue('mcp_enabled');
    state = val == 'true';
  }

  /// 设置 MCP 启用状态并持久化
  Future<void> setEnabled(bool value) async {
    state = value;
    await _settingsDao.setValue('mcp_enabled', value.toString());
  }
}

/// MCP 工具启用/禁用设置管理器
///
/// 管理各工具的启用状态，持久化到数据库。
class McpToolSettingsNotifier extends StateNotifier<List<McpToolConfig>> {
  final SettingsDao _settingsDao;

  McpToolSettingsNotifier(this._settingsDao)
      : super(List.from(mcpBuiltInTools)) {
    _load();
  }

  /// 从数据库加载各工具的启用状态
  Future<void> _load() async {
    final updated = <McpToolConfig>[];
    for (final tool in mcpBuiltInTools) {
      final val = await _settingsDao.getValue('mcp_tool_${tool.toolId}_enabled');
      updated.add(tool.copyWith(enabled: val == 'true'));
    }
    state = updated;
  }

  /// 设置指定工具的启用状态并持久化
  Future<void> setToolEnabled(String toolId, bool enabled) async {
    state = [
      for (final t in state)
        if (t.toolId == toolId) t.copyWith(enabled: enabled) else t,
    ];
    await _settingsDao.setValue('mcp_tool_${toolId}_enabled', enabled.toString());
  }
}
