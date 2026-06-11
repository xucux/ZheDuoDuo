// OCR 文字识别服务
//
// 基于 Google ML Kit Text Recognition 提供图片文字识别功能。
// 支持中文脚本识别，提供多种输出格式：
// - 纯文本、结构化 JSON、Markdown 格式
// - 支持文件路径和二进制字节两种输入方式

import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

/// OCR 文字识别服务
///
/// 使用 Google ML Kit 的 TextRecognizer（中文脚本）进行图片文字识别。
/// 每次识别都会创建并关闭 Recognizer 实例，避免资源泄漏。
class OcrService {
  OcrService();

  /// 将二进制图片数据保存为临时文件
  ///
  /// [bytes] 图片二进制数据，返回临时文件路径。
  Future<String> _saveTempImage(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// 识别图片中的文字（纯文本）
  ///
  /// [imagePath] 图片文件路径，返回识别出的全部文本。
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

  /// 识别图片中的文字（返回 ML Kit 原始结果对象）
  ///
  /// [imagePath] 图片文件路径，返回 [RecognizedText] 包含块、行、元素等详细信息。
  Future<RecognizedText> recognizeDetailed(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      return await recognizer.processImage(inputImage);
    } finally {
      recognizer.close();
    }
  }

  /// 识别图片中的文字（结构化 JSON）
  ///
  /// [imagePath] 图片文件路径，返回包含 fullText、blockCount、blocks 的 Map。
  /// 每个 block 包含 text、boundingBox、cornerPoints、lines 等信息。
  Future<Map<String, dynamic>> recognizeStructured(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final result = await recognizer.processImage(inputImage);
      final blocks = result.blocks.map((block) {
        return {
          'text': block.text,
          'boundingBox': {
            'left': block.boundingBox.left,
            'top': block.boundingBox.top,
            'width': block.boundingBox.width,
            'height': block.boundingBox.height,
          },
          'cornerPoints': block.cornerPoints
              .map((p) => {'x': p.x, 'y': p.y})
              .toList(),
          'lines': block.lines.map((line) {
            return {
              'text': line.text,
              'boundingBox': {
                'left': line.boundingBox.left,
                'top': line.boundingBox.top,
                'width': line.boundingBox.width,
                'height': line.boundingBox.height,
              },
              'elements': line.elements.map((element) {
                return {
                  'text': element.text,
                  'confidence': element.confidence,
                  'boundingBox': {
                    'left': element.boundingBox.left,
                    'top': element.boundingBox.top,
                    'width': element.boundingBox.width,
                    'height': element.boundingBox.height,
                  },
                };
              }).toList(),
            };
          }).toList(),
        };
      }).toList();
      return {
        'fullText': result.text,
        'blockCount': blocks.length,
        'blocks': blocks,
      };
    } finally {
      recognizer.close();
    }
  }

  /// 从二进制数据识别文字（纯文本）
  ///
  /// [bytes] 图片二进制数据，自动保存为临时文件后识别，识别完毕后删除临时文件。
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

  /// 从二进制数据识别文字（结构化 JSON）
  Future<Map<String, dynamic>> recognizeStructuredFromBytes(Uint8List bytes) async {
    final path = await _saveTempImage(bytes);
    try {
      return await recognizeStructured(path);
    } finally {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  /// 从二进制数据识别文字（Markdown 格式）
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

  /// 识别图片中的文字（Markdown 格式）
  ///
  /// [imagePath] 图片文件路径，返回 Markdown 格式的识别结果，
  /// 按文本块分节输出。
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
}
