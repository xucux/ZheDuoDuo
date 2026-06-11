// MCP 工具注册表
//
// 集中管理所有 MCP 工具的注册、查询和启用状态。
// 内置工具包括：OCR 识别、商品截图解析、折扣查询/聚合/分组。

import '../../../core/database/app_database.dart';
import '../../ocr/services/ocr_service.dart';
import '../models/mcp_protocol.dart';
import '../models/mcp_tool.dart';
import '../tools/deals_aggregate_tool.dart';
import '../tools/deals_group_tool.dart';
import '../tools/deals_query_tool.dart';
import '../tools/ocr_tool.dart';
import '../tools/screenshot_parser_tool.dart';

/// MCP 工具注册表
///
/// 管理所有已注册的 MCP 工具，提供按名称查询、获取已启用工具等操作。
class McpToolRegistry {
  /// 工具名称到工具实例的映射
  final Map<String, McpTool> _tools = {};

  /// 创建注册表并注册所有内置工具
  ///
  /// [db] 数据库实例，[ocrService] 可选的 OCR 服务实例。
  McpToolRegistry(AppDatabase db, {OcrService? ocrService}) {
    _register(OcrTool(ocrService: ocrService ?? OcrService()));
    _register(ScreenshotParserTool(db));
    _register(DealsQueryTool(db));
    _register(DealsAggregateTool(db));
    _register(DealsGroupTool(db));
  }

  /// 注册一个工具
  void _register(McpTool tool) {
    _tools[tool.name] = tool;
  }

  /// 根据名称获取工具实例
  McpTool? get(String name) => _tools[name];

  /// 获取所有已注册的工具
  List<McpTool> get all => _tools.values.toList();

  /// 获取所有已启用的工具
  List<McpTool> get enabledTools => _tools.values.where((t) => t.enabled).toList();

  /// 根据名称获取工具定义
  McpToolDefinition? getDefinition(String name) {
    final tool = _tools[name];
    return tool?.definition;
  }

  /// 获取所有已启用工具的定义列表
  List<McpToolDefinition> get enabledDefinitions =>
      _tools.values.where((t) => t.enabled).map((t) => t.definition).toList();

  /// 获取所有已启用工具的 JSON 描述（用于 tools/list 响应）
  List<Map<String, dynamic>> get enabledToolsJson =>
      _tools.values.where((t) => t.enabled).map((t) => {
        'name': t.name,
        'description': t.description,
        'inputSchema': t.inputSchema,
      }).toList();
}
