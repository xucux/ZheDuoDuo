// MCP（Model Context Protocol）协议模型
//
// 定义 JSON-RPC 2.0 格式的 MCP 请求/响应/错误模型，
// 以及工具定义和标准错误码。
// MCP 服务端通过 HTTP 接收请求，路由到对应工具执行后返回结果。

import 'dart:convert';

/// MCP JSON-RPC 请求
class McpRequest {
  /// JSON-RPC 版本，固定为 "2.0"
  final String jsonrpc;
  /// 请求 ID，用于匹配响应
  final int id;
  /// 请求方法（如 "tools/list"、"tools/call"）
  final String method;
  /// 请求参数
  final Map<String, dynamic>? params;

  const McpRequest({
    this.jsonrpc = '2.0',
    required this.id,
    required this.method,
    this.params,
  });

  /// 从 JSON Map 创建请求对象
  factory McpRequest.fromJson(Map<String, dynamic> json) {
    return McpRequest(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      id: json['id'] as int,
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );
  }

  /// 转为 JSON Map
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'id': id,
    'method': method,
    if (params != null) 'params': params,
  };
}

/// MCP JSON-RPC 响应
class McpResponse {
  /// JSON-RPC 版本
  final String jsonrpc;
  /// 对应请求的 ID
  final int id;
  /// 成功时的结果数据
  final dynamic result;
  /// 失败时的错误信息
  final McpError? error;

  const McpResponse({
    this.jsonrpc = '2.0',
    required this.id,
    this.result,
    this.error,
  });

  /// 转为 JSON Map
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'id': id,
    if (error != null) 'error': error!.toJson(),
    if (result != null) 'result': result,
  };

  /// 转为格式化的 JSON 字符串
  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
}

/// MCP JSON-RPC 错误
class McpError {
  /// 错误码
  final int code;
  /// 错误描述
  final String message;
  /// 附加错误数据
  final dynamic data;

  const McpError({
    required this.code,
    required this.message,
    this.data,
  });

  /// 转为 JSON Map
  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    if (data != null) 'data': data,
  };
}

/// MCP 工具定义
///
/// 描述一个 MCP 工具的名称、描述和输入参数 JSON Schema。
class McpToolDefinition {
  /// 工具名称（唯一标识）
  final String name;
  /// 工具描述
  final String description;
  /// 输入参数 JSON Schema
  final Map<String, dynamic> inputSchema;

  const McpToolDefinition({
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  /// 转为 JSON Map
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'inputSchema': inputSchema,
  };
}

/// MCP 标准错误码（JSON-RPC 2.0 规范）
const List<Map<String, dynamic>> mcpStandardErrors = [
  {'code': -32700, 'message': 'Parse error'},
  {'code': -32600, 'message': 'Invalid Request'},
  {'code': -32601, 'message': 'Method not found'},
  {'code': -32602, 'message': 'Invalid params'},
  {'code': -32603, 'message': 'Internal error'},
];
