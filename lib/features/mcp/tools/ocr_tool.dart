// MCP 工具：OCR 文字识别
//
// 为 LLM 提供图片文字识别能力，支持三种输入方式：
// - 本地文件路径（image_path）
// - 远程 URL（image_url，自动下载到临时文件）
// - Base64 编码（image_base64，自动解码保存到临时文件）
// 支持三种输出格式：纯文本、结构化 JSON、Markdown。

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../ocr/services/ocr_service.dart';
import '../models/mcp_tool.dart';

/// OCR 文字识别 MCP 工具
///
/// 将图片中的文字识别为 LLM 可处理的文本内容。
/// 远程 URL 和 Base64 输入会自动解析为临时文件，识别后自动清理。
class OcrTool extends McpTool {
  final OcrService _ocrService;
  final Dio _dio;

  OcrTool({required OcrService ocrService, Dio? dio})
      : _ocrService = ocrService,
        _dio = dio ?? Dio();

  @override
  final String name = 'ocr_recognize';

  @override
  final String description = '识别图片中的文字内容，支持本地路径、远程 URL、Base64 三种输入方式';

  @override
  final bool enabled = true;

  @override
  final Map<String, dynamic> inputSchema = {
    'type': 'object',
    'properties': {
      'image_path': {
        'type': 'string',
        'description': '本地图片文件路径',
      },
      'image_url': {
        'type': 'string',
        'description': '远程图片 URL 地址',
      },
      'image_base64': {
        'type': 'string',
        'description': '图片 Base64 编码数据（不含 data:image/...;base64, 前缀）',
      },
      'output_format': {
        'type': 'string',
        'description': '输出格式: text（纯文本，默认）, structured（结构化）, markdown',
        'enum': ['text', 'structured', 'markdown'],
      },
    },
    'anyOf': [
      {'required': ['image_path']},
      {'required': ['image_url']},
      {'required': ['image_base64']},
    ],
  };

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> arguments) async {
    final imagePath = arguments['image_path'] as String?;
    final imageUrl = arguments['image_url'] as String?;
    final imageBase64 = arguments['image_base64'] as String?;
    final outputFormat = arguments['output_format'] as String? ?? 'text';

    if (imagePath == null && imageUrl == null && imageBase64 == null) {
      return {
        'success': false,
        'error': '请提供 image_path、image_url 或 image_base64 之一',
      };
    }

    try {
      final resolvedPath = await _resolveImage(
        imagePath: imagePath,
        imageUrl: imageUrl,
        imageBase64: imageBase64,
      );
      if (resolvedPath == null) {
        return {'success': false, 'error': '无法解析图片输入'};
      }
      try {
        return await _recognize(resolvedPath, outputFormat);
      } finally {
        if (imagePath == null) {
          try {
            await File(resolvedPath).delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'OCR 识别失败: $e',
        'text': '',
      };
    }
  }

  /// 解析图片输入为本地文件路径
  ///
  /// 优先使用本地路径，其次下载远程 URL，最后解码 Base64。
  /// 返回 null 表示所有输入均为空。
  Future<String?> _resolveImage({
    String? imagePath,
    String? imageUrl,
    String? imageBase64,
  }) async {
    if (imagePath != null) {
      if (!await File(imagePath).exists()) {
        throw Exception('文件不存在: $imagePath');
      }
      return imagePath;
    }

    if (imageUrl != null) {
      return _downloadImage(imageUrl);
    }

    if (imageBase64 != null) {
      return _saveBase64Image(imageBase64);
    }

    return null;
  }

  /// 下载远程图片到临时文件
  Future<String> _downloadImage(String url) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/ocr_url_${DateTime.now().millisecondsSinceEpoch}.png';
    await _dio.download(url, path);
    if (!await File(path).exists()) {
      throw Exception('下载图片失败: $url');
    }
    return path;
  }

  /// 将 Base64 编码的图片保存到临时文件
  ///
  /// 自动去除 data:image/...;base64, 前缀。
  Future<String> _saveBase64Image(String base64Str) async {
    final raw = base64Str.contains(',')
        ? base64Str.split(',').last
        : base64Str;
    final bytes = base64Decode(raw);
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/ocr_b64_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(bytes);
    return path;
  }

  /// 按指定格式执行 OCR 识别
  Future<Map<String, dynamic>> _recognize(String path, String format) async {
    switch (format) {
      case 'structured':
        final result = await _ocrService.recognizeStructured(path);
        final resultMap = result.toMap();
        return {
          'success': true,
          'text': result.fullText,
          'structured': resultMap,
          'format': 'structured',
        };
      case 'markdown':
        final markdown = await _ocrService.recognizeAsMarkdown(path);
        return {
          'success': true,
          'text': markdown,
          'format': 'markdown',
        };
      default:
        final text = await _ocrService.recognizeImage(path);
        return {
          'success': true,
          'text': text,
          'format': 'text',
        };
    }
  }
}
