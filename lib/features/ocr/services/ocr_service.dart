// OCR 文字识别服务 - 统一门面
//
// 向后兼容的 OCR 服务入口，自动委托给当前平台的实现：
// - 移动端（Android / iOS）：Google ML Kit
// - 桌面端（Windows / macOS / Linux）：Tesseract OCR
//
// 此文件保持原有 OcrService 类名和 API 不变，内部通过 [OcrServiceProvider] 选择平台实现。
// 新代码建议直接使用 [OcrServiceProvider.create()] 获取服务实例。

import 'dart:typed_data';

import 'ocr_service_interface.dart';
import 'ocr_service_provider.dart';

/// OCR 文字识别服务（向后兼容门面）
///
/// 保持原有 OcrService 类名和 API 不变，内部委托给平台实现。
/// 移动端使用 Google ML Kit，桌面端使用 Tesseract OCR。
class OcrService {
  /// 平台实际的 OCR 实现
  final OcrServiceBase _impl;

  OcrService() : _impl = OcrServiceProvider.create();

  /// 识别图片中的文字（纯文本）
  ///
  /// [imagePath] 图片文件路径，返回识别出的全部文本。
  Future<String> recognizeImage(String imagePath) =>
      _impl.recognizeImage(imagePath);

  /// 识别图片中的文字（结构化结果）
  ///
  /// [imagePath] 图片文件路径，返回 [OcrStructuredResult] 包含块、行、元素等详细信息。
  Future<OcrStructuredResult> recognizeStructured(String imagePath) =>
      _impl.recognizeStructured(imagePath);

  /// 识别图片中的文字（结构化 JSON Map）
  ///
  /// [imagePath] 图片文件路径，返回包含 fullText、blockCount、blocks 的 Map。
  /// 此方法为向后兼容保留，内部将 OcrStructuredResult 转为 Map。
  Future<Map<String, dynamic>> recognizeStructuredMap(String imagePath) async {
    final result = await _impl.recognizeStructured(imagePath);
    return result.toMap();
  }

  /// 识别图片中的文字（Markdown 格式）
  ///
  /// [imagePath] 图片文件路径，返回 Markdown 格式的识别结果，
  /// 按文本块分节输出。
  Future<String> recognizeAsMarkdown(String imagePath) =>
      _impl.recognizeAsMarkdown(imagePath);

  /// 从二进制数据识别文字（纯文本）
  ///
  /// [bytes] 图片二进制数据，自动保存为临时文件后识别，识别完毕后删除临时文件。
  Future<String> recognizeImageFromBytes(Uint8List bytes) =>
      _impl.recognizeImageFromBytes(bytes);

  /// 从二进制数据识别文字（结构化 JSON Map）
  ///
  /// 此方法为向后兼容保留。
  Future<Map<String, dynamic>> recognizeStructuredFromBytesMap(Uint8List bytes) async {
    final result = await _impl.recognizeStructuredFromBytes(bytes);
    return result.toMap();
  }

  /// 从二进制数据识别文字（结构化结果）
  Future<OcrStructuredResult> recognizeStructuredFromBytes(Uint8List bytes) =>
      _impl.recognizeStructuredFromBytes(bytes);

  /// 从二进制数据识别文字（Markdown 格式）
  Future<String> recognizeAsMarkdownFromBytes(Uint8List bytes) =>
      _impl.recognizeAsMarkdownFromBytes(bytes);
}
