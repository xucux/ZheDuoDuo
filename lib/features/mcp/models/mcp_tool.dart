// MCP 工具抽象模型与内置工具配置
//
// 定义 MCP 工具的抽象基类和配置模型，
// 以及系统内置的工具列表（OCR、截图解析、折扣查询/聚合/分组）。

import 'mcp_protocol.dart';

/// MCP 工具抽象基类
///
/// 所有 MCP 工具需实现此接口，提供名称、描述、输入 Schema 和执行方法。
abstract class McpTool {
  /// 工具名称（唯一标识）
  String get name;
  /// 工具描述
  String get description;
  /// 输入参数 JSON Schema
  Map<String, dynamic> get inputSchema;
  /// 是否启用
  bool get enabled;

  /// 获取工具定义（用于 tools/list 响应）
  McpToolDefinition get definition => McpToolDefinition(
    name: name,
    description: description,
    inputSchema: inputSchema,
  );

  /// 执行工具，传入参数并返回结果
  Future<Map<String, dynamic>> execute(Map<String, dynamic> arguments);
}

/// MCP 工具配置模型
///
/// 用于 UI 展示和持久化工具的启用/禁用状态。
class McpToolConfig {
  /// 工具 ID
  final String toolId;
  /// 工具名称
  final String name;
  /// 工具描述
  final String description;
  /// 函数名称（MCP 协议中的实际调用名称）
  final String functionName;
  /// 是否启用
  final bool enabled;

  const McpToolConfig({
    required this.toolId,
    required this.name,
    required this.description,
    required this.functionName,
    this.enabled = false,
  });

  /// 复制并修改启用状态
  McpToolConfig copyWith({bool? enabled}) {
    return McpToolConfig(
      toolId: toolId,
      name: name,
      description: description,
      functionName: functionName,
      enabled: enabled ?? this.enabled,
    );
  }

  /// 转为 JSON Map
  Map<String, dynamic> toJson() => {
    'toolId': toolId,
    'name': name,
    'description': description,
    'functionName': functionName,
    'enabled': enabled,
  };
}

/// 系统内置 MCP 工具配置列表
///
/// 定义所有可用的 MCP 工具及其默认启用状态。
const List<McpToolConfig> mcpBuiltInTools = [
  McpToolConfig(
    toolId: 'ocr_recognize',
    name: 'OCR 文字识别',
    description: '识别图片中的文字内容（Google ML Kit）',
    functionName: 'ocr_recognize',
    enabled: true,
  ),
  McpToolConfig(
    toolId: 'screenshot_parser_add_deal',
    name: '商品截图解析',
    description: '解析商品截图信息并新增折扣记录',
    functionName: 'screenshot_parser_add_deal',
    enabled: true,
  ),
  McpToolConfig(
    toolId: 'deals_query',
    name: '折扣信息查询',
    description: '查询折扣信息列表，支持平台、分类、关键词模糊搜索、价格范围、时间范围筛选和排序',
    functionName: 'deals_query',
    enabled: true,
  ),
  McpToolConfig(
    toolId: 'deals_aggregate',
    name: '折扣信息聚合统计',
    description: '聚合统计折扣信息，支持计数、求和、平均值、最小值、最大值等汇总方式',
    functionName: 'deals_aggregate',
    enabled: true,
  ),
  McpToolConfig(
    toolId: 'deals_group',
    name: '折扣信息分组查询',
    description: '分组查询折扣信息列表，支持按平台、分类、月份、年份分组统计',
    functionName: 'deals_group',
    enabled: true,
  ),
];

/// 根据工具 ID 查找内置工具配置
McpToolConfig? findMcpToolById(String toolId) {
  for (final t in mcpBuiltInTools) {
    if (t.toolId == toolId) return t;
  }
  return null;
}
