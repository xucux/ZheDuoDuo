// OCR 文字识别服务抽象接口
//
// 定义 OCR 识别的统一接口，屏蔽不同平台底层实现的差异。
// 移动端（Android/iOS）使用 Google ML Kit，桌面端使用 Tesseract OCR。
// 通过 [OcrServiceProvider] 工厂方法按平台自动选择实现。

import 'dart:typed_data';

/// OCR 识别结果中的文本块
///
/// 表示图片中一个连续的文本区域，包含文本内容、位置和行级信息。
class OcrTextBlock {
  /// 文本内容
  final String text;
  /// 文本块边界矩形 {left, top, width, height}
  final Map<String, double> boundingBox;
  /// 文本块四角坐标 [{x, y}, ...]
  final List<Map<String, double>> cornerPoints;
  /// 文本块内的行列表
  final List<OcrTextLine> lines;

  OcrTextBlock({
    required this.text,
    required this.boundingBox,
    required this.cornerPoints,
    required this.lines,
  });

  /// 从 Map 构造（用于反序列化）
  factory OcrTextBlock.fromMap(Map<String, dynamic> map) {
    return OcrTextBlock(
      text: map['text'] as String? ?? '',
      boundingBox: Map<String, double>.from(map['boundingBox'] as Map? ?? {}),
      cornerPoints: (map['cornerPoints'] as List?)
              ?.map((p) => Map<String, double>.from(p as Map))
              .toList() ??
          [],
      lines: (map['lines'] as List?)
              ?.map((l) => OcrTextLine.fromMap(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// 转为 Map（用于序列化）
  Map<String, dynamic> toMap() => {
        'text': text,
        'boundingBox': boundingBox,
        'cornerPoints': cornerPoints,
        'lines': lines.map((l) => l.toMap()).toList(),
      };
}

/// OCR 识别结果中的文本行
///
/// 表示文本块内的一行文字，包含文本内容和元素级信息。
class OcrTextLine {
  /// 行文本内容
  final String text;
  /// 行边界矩形 {left, top, width, height}
  final Map<String, double> boundingBox;
  /// 行内元素列表
  final List<OcrTextElement> elements;

  OcrTextLine({
    required this.text,
    required this.boundingBox,
    required this.elements,
  });

  /// 从 Map 构造
  factory OcrTextLine.fromMap(Map<String, dynamic> map) {
    return OcrTextLine(
      text: map['text'] as String? ?? '',
      boundingBox: Map<String, double>.from(map['boundingBox'] as Map? ?? {}),
      elements: (map['elements'] as List?)
              ?.map((e) => OcrTextElement.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// 转为 Map
  Map<String, dynamic> toMap() => {
        'text': text,
        'boundingBox': boundingBox,
        'elements': elements.map((e) => e.toMap()).toList(),
      };
}

/// OCR 识别结果中的文本元素
///
/// 表示行内最小识别单元（通常为一个词或字），包含文本、置信度和位置。
class OcrTextElement {
  /// 元素文本内容
  final String text;
  /// 识别置信度（0.0 ~ 1.0，桌面端可能为 null）
  final double? confidence;
  /// 元素边界矩形 {left, top, width, height}
  final Map<String, double> boundingBox;

  OcrTextElement({
    required this.text,
    this.confidence,
    required this.boundingBox,
  });

  /// 从 Map 构造
  factory OcrTextElement.fromMap(Map<String, dynamic> map) {
    return OcrTextElement(
      text: map['text'] as String? ?? '',
      confidence: (map['confidence'] as num?)?.toDouble(),
      boundingBox: Map<String, double>.from(map['boundingBox'] as Map? ?? {}),
    );
  }

  /// 转为 Map
  Map<String, dynamic> toMap() => {
        'text': text,
        if (confidence != null) 'confidence': confidence,
        'boundingBox': boundingBox,
      };
}

/// OCR 结构化识别结果
///
/// 包含完整识别文本、文本块数量和各文本块详细信息。
class OcrStructuredResult {
  /// 完整识别文本
  final String fullText;
  /// 文本块数量
  final int blockCount;
  /// 文本块列表
  final List<OcrTextBlock> blocks;

  OcrStructuredResult({
    required this.fullText,
    required this.blockCount,
    required this.blocks,
  });

  /// 从 Map 构造
  factory OcrStructuredResult.fromMap(Map<String, dynamic> map) {
    return OcrStructuredResult(
      fullText: map['fullText'] as String? ?? '',
      blockCount: map['blockCount'] as int? ?? 0,
      blocks: (map['blocks'] as List?)
              ?.map((b) => OcrTextBlock.fromMap(b as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// 转为 Map（兼容原有 JSON 格式）
  Map<String, dynamic> toMap() => {
        'fullText': fullText,
        'blockCount': blockCount,
        'blocks': blocks.map((b) => b.toMap()).toList(),
      };
}

/// OCR 文字识别服务抽象基类
///
/// 定义图片文字识别的统一 API，所有平台实现均需遵循此接口。
/// 支持三种输出格式：纯文本、结构化结果、Markdown。
/// 支持文件路径和二进制字节两种输入方式。
///
/// 使用 [OcrServiceProvider.create()] 按当前平台自动创建合适的实现实例。
abstract class OcrServiceBase {
  /// 识别图片中的文字（纯文本）
  ///
  /// [imagePath] 图片文件路径，返回识别出的全部文本。
  Future<String> recognizeImage(String imagePath);

  /// 识别图片中的文字（结构化结果）
  ///
  /// [imagePath] 图片文件路径，返回 [OcrStructuredResult] 包含块、行、元素等详细信息。
  Future<OcrStructuredResult> recognizeStructured(String imagePath);

  /// 识别图片中的文字（Markdown 格式）
  ///
  /// [imagePath] 图片文件路径，返回 Markdown 格式的识别结果，按文本块分节输出。
  Future<String> recognizeAsMarkdown(String imagePath);

  /// 从二进制数据识别文字（纯文本）
  ///
  /// [bytes] 图片二进制数据，自动保存为临时文件后识别，识别完毕后删除临时文件。
  Future<String> recognizeImageFromBytes(Uint8List bytes);

  /// 从二进制数据识别文字（结构化结果）
  Future<OcrStructuredResult> recognizeStructuredFromBytes(Uint8List bytes);

  /// 从二进制数据识别文字（Markdown 格式）
  Future<String> recognizeAsMarkdownFromBytes(Uint8List bytes);
}
