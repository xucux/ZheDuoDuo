// OCR 文字识别服务 - 移动端实现（Google ML Kit）
//
// 基于 Google ML Kit Text Recognition 提供图片文字识别功能。
// 仅支持 Android / iOS 平台，桌面端请使用 [DesktopOcrService]。
// 支持中文脚本识别，提供多种输出格式：
// - 纯文本、结构化结果、Markdown 格式
// - 支持文件路径和二进制字节两种输入方式

import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import 'ocr_service_interface.dart';

/// OCR 文字识别服务 - 移动端实现
///
/// 使用 Google ML Kit 的 TextRecognizer（中文脚本）进行图片文字识别。
/// 每次识别都会创建并关闭 Recognizer 实例，避免资源泄漏。
class MlKitOcrService implements OcrServiceBase {
  MlKitOcrService();

  /// 将二进制图片数据保存为临时文件
  ///
  /// [bytes] 图片二进制数据，返回临时文件路径。
  Future<String> _saveTempImage(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Future<String> recognizeImage(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final result = await recognizer.processImage(inputImage);
      return result.text;
    } finally {
      recognizer.close();
    }
  }

  @override
  Future<OcrStructuredResult> recognizeStructured(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final result = await recognizer.processImage(inputImage);
      return _convertMlKitResult(result);
    } finally {
      recognizer.close();
    }
  }

  @override
  Future<String> recognizeAsMarkdown(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final result = await recognizer.processImage(inputImage);
      final buffer = StringBuffer();
      buffer.writeln('# OCR 识别结果\n');
      final blocks = result.blocks;
      for (int i = 0; i < blocks.length; i++) {
        final block = blocks[i];
        buffer.writeln('## 文本块 ${i + 1}\n');
        buffer.writeln('${block.text}\n');
        buffer.writeln('---\n');
      }
      return buffer.toString();
    } finally {
      recognizer.close();
    }
  }

  @override
  Future<String> recognizeImageFromBytes(Uint8List bytes) async {
    final path = await _saveTempImage(bytes);
    try {
      return await recognizeImage(path);
    } finally {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  @override
  Future<OcrStructuredResult> recognizeStructuredFromBytes(Uint8List bytes) async {
    final path = await _saveTempImage(bytes);
    try {
      return await recognizeStructured(path);
    } finally {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  @override
  Future<String> recognizeAsMarkdownFromBytes(Uint8List bytes) async {
    final path = await _saveTempImage(bytes);
    try {
      return await recognizeAsMarkdown(path);
    } finally {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  /// 将 ML Kit RecognizedText 转换为平台无关的 OcrStructuredResult
  OcrStructuredResult _convertMlKitResult(RecognizedText result) {
    final blocks = result.blocks.map((block) {
      return OcrTextBlock(
        text: block.text,
        boundingBox: {
          'left': block.boundingBox.left,
          'top': block.boundingBox.top,
          'width': block.boundingBox.width,
          'height': block.boundingBox.height,
        },
        cornerPoints: block.cornerPoints
            .map((p) => {'x': p.x.toDouble(), 'y': p.y.toDouble()})
            .toList(),
        lines: block.lines.map((line) {
          return OcrTextLine(
            text: line.text,
            boundingBox: {
              'left': line.boundingBox.left,
              'top': line.boundingBox.top,
              'width': line.boundingBox.width,
              'height': line.boundingBox.height,
            },
            elements: line.elements.map((element) {
              return OcrTextElement(
                text: element.text,
                confidence: element.confidence,
                boundingBox: {
                  'left': element.boundingBox.left,
                  'top': element.boundingBox.top,
                  'width': element.boundingBox.width,
                  'height': element.boundingBox.height,
                },
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();

    return OcrStructuredResult(
      fullText: result.text,
      blockCount: blocks.length,
      blocks: blocks,
    );
  }
}
