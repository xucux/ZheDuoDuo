// MCP HTTP 服务端
//
// 作为本地服务的一个模块运行，通过 shelf_router 注册 /mcp 和 /sse 路由。
// 支持 POST 模式（/mcp）和 SSE 模式（/sse）。

import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/mcp_protocol.dart';
import 'mcp_tool_registry.dart';

/// MCP HTTP 服务端
///
/// 处理 LLM 发来的 MCP 请求，注册到本地服务的 /mcp 和 /sse 路径。
class McpServerService {
  /// 工具注册表
  final McpToolRegistry _registry;

  McpServerService(this._registry);

  /// 将 MCP 路由注册到外部 Router
  void registerTo(Router router) {
    router.post('/mcp', _handleMcpRequest);
    router.get('/sse', _handleSseRequest);
  }

  /// 处理 /mcp 路径的 HTTP POST 请求
  Future<Response> _handleMcpRequest(Request request) async {
    try {
      final text = await request.readAsString();
      final json = jsonDecode(text) as Map<String, dynamic>;
      final req = McpRequest.fromJson(json);
      return _processRequest(req);
    } catch (_) {
      return Response(400,
        body: const McpResponse(
          id: 0,
          error: McpError(code: -32700, message: 'Parse error'),
        ).toJsonString(),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }
  }

  /// 处理 /sse 路径的 SSE 请求
  Future<Response> _handleSseRequest(Request request) async {
    // SSE 简化实现：返回初始连接响应后关闭，让客户端回退到 POST 模式
    return Response.ok(
      'event: endpoint\ndata: /mcp\n\n',
      headers: {
        'content-type': 'text/event-stream; charset=utf-8',
        'cache-control': 'no-cache',
        'connection': 'keep-alive',
      },
    );
  }

  /// 路由 MCP 请求到对应处理方法
  Future<Response> _processRequest(McpRequest request) async {
    switch (request.method) {
      case 'tools/list':
        return _handleListTools(request);
      case 'tools/call':
        return await _handleCallTool(request);
      default:
        return Response.ok(
          McpResponse(
            id: request.id,
            error: const McpError(code: -32601, message: 'Method not found'),
          ).toJsonString(),
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
    }
  }

  /// 处理 tools/list 请求：返回所有已启用工具的定义
  Response _handleListTools(McpRequest request) {
    final tools = _registry.enabledToolsJson;
    return Response.ok(
      McpResponse(
        id: request.id,
        result: {'tools': tools},
      ).toJsonString(),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  /// 处理 tools/call 请求：执行指定工具并返回结果
  Future<Response> _handleCallTool(McpRequest request) async {
    final params = request.params ?? {};
    final name = params['name'] as String?;
    final arguments = params['arguments'] as Map<String, dynamic>? ?? {};

    if (name == null) {
      return Response.ok(
        McpResponse(
          id: request.id,
          error: const McpError(code: -32602, message: 'Missing tool name'),
        ).toJsonString(),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }

    final tool = _registry.get(name);
    if (tool == null || !tool.enabled) {
      return Response.ok(
        McpResponse(
          id: request.id,
          error: McpError(
            code: -32602,
            message: 'Tool not found or disabled: $name',
          ),
        ).toJsonString(),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }

    try {
      final result = await tool.execute(arguments);
      return Response.ok(
        McpResponse(
          id: request.id,
          result: result,
        ).toJsonString(),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    } catch (e) {
      return Response.ok(
        McpResponse(
          id: request.id,
          error: McpError(
            code: -32603,
            message: 'Tool execution failed',
            data: e.toString(),
          ),
        ).toJsonString(),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }
  }
}
