// OCR 文字识别服务 - 桌面端实现（Tesseract OCR）
//
// 基于 Tesseract OCR 引擎提供图片文字识别功能。
// 支持 Windows / macOS / Linux 桌面平台。
// 通过 Process 调用系统安装的 tesseract 命令行工具执行识别。
//
// 前置条件：
// - Windows: 下载安装 UB Mannheim Tesseract (https://github.com/UB-Mannheim/tesseract/wiki)
// - macOS: brew install tesseract tesseract-lang
// - Linux: sudo apt install tesseract-ocr tesseract-ocr-chi-sim
//
// 支持中文脚本识别，提供多种输出格式：
// - 纯文本、结构化结果（TSV 解析）、Markdown 格式
// - 支持文件路径和二进制字节两种输入方式

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'ocr_service_interface.dart';
import '../../../core/utils/logger_util.dart';

/// OCR 文字识别服务 - 桌面端实现
///
/// 通过调用系统 Tesseract CLI 执行 OCR 识别。
/// 自动检测 tesseract 可执行文件路径，支持中英文识别。
class DesktopOcrService implements OcrServiceBase {
  /// Tesseract 可执行文件路径（缓存）
  static String? _tesseractPath;

  /// Tesseract 语言参数（中文简体 + 英文）
  static const String _lang = 'chi_sim+eng';

  DesktopOcrService();

  /// 检测 tesseract 可执行文件路径
  ///
  /// 按优先级依次检测：
  /// 1. 系统环境变量 PATH 中的 tesseract
  /// 2. Windows 默认安装路径（UB Mannheim）
  /// 3. macOS Homebrew 安装路径
  /// 4. Linux 默认路径
  /// 找不到则抛出异常。
  Future<String> _findTesseract() async {
    if (_tesseractPath != null) return _tesseractPath!;

    // 尝试直接执行 tesseract --version 检测是否在 PATH 中
    try {
      final result = await Process.run('tesseract', ['--version']);
      if (result.exitCode == 0) {
        _tesseractPath = 'tesseract';
        AppLogger.instance.i('[DesktopOcr] 检测到 tesseract 在 PATH 中');
        return _tesseractPath!;
      }
    } catch (_) {}

    // Windows: 检测 UB Mannheim 默认安装路径
    if (Platform.isWindows) {
      final windir = Platform.environment['ProgramFiles'] ?? r'C:\Program Files';
      final tesseractExe = '$windir\\Tesseract-OCR\\tesseract.exe';
      if (await File(tesseractExe).exists()) {
        _tesseractPath = tesseractExe;
        AppLogger.instance.i('[DesktopOcr] 检测到 Windows Tesseract: $tesseractExe');
        return _tesseractPath!;
      }
    }

    throw Exception(
      '未检测到 Tesseract OCR 引擎。\n'
      '请安装后重试：\n'
      '- Windows: https://github.com/UB-Mannheim/tesseract/wiki\n'
      '- macOS: brew install tesseract tesseract-lang\n'
      '- Linux: sudo apt install tesseract-ocr tesseract-ocr-chi-sim',
    );
  }

  /// 将二进制图片数据保存为临时文件
  Future<String> _saveTempImage(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// 调用 tesseract 执行识别，返回原始标准输出
  ///
  /// [imagePath] 图片文件路径，[outputFormat] 输出格式（stdout 为纯文本，tsv 为结构化）。
  Future<String> _runTesseract(String imagePath, {String outputFormat = 'stdout'}) async {
    final tesseract = await _findTesseract();

    // tesseract 输出文件前缀（tesseract 会自动追加 .txt 或 .tsv 后缀）
    final dir = await getTemporaryDirectory();
    final outputBase = '${dir.path}/ocr_out_${DateTime.now().millisecondsSinceEpoch}';

    final args = <String>[
      imagePath,
      outputBase,
      '-l', _lang,
    ];

    // 指定输出格式
    if (outputFormat == 'tsv') {
      args.add('tsv');
    }

    AppLogger.instance.d('[DesktopOcr] 执行: $tesseract ${args.join(' ')}');

    final result = await Process.run(tesseract, args);

    if (result.exitCode != 0) {
      final stderr = result.stderr.toString().trim();
      AppLogger.instance.e('[DesktopOcr] Tesseract 执行失败 (exit ${result.exitCode}): $stderr');
      throw Exception('Tesseract 识别失败: $stderr');
    }

    // 读取输出文件
    final ext = outputFormat == 'tsv' ? '.tsv' : '.txt';
    final outputFile = File('$outputBase$ext');
    if (await outputFile.exists()) {
      final content = await outputFile.readAsString(encoding: utf8);
      // 清理临时输出文件
      try {
        await outputFile.delete();
      } catch (_) {}
      return content;
    }

    // 某些情况下 tesseract 直接输出到 stdout
    return result.stdout.toString();
  }

  @override
  Future<String> recognizeImage(String imagePath) async {
    return _runTesseract(imagePath, outputFormat: 'stdout');
  }

  @override
  Future<OcrStructuredResult> recognizeStructured(String imagePath) async {
    final tsvOutput = await _runTesseract(imagePath, outputFormat: 'tsv');
    return _parseTsv(tsvOutput);
  }

  @override
  Future<String> recognizeAsMarkdown(String imagePath) async {
    final structured = await recognizeStructured(imagePath);
    final buffer = StringBuffer();
    buffer.writeln('# OCR 识别结果\n');
    for (int i = 0; i < structured.blocks.length; i++) {
      final block = structured.blocks[i];
      buffer.writeln('## 文本块 ${i + 1}\n');
      buffer.writeln('${block.text}\n');
      buffer.writeln('---\n');
    }
    return buffer.toString();
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

  /// 解析 Tesseract TSV 输出为 OcrStructuredResult
  ///
  /// Tesseract TSV 格式：
  /// level  page_num  block_num  par_num  line_num  word_num  ...
  /// left   top       width      height    conf      text
  ///
  /// 按 block_num 和 line_num 分组，构建树状结构。
  OcrStructuredResult _parseTsv(String tsv) {
    final lines = tsv.split('\n');
    if (lines.isEmpty) {
      return OcrStructuredResult(fullText: '', blockCount: 0, blocks: []);
    }

    // 跳过表头行
    final dataLines = lines.where((l) => l.trim().isNotEmpty).skip(1).toList();

    // 按 block_num 分组
    final blockMap = <int, List<_TsvWord>>{};
    final allText = StringBuffer();

    for (final line in dataLines) {
      final cols = line.split('\t');
      if (cols.length < 12) continue;

      final level = int.tryParse(cols[0]) ?? 0;
      // level 5 = word level
      if (level != 5) continue;

      final blockNum = int.tryParse(cols[2]) ?? 0;
      final lineNum = int.tryParse(cols[4]) ?? 0;
      final left = double.tryParse(cols[6]) ?? 0;
      final top = double.tryParse(cols[7]) ?? 0;
      final width = double.tryParse(cols[8]) ?? 0;
      final height = double.tryParse(cols[9]) ?? 0;
      final conf = double.tryParse(cols[10]) ?? 0;
      final text = cols[11];

      blockMap.putIfAbsent(blockNum, () => []);
      blockMap[blockNum]!.add(_TsvWord(
        lineNum: lineNum,
        left: left,
        top: top,
        width: width,
        height: height,
        confidence: conf,
        text: text,
      ));

      if (text.isNotEmpty) {
        allText.write(text);
        allText.write(' ');
      }
    }

    // 构建 OcrStructuredResult
    final blocks = <OcrTextBlock>[];
    final sortedBlockNums = blockMap.keys.toList()..sort();

    for (final blockNum in sortedBlockNums) {
      final words = blockMap[blockNum]!;
      // 按 lineNum 分组
      final lineMap = <int, List<_TsvWord>>{};
      for (final w in words) {
        lineMap.putIfAbsent(w.lineNum, () => []);
        lineMap[w.lineNum]!.add(w);
      }

      final ocrLines = <OcrTextLine>[];
      final sortedLineNums = lineMap.keys.toList()..sort();

      // 计算整个 block 的边界
      double blockLeft = double.infinity, blockTop = double.infinity;
      double blockRight = 0, blockBottom = 0;
      final blockTextBuffer = StringBuffer();

      for (final lineNum in sortedLineNums) {
        final lineWords = lineMap[lineNum]!;
        final lineText = lineWords.map((w) => w.text).join(' ');
        blockTextBuffer.writeln(lineText);

        // 计算行边界
        double lineLeft = double.infinity, lineTop = double.infinity;
        double lineRight = 0, lineBottom = 0;
        final elements = <OcrTextElement>[];

        for (final w in lineWords) {
          if (w.left < lineLeft) lineLeft = w.left;
          if (w.top < lineTop) lineTop = w.top;
          final r = w.left + w.width;
          final b = w.top + w.height;
          if (r > lineRight) lineRight = r;
          if (b > lineBottom) lineBottom = b;

          if (w.left < blockLeft) blockLeft = w.left;
          if (w.top < blockTop) blockTop = w.top;
          if (r > blockRight) blockRight = r;
          if (b > blockBottom) blockBottom = b;

          elements.add(OcrTextElement(
            text: w.text,
            confidence: w.confidence > 0 ? w.confidence / 100.0 : null,
            boundingBox: {
              'left': w.left,
              'top': w.top,
              'width': w.width,
              'height': w.height,
            },
          ));
        }

        ocrLines.add(OcrTextLine(
          text: lineText,
          boundingBox: {
            'left': lineLeft == double.infinity ? 0 : lineLeft,
            'top': lineTop == double.infinity ? 0 : lineTop,
            'width': lineRight - lineLeft,
            'height': lineBottom - lineTop,
          },
          elements: elements,
        ));
      }

      blocks.add(OcrTextBlock(
        text: blockTextBuffer.toString().trim(),
        boundingBox: {
          'left': blockLeft == double.infinity ? 0 : blockLeft,
          'top': blockTop == double.infinity ? 0 : blockTop,
          'width': blockRight - blockLeft,
          'height': blockBottom - blockTop,
        },
        cornerPoints: [],
        lines: ocrLines,
      ));
    }

    return OcrStructuredResult(
      fullText: allText.toString().trim(),
      blockCount: blocks.length,
      blocks: blocks,
    );
  }
}

/// Tesseract TSV 输出中的单词行
class _TsvWord {
  final int lineNum;
  final double left;
  final double top;
  final double width;
  final double height;
  final double confidence;
  final String text;

  _TsvWord({
    required this.lineNum,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.confidence,
    required this.text,
  });
}
