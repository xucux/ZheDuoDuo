// MCP HTTP 服务端
//
// 在本地启动 HTTP 服务器，接收 LLM 的 MCP 请求并路由到对应工具执行。
// 支持 tools/list（列出可用工具）和 tools/call（调用工具）两个方法。
// 服务器绑定在 127.0.0.1 的随机端口上。

import 'dart:convert';
import 'dart:io';

import '../models/mcp_protocol.dart';
import 'mcp_tool_registry.dart';

/// MCP HTTP 服务端
///
/// 在本地启动 HTTP 服务器，处理 LLM 发来的 MCP JSON-RPC 请求。
/// 仅支持 POST 方法，支持 tools/list 和 tools/call 两个方法。
class McpServerService {
  /// HTTP 服务器实例
  HttpServer? _server;
  /// 工具注册表
  final McpToolRegistry _registry;
  /// 是否正在运行
  bool _running = false;
  /// 监听端口
  int _port = 0;

  McpServerService(this._registry);

  /// 是否正在运行
  bool get isRunning => _running;
  /// 监听端口
  int get port => _port;

  /// 启动 HTTP 服务器
  ///
  /// [preferredPort] 首选端口，0 表示随机分配。
  Future<void> start({int preferredPort = 0}) async {
    if (_running) return;

    _server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      preferredPort,
    );
    _port = _server!.port;
    _running = true;

    _server!.listen(_handleRequest, onError: (error) {
      _running = false;
    });
  }

  /// 停止 HTTP 服务器
  Future<void> stop() async {
    _running = false;
    await _server?.close(force: true);
    _server = null;
    _port = 0;
  }

  /// 处理 HTTP 请求（仅允许 POST）
  void _handleRequest(HttpRequest request) {
    request.response.headers.contentType = ContentType.json;

    if (request.method != 'POST') {
      request.response.statusCode = 405;
      request.response.write(const McpResponse(
        id: 0,
        error: McpError(code: -32600, message: 'Method not allowed'),
      ).toJsonString());
      request.response.close();
      return;
    }

    utf8.decodeStream(request).then((text) {
      Map<String, dynamic> json;
      try {
        json = jsonDecode(text) as Map<String, dynamic>;
      } catch (_) {
        request.response.statusCode = 400;
        request.response.write(const McpResponse(
          id: 0,
          error: McpError(code: -32700, message: 'Parse error'),
        ).toJsonString());
        request.response.close();
        return;
      }

      final req = McpRequest.fromJson(json);
      _processRequest(req, request.response);
    }).catchError((_) {
      request.response.statusCode = 500;
      request.response.write(const McpResponse(
        id: 0,
        error: McpError(code: -32603, message: 'Internal error'),
      ).toJsonString());
      request.response.close();
    });
  }

  /// 路由 MCP 请求到对应处理方法
  void _processRequest(McpRequest request, HttpResponse response) {
    switch (request.method) {
      case 'tools/list':
        _handleListTools(request, response);
      case 'tools/call':
        _handleCallTool(request, response);
      default:
        response.write(McpResponse(
          id: request.id,
          error: const McpError(code: -32601, message: 'Method not found'),
        ).toJsonString());
        response.close();
    }
  }

  /// 处理 tools/list 请求：返回所有已启用工具的定义
  void _handleListTools(McpRequest request, HttpResponse response) {
    final tools = _registry.enabledToolsJson;
    response.write(McpResponse(
      id: request.id,
      result: {'tools': tools},
    ).toJsonString());
    response.close();
  }

  /// 处理 tools/call 请求：执行指定工具并返回结果
  void _handleCallTool(McpRequest request, HttpResponse response) {
    final params = request.params ?? {};
    final name = params['name'] as String?;
    final arguments = params['arguments'] as Map<String, dynamic>? ?? {};

    if (name == null) {
      response.write(McpResponse(
        id: request.id,
        error: const McpError(code: -32602, message: 'Missing tool name'),
      ).toJsonString());
      response.close();
      return;
    }

    final tool = _registry.get(name);
    if (tool == null || !tool.enabled) {
      response.write(McpResponse(
        id: request.id,
        error: McpError(
          code: -32602,
          message: 'Tool not found or disabled: $name',
        ),
      ).toJsonString());
      response.close();
      return;
    }

    tool.execute(arguments).then((result) {
      response.write(McpResponse(
        id: request.id,
        result: result,
      ).toJsonString());
      response.close();
    }).catchError((e) {
      response.write(McpResponse(
        id: request.id,
        error: McpError(
          code: -32603,
          message: 'Tool execution failed',
          data: e.toString(),
        ),
      ).toJsonString());
      response.close();
    });
  }

  /// 服务器地址（如 http://127.0.0.1:12345）
  String get address => 'http://127.0.0.1:$_port';
}
