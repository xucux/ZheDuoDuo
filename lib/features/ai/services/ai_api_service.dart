// AI API 调用服务
//
// 封装与各 AI 服务商（OpenAI Chat / OpenAI Responses / Anthropic）的 HTTP 交互。
// 支持：
// - 非流式和流式（SSE）两种请求模式
// - MCP 工具调用（function calling）循环
// - 消息上下文压缩（按 token 预算裁剪历史消息）
// - 多模态消息（文本 + 图片）

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/ai_chat_models.dart';

/// AI API 调用结果
///
/// 包含模型返回的正式回复内容 [content] 和可选的推理过程 [reasoningContent]。
/// reasoningContent 仅用于前端展示，不参与后续上下文发送。
class AiApiResult {
  /// 正式回复内容
  final String content;
  /// 推理过程内容（如 DeepSeek reasoning_content）
  final String? reasoningContent;

  const AiApiResult(this.content, {this.reasoningContent});
}

/// 流式响应回调
///
/// 用于实时接收推理过程和正式回复内容。
class StreamCallbacks {
  /// 推理内容回调（如 DeepSeek reasoning_content）
  final void Function(String reasoning)? onReasoning;
  /// 正式回复内容回调
  final void Function(String content)? onContent;
  /// 完成回调
  final void Function()? onDone;
  /// 错误回调
  final void Function(String error)? onError;

  const StreamCallbacks({
    this.onReasoning,
    this.onContent,
    this.onDone,
    this.onError,
  });
}

/// AI API 调用服务
///
/// 统一封装 OpenAI Chat Completions、OpenAI Responses API 和 Anthropic Messages API
/// 三种协议的请求构建、发送和响应解析。支持 MCP 工具调用循环。
class AiApiService {
  /// Anthropic API 版本号
  static const _anthropicVersion = '2023-06-01';
  /// 请求超时时间
  static const _timeout = Duration(seconds: 60);

  /// 发送消息的静态入口方法
  ///
  /// [settings] 对话配置，[messages] 历史消息列表，
  /// [systemPrompt] 系统提示词，[currentUserImages] 当前用户图片路径，
  /// [mcpTools] MCP 工具定义列表，[onMcpToolCall] 工具调用回调，
  /// [streamCallbacks] 流式响应回调（非空时启用流式模式）。
  static Future<AiApiResult> sendMessage({
    required AiChatSettings settings,
    required List<ChatMessage> messages,
    required String systemPrompt,
    required List<String> currentUserImages,
    List<Map<String, dynamic>> mcpTools = const [],
    Future<Map<String, dynamic>> Function(String toolName, Map<String, dynamic> args)? onMcpToolCall,
    StreamCallbacks? streamCallbacks,
  }) async {
    final service = AiApiService();
    return service._send(
      settings, messages, systemPrompt, currentUserImages, mcpTools, onMcpToolCall, streamCallbacks,
    );
  }

  /// 内部发送方法：压缩消息后按协议分发
  Future<AiApiResult> _send(
    AiChatSettings settings,
    List<ChatMessage> messages,
    String systemPrompt,
    List<String> currentUserImages,
    List<Map<String, dynamic>> mcpTools,
    Future<Map<String, dynamic>> Function(String toolName, Map<String, dynamic> args)? onMcpToolCall,
    StreamCallbacks? streamCallbacks,
  ) async {
    final compressed = _compress(messages, settings.maxTokens);

    switch (settings.protocol) {
      case AiProtocol.openaiChat:
        return _openAIChat(settings, compressed, systemPrompt, currentUserImages, mcpTools, onMcpToolCall, streamCallbacks);
      case AiProtocol.openaiResponses:
        return _openAIResponses(settings, compressed, systemPrompt, currentUserImages, mcpTools, onMcpToolCall, streamCallbacks);
      case AiProtocol.anthropic:
        return _anthropic(settings, compressed, systemPrompt, currentUserImages, mcpTools, onMcpToolCall, streamCallbacks);
    }
  }

  /// 压缩消息列表：按 token 预算从最新消息向前保留
  ///
  /// 预算为 maxTokens 的 70%，超出时丢弃最早的消息。
  /// 图片消息额外估算 100 token/张。
  List<ChatMessage> _compress(List<ChatMessage> messages, int maxTokens) {
    if (messages.isEmpty) return messages;

    int estimateTokens(String text) => (text.length ~/ 2).clamp(1, 999999);

    final budget = (maxTokens * 0.7).floor();
    int total = 0;
    final result = <ChatMessage>[];

    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];
      int tokens = estimateTokens(msg.content);
      if (msg.imagePaths.isNotEmpty) {
        tokens += msg.imagePaths.length * 100;
      }
      if (total + tokens > budget && result.isNotEmpty) break;
      total += tokens;
      result.insert(0, msg);
    }

    if (result.isEmpty && messages.isNotEmpty) {
      result.add(messages.last);
    }

    return result;
  }

  /// OpenAI Chat Completions 非流式请求
  ///
  /// 构建消息列表后发送请求，支持 MCP 工具调用循环。
  /// 当有流式回调时自动切换到流式模式。
  Future<AiApiResult> _openAIChat(
    AiChatSettings settings,
    List<ChatMessage> messages,
    String systemPrompt,
    List<String> currentUserImages,
    List<Map<String, dynamic>> mcpTools,
    Future<Map<String, dynamic>> Function(String toolName, Map<String, dynamic> args)? onMcpToolCall,
    StreamCallbacks? streamCallbacks,
  ) async {
    final apiMessages = <Map<String, dynamic>>[];

    if (systemPrompt.isNotEmpty) {
      apiMessages.add({'role': 'system', 'content': systemPrompt});
    }

    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final isLast = i == messages.length - 1;
      final content = _openAIContent(msg, isLast ? currentUserImages : []);
      apiMessages.add({'role': msg.role.toKey(), 'content': content});
    }

    final hasTools = mcpTools.isNotEmpty && onMcpToolCall != null;

    // 如果提供了流式回调，使用流式请求
    if (streamCallbacks != null) {
      return _openAIChatStream(
        settings, apiMessages, hasTools, mcpTools, onMcpToolCall, streamCallbacks,
      );
    }

    while (true) {
      final requestData = {
        'model': settings.model,
        'messages': apiMessages,
        'temperature': settings.temperature,
        'max_tokens': settings.maxTokens,
        if (hasTools) 'tools': mcpTools,
        if (hasTools) 'tool_choice': 'auto',
      };
      debugPrint('[AI API] OpenAI Chat Request: ${_sanitizeRequest(requestData)}');

      final response = await Dio().post(
        '${settings.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${settings.apiKey}',
            'Content-Type': 'application/json',
          },
          sendTimeout: _timeout,
          receiveTimeout: _timeout,
        ),
        data: requestData,
      );

      final data = response.data as Map<String, dynamic>;
      debugPrint('[AI API] OpenAI Chat Response (${response.statusCode}): ${_truncateResponse(data)}');
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) throw Exception('API 返回为空');
      final message = choices[0]['message'] as Map<String, dynamic>?;
      if (message == null) throw Exception('API 返回消息为空');

      final toolCalls = message['tool_calls'] as List?;
      if (toolCalls == null || toolCalls.isEmpty || !hasTools) {
        final content = message['content'] as String? ?? '';
        final reasoning = message['reasoning_content'] as String?;
        return AiApiResult(content, reasoningContent: reasoning);
      }

      apiMessages.add(Map<String, dynamic>.from(message));

      for (final tc in toolCalls) {
        await _executeToolAndAppend(tc as Map<String, dynamic>, apiMessages, onMcpToolCall);
      }

      currentUserImages = [];
    }
  }

  /// OpenAI Chat 流式请求
  Future<AiApiResult> _openAIChatStream(
    AiChatSettings settings,
    List<Map<String, dynamic>> apiMessages,
    bool hasTools,
    List<Map<String, dynamic>> mcpTools,
    Future<Map<String, dynamic>> Function(String toolName, Map<String, dynamic> args)? onMcpToolCall,
    StreamCallbacks callbacks,
  ) async {
    final requestData = {
      'model': settings.model,
      'messages': apiMessages,
      'temperature': settings.temperature,
      'max_tokens': settings.maxTokens,
      'stream': true,
      if (hasTools) 'tools': mcpTools,
      if (hasTools) 'tool_choice': 'auto',
    };
    debugPrint('[AI API] OpenAI Chat Stream Request: ${_sanitizeRequest(requestData)}');

    final dio = Dio();
    final response = await dio.post<ResponseBody>(
      '${settings.baseUrl}/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${settings.apiKey}',
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
        },
        responseType: ResponseType.stream,
        sendTimeout: _timeout,
        receiveTimeout: _timeout,
      ),
      data: requestData,
    );

    final stream = response.data!.stream;
    final buffer = StringBuffer();
    final reasoningBuffer = StringBuffer();
    String? toolCallId;
    String? toolCallName;
    StringBuffer? toolCallArgsBuffer;

    await for (final chunk in stream) {
      final lines = utf8.decode(chunk).split('\n');
      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data.isEmpty || data == '[DONE]') continue;

        try {
          final jsonData = jsonDecode(data) as Map<String, dynamic>;
          final choices = jsonData['choices'] as List?;
          if (choices == null || choices.isEmpty) continue;

          final delta = choices[0]['delta'] as Map<String, dynamic>?;
          if (delta == null) continue;

          // 处理推理内容
          final reasoning = delta['reasoning_content'] as String?;
          if (reasoning != null && reasoning.isNotEmpty) {
            reasoningBuffer.write(reasoning);
            callbacks.onReasoning?.call(reasoningBuffer.toString());
          }

          // 处理正式内容
          final content = delta['content'] as String?;
          if (content != null && content.isNotEmpty) {
            buffer.write(content);
            callbacks.onContent?.call(buffer.toString());
          }

          // 处理工具调用
          final toolCalls = delta['tool_calls'] as List?;
          if (toolCalls != null && toolCalls.isNotEmpty) {
            final tc = toolCalls[0] as Map<String, dynamic>;
            if (tc['id'] != null) toolCallId = tc['id'] as String;
            if (tc['function'] != null) {
              final fn = tc['function'] as Map<String, dynamic>;
              if (fn['name'] != null) toolCallName = fn['name'] as String;
              if (fn['arguments'] != null) {
                toolCallArgsBuffer ??= StringBuffer();
                toolCallArgsBuffer.write(fn['arguments'] as String);
              }
            }
          }
        } catch (e) {
          debugPrint('[AI API] Stream parse error: $e');
        }
      }
    }

    // 如果有工具调用，执行工具
    if (toolCallId != null && toolCallName != null && hasTools && onMcpToolCall != null) {
      final argsStr = toolCallArgsBuffer?.toString() ?? '{}';
      Map<String, dynamic> args;
      try {
        args = jsonDecode(argsStr) as Map<String, dynamic>;
      } catch (_) {
        args = {};
      }

      Map<String, dynamic> result;
      try {
        result = await onMcpToolCall(toolCallName, args);
      } catch (e) {
        result = {'error': '工具执行失败: $e'};
      }

      // 添加工具调用结果到消息列表
      apiMessages.add({
        'role': 'assistant',
        'content': buffer.toString(),
        'tool_calls': [{
          'id': toolCallId,
          'type': 'function',
          'function': {'name': toolCallName, 'arguments': argsStr},
        }],
      });
      apiMessages.add({
        'role': 'tool',
        'tool_call_id': toolCallId,
        'content': jsonEncode(result),
      });

      // 递归调用获取最终结果
      return _openAIChatStream(settings, apiMessages, hasTools, mcpTools, onMcpToolCall, callbacks);
    }

    callbacks.onDone?.call();
    return AiApiResult(buffer.toString(), reasoningContent: reasoningBuffer.toString());
  }

  Future<AiApiResult> _openAIResponses(
    AiChatSettings settings,
    List<ChatMessage> messages,
    String systemPrompt,
    List<String> currentUserImages,
    List<Map<String, dynamic>> mcpTools,
    Future<Map<String, dynamic>> Function(String toolName, Map<String, dynamic> args)? onMcpToolCall,
    StreamCallbacks? streamCallbacks,
  ) async {
    final inputItems = <Map<String, dynamic>>[];

    if (systemPrompt.isNotEmpty) {
      inputItems.add({'role': 'system', 'content': systemPrompt});
    }

    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final isLast = i == messages.length - 1;
      final content = _openAIContent(msg, isLast ? currentUserImages : []);
      inputItems.add({'role': msg.role.toKey(), 'content': content});
    }

    final hasTools = mcpTools.isNotEmpty && onMcpToolCall != null;

    // OpenAI Responses API 暂不支持流式，使用非流式
    if (streamCallbacks != null) {
      // 先返回空结果，实际通过非流式获取
      final result = await _openAIResponsesNonStream(
        settings, inputItems, systemPrompt, hasTools, mcpTools, onMcpToolCall,
      );
      if (result.reasoningContent?.isNotEmpty == true) {
        streamCallbacks.onReasoning?.call(result.reasoningContent!);
      }
      streamCallbacks.onContent?.call(result.content);
      streamCallbacks.onDone?.call();
      return result;
    }

    return _openAIResponsesNonStream(
      settings, inputItems, systemPrompt, hasTools, mcpTools, onMcpToolCall,
    );
  }

  Future<AiApiResult> _openAIResponsesNonStream(
    AiChatSettings settings,
    List<Map<String, dynamic>> inputItems,
    String systemPrompt,
    bool hasTools,
    List<Map<String, dynamic>> mcpTools,
    Future<Map<String, dynamic>> Function(String toolName, Map<String, dynamic> args)? onMcpToolCall,
  ) async {
    while (true) {
      final requestData = {
        'model': settings.model,
        'input': inputItems,
        'instructions': systemPrompt,
        'temperature': settings.temperature,
        'max_output_tokens': settings.maxTokens,
        if (hasTools) 'tools': mcpTools,
        if (hasTools) 'tool_choice': 'auto',
      };
      debugPrint('[AI API] OpenAI Responses Request: ${_sanitizeRequest(requestData)}');

      final response = await Dio().post(
        '${settings.baseUrl}/responses',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${settings.apiKey}',
            'Content-Type': 'application/json',
          },
          sendTimeout: _timeout,
          receiveTimeout: _timeout,
        ),
        data: requestData,
      );

      final data = response.data as Map<String, dynamic>;
      debugPrint('[AI API] OpenAI Responses Response (${response.statusCode}): ${_truncateResponse(data)}');
      final output = data['output'] as List?;
      if (output == null || output.isEmpty) throw Exception('API 返回为空');

      final functionCalls = output
          .where((item) => (item as Map<String, dynamic>)['type'] == 'function_call')
          .cast<Map<String, dynamic>>()
          .toList();

      if (functionCalls.isEmpty || !hasTools) {
        final content = output
            .where((item) => (item as Map<String, dynamic>)['type'] == 'message')
            .expand((item) => (item as Map<String, dynamic>)['content'] as List? ?? [])
            .where((c) => (c as Map<String, dynamic>)['type'] == 'output_text')
            .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
            .join();
        if (content.isNotEmpty) return AiApiResult(content);
        final firstMsg = output.firstWhere(
          (item) => (item as Map<String, dynamic>)['type'] == 'message',
          orElse: () => output.first as Map<String, dynamic>,
        );
        final textContent = firstMsg['content'] as List?;
        if (textContent != null && textContent.isNotEmpty) {
          final text = textContent
              .where((c) => (c as Map<String, dynamic>)['type'] == 'output_text')
              .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
              .join();
          return AiApiResult(text);
        }
        return const AiApiResult('');
      }

      inputItems.add({
        'role': 'assistant',
        'content': output
            .where((item) => (item as Map<String, dynamic>)['type'] == 'message')
            .map((item) {
              final m = Map<String, dynamic>.from(item as Map);
              m.remove('id');
              m.remove('status');
              m.remove('type');
              return m;
            })
            .toList(),
      });

      for (final fc in functionCalls) {
        final name = fc['name'] as String? ?? '';
        final argsStr = fc['arguments'] as String? ?? '{}';
        final callId = fc['id'] as String? ?? '';

        Map<String, dynamic> args;
        try {
          args = jsonDecode(argsStr) as Map<String, dynamic>;
        } catch (_) {
          args = {};
        }

        Map<String, dynamic> result;
        try {
          result = await onMcpToolCall!(name, args);
        } catch (e) {
          result = {'error': '工具执行失败: $e'};
        }

        inputItems.add({
          'type': 'function_call_output',
          'call_id': callId,
          'output': jsonEncode(result),
        });
      }
    }
  }

  Future<AiApiResult> _anthropic(
    AiChatSettings settings,
    List<ChatMessage> messages,
    String systemPrompt,
    List<String> currentUserImages,
    List<Map<String, dynamic>> mcpTools,
    Future<Map<String, dynamic>> Function(String toolName, Map<String, dynamic> args)? onMcpToolCall,
    StreamCallbacks? streamCallbacks,
  ) async {
    final apiMessages = <Map<String, dynamic>>[];

    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final isLast = i == messages.length - 1;
      final content = _anthropicContent(msg, isLast ? currentUserImages : []);
      apiMessages.add({'role': msg.role.toKey(), 'content': content});
    }

    final hasTools = mcpTools.isNotEmpty && onMcpToolCall != null;

    // Anthropic 支持流式
    if (streamCallbacks != null) {
      return _anthropicStream(
        settings, apiMessages, systemPrompt, hasTools, mcpTools, onMcpToolCall, streamCallbacks,
      );
    }

    return _anthropicNonStream(
      settings, apiMessages, systemPrompt, hasTools, mcpTools, onMcpToolCall,
    );
  }

  Future<AiApiResult> _anthropicNonStream(
    AiChatSettings settings,
    List<Map<String, dynamic>> apiMessages,
    String systemPrompt,
    bool hasTools,
    List<Map<String, dynamic>> mcpTools,
    Future<Map<String, dynamic>> Function(String toolName, Map<String, dynamic> args)? onMcpToolCall,
  ) async {
    while (true) {
      final requestData = {
        'model': settings.model,
        'max_tokens': settings.maxTokens,
        'system': systemPrompt,
        'messages': apiMessages,
        'temperature': settings.temperature,
        if (hasTools) 'tools': mcpTools,
      };
      debugPrint('[AI API] Anthropic Request: ${_sanitizeRequest(requestData)}');

      final response = await Dio().post(
        '${settings.baseUrl}/v1/messages',
        options: Options(
          headers: {
            'x-api-key': settings.apiKey,
            'anthropic-version': _anthropicVersion,
            'Content-Type': 'application/json',
          },
          sendTimeout: _timeout,
          receiveTimeout: _timeout,
        ),
        data: requestData,
      );

      final data = response.data as Map<String, dynamic>;
      debugPrint('[AI API] Anthropic Response (${response.statusCode}): ${_truncateResponse(data)}');
      final content = data['content'] as List?;
      if (content == null || content.isEmpty) throw Exception('API 返回为空');

      final toolUses = content
          .where((c) => (c as Map<String, dynamic>)['type'] == 'tool_use')
          .cast<Map<String, dynamic>>()
          .toList();

      if (toolUses.isEmpty || !hasTools) {
        final text = content
            .where((c) => (c as Map<String, dynamic>)['type'] == 'text')
            .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
            .join();
        final thinking = content
            .where((c) => (c as Map<String, dynamic>)['type'] == 'thinking')
            .map((c) => (c as Map<String, dynamic>)['thinking'] as String? ?? '')
            .join('\n');
        return AiApiResult(text, reasoningContent: thinking.isNotEmpty ? thinking : null);
      }

      final stopReason = data['stop_reason'] as String?;
      if (stopReason != 'tool_use' || !hasTools) {
        final text = content
            .where((c) => (c as Map<String, dynamic>)['type'] == 'text')
            .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
            .join();
        final thinking = content
            .where((c) => (c as Map<String, dynamic>)['type'] == 'thinking')
            .map((c) => (c as Map<String, dynamic>)['thinking'] as String? ?? '')
            .join('\n');
        return AiApiResult(text, reasoningContent: thinking.isNotEmpty ? thinking : null);
      }

      apiMessages.add({'role': 'assistant', 'content': content});

      final toolResults = <Map<String, dynamic>>[];
      for (final tu in toolUses) {
        final toolUseId = tu['id'] as String? ?? '';
        final name = tu['name'] as String? ?? '';
        final input = tu['input'] as Map<String, dynamic>? ?? {};

        Map<String, dynamic> result;
        try {
          result = await onMcpToolCall!(name, input);
        } catch (e) {
          result = {'error': '工具执行失败: $e'};
        }

        toolResults.add({
          'type': 'tool_result',
          'tool_use_id': toolUseId,
          'content': jsonEncode(result),
        });
      }

      apiMessages.add({'role': 'user', 'content': toolResults});
    }
  }

  /// Anthropic 流式请求
  Future<AiApiResult> _anthropicStream(
    AiChatSettings settings,
    List<Map<String, dynamic>> apiMessages,
    String systemPrompt,
    bool hasTools,
    List<Map<String, dynamic>> mcpTools,
    Future<Map<String, dynamic>> Function(String toolName, Map<String, dynamic> args)? onMcpToolCall,
    StreamCallbacks callbacks,
  ) async {
    final requestData = {
      'model': settings.model,
      'max_tokens': settings.maxTokens,
      'system': systemPrompt,
      'messages': apiMessages,
      'temperature': settings.temperature,
      'stream': true,
      if (hasTools) 'tools': mcpTools,
    };
    debugPrint('[AI API] Anthropic Stream Request: ${_sanitizeRequest(requestData)}');

    final dio = Dio();
    final response = await dio.post<ResponseBody>(
      '${settings.baseUrl}/v1/messages',
      options: Options(
        headers: {
          'x-api-key': settings.apiKey,
          'anthropic-version': _anthropicVersion,
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
        },
        responseType: ResponseType.stream,
        sendTimeout: _timeout,
        receiveTimeout: _timeout,
      ),
      data: requestData,
    );

    final stream = response.data!.stream;
    final buffer = StringBuffer();
    final thinkingBuffer = StringBuffer();
    final toolUseBuffers = <String, Map<String, dynamic>>{};

    await for (final chunk in stream) {
      final lines = utf8.decode(chunk).split('\n');
      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data.isEmpty) continue;

        // Anthropic 流式以 [DONE] 结束
        if (data == '[DONE]') {
          callbacks.onDone?.call();
          return AiApiResult(buffer.toString(), reasoningContent: thinkingBuffer.toString());
        }

        try {
          final event = jsonDecode(data) as Map<String, dynamic>;
          final type = event['type'] as String?;

          // 处理内容块开始
          if (type == 'content_block_start') {
            final contentBlock = event['content_block'] as Map<String, dynamic>?;
            if (contentBlock != null) {
              final blockType = contentBlock['type'] as String?;
              if (blockType == 'tool_use') {
                final id = contentBlock['id'] as String? ?? '';
                toolUseBuffers[id] = {
                  'id': id,
                  'name': contentBlock['name'] as String? ?? '',
                  'input': StringBuffer(),
                };
              }
            }
          }

          // 处理内容块增量
          if (type == 'content_block_delta') {
            final delta = event['delta'] as Map<String, dynamic>?;
            if (delta != null) {
              // 文本内容
              final text = delta['text'] as String?;
              if (text != null && text.isNotEmpty) {
                buffer.write(text);
                callbacks.onContent?.call(buffer.toString());
              }

              // thinking 内容
              final thinking = delta['thinking'] as String?;
              if (thinking != null && thinking.isNotEmpty) {
                thinkingBuffer.write(thinking);
                callbacks.onReasoning?.call(thinkingBuffer.toString());
              }

              // 工具输入
              final partialJson = delta['partial_json'] as String?;
              if (partialJson != null) {
                final index = event['index'] as int? ?? 0;
                // 找到对应的工具调用
                for (final entry in toolUseBuffers.entries) {
                  if (entry.value['index'] == index) {
                    (entry.value['input'] as StringBuffer).write(partialJson);
                    break;
                  }
                }
              }
            }
          }

          // 处理停止原因
          if (type == 'message_stop') {
            final stopReason = event['stop_reason'] as String?;
            if (stopReason == 'tool_use' && hasTools && onMcpToolCall != null && toolUseBuffers.isNotEmpty) {
              // 执行工具调用
              final toolResults = <Map<String, dynamic>>[];
              for (final entry in toolUseBuffers.entries) {
                final toolData = entry.value;
                final name = toolData['name'] as String;
                final inputStr = (toolData['input'] as StringBuffer).toString();
                Map<String, dynamic> input;
                try {
                  input = jsonDecode(inputStr) as Map<String, dynamic>;
                } catch (_) {
                  input = {};
                }

                Map<String, dynamic> result;
                try {
                  result = await onMcpToolCall(name, input);
                } catch (e) {
                  result = {'error': '工具执行失败: $e'};
                }

                toolResults.add({
                  'type': 'tool_result',
                  'tool_use_id': entry.key,
                  'content': jsonEncode(result),
                });
              }

              // 添加当前消息到上下文
              apiMessages.add({'role': 'assistant', 'content': [
                {'type': 'text', 'text': buffer.toString()},
                ...toolUseBuffers.entries.map((e) => {
                  'type': 'tool_use',
                  'id': e.key,
                  'name': e.value['name'],
                  'input': jsonDecode((e.value['input'] as StringBuffer).toString()),
                }),
              ]});
              apiMessages.add({'role': 'user', 'content': toolResults});

              // 递归调用获取最终结果
              return _anthropicStream(
                settings, apiMessages, systemPrompt, hasTools, mcpTools, onMcpToolCall, callbacks,
              );
            }

            callbacks.onDone?.call();
            return AiApiResult(buffer.toString(), reasoningContent: thinkingBuffer.toString());
          }
        } catch (e) {
          debugPrint('[AI API] Anthropic stream parse error: $e');
        }
      }
    }

    callbacks.onDone?.call();
    return AiApiResult(buffer.toString(), reasoningContent: thinkingBuffer.toString());
  }

  Future<void> _executeToolAndAppend(
    Map<String, dynamic> toolCall,
    List<Map<String, dynamic>> apiMessages,
    Future<Map<String, dynamic>> Function(String toolName, Map<String, dynamic> args)? onMcpToolCall,
  ) async {
    final function = toolCall['function'] as Map<String, dynamic>?;
    final name = function?['name'] as String? ?? '';
    final argsStr = function?['arguments'] as String? ?? '{}';

    Map<String, dynamic> args;
    try {
      args = jsonDecode(argsStr) as Map<String, dynamic>;
    } catch (_) {
      args = {};
    }

    Map<String, dynamic> result;
    try {
      result = await onMcpToolCall!(name, args);
    } catch (e) {
      result = {'error': '工具执行失败: $e'};
    }

    apiMessages.add({
      'role': 'tool',
      'tool_call_id': toolCall['id'],
      'content': jsonEncode(result),
    });
  }

  dynamic _openAIContent(ChatMessage msg, List<String> imageDataUris) {
    final hasImages = imageDataUris.isNotEmpty;
    if (!hasImages) return msg.content;

    final parts = <Map<String, dynamic>>[];
    if (msg.content.isNotEmpty) {
      parts.add({'type': 'text', 'text': msg.content});
    }
    for (final uri in imageDataUris) {
      parts.add({
        'type': 'image_url',
        'image_url': {'url': uri},
      });
    }
    return parts;
  }

  dynamic _anthropicContent(ChatMessage msg, List<String> imageDataUris) {
    final hasImages = imageDataUris.isNotEmpty;
    if (!hasImages) return msg.content;

    final parts = <Map<String, dynamic>>[];
    if (msg.content.isNotEmpty) {
      parts.add({'type': 'text', 'text': msg.content});
    }
    for (final uri in imageDataUris) {
      parts.add({
        'type': 'image',
        'source': {
          'type': 'base64',
          'media_type': 'image/jpeg',
          'data': uri.split(',').last,
        },
      });
    }
    return parts;
  }

  Map<String, dynamic> _sanitizeRequest(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);
    if (sanitized.containsKey('headers')) {
      final headers = Map<String, dynamic>.from(sanitized['headers'] as Map);
      if (headers.containsKey('Authorization')) {
        headers['Authorization'] = 'Bearer ***';
      }
      if (headers.containsKey('x-api-key')) {
        headers['x-api-key'] = '***';
      }
      sanitized['headers'] = headers;
    }
    return sanitized;
  }

  Map<String, dynamic> _truncateResponse(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);
    // 截断长文本内容
    void truncateValue(dynamic value, int maxLength) {
      if (value is String && value.length > maxLength) {
        return;
      }
    }
    return result;
  }
}
