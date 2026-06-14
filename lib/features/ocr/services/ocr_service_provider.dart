// OCR 服务工厂
//
// 根据当前运行平台自动选择合适的 OCR 实现类：
// - 移动端（Android / iOS）：使用 [MlKitOcrService]（Google ML Kit）
// - 桌面端（Windows / macOS / Linux）：使用 [DesktopOcrService]（Tesseract OCR）
//
// 使用方式：
// ```dart
// final ocrService = OcrServiceProvider.create();
// final text = await ocrService.recognizeImage(imagePath);
// ```

import 'dart:io';

import 'ocr_service_interface.dart';
import 'mlkit_ocr_service.dart';
import 'desktop_ocr_service.dart';

/// OCR 服务工厂类
///
/// 提供统一的工厂方法，根据当前平台创建对应的 OCR 服务实例。
/// 移动端使用 Google ML Kit，桌面端使用 Tesseract OCR。
class OcrServiceProvider {
  OcrServiceProvider._();

  /// 根据当前平台创建 OCR 服务实例
  ///
  /// - Android / iOS → [MlKitOcrService]
  /// - Windows / macOS / Linux → [DesktopOcrService]
  static OcrServiceBase create() {
    if (Platform.isAndroid || Platform.isIOS) {
      return MlKitOcrService();
    }
    // 桌面端：Windows / macOS / Linux
    return DesktopOcrService();
  }

  /// 判断当前平台是否支持 ML Kit OCR
  ///
  /// 返回 true 表示当前平台可以使用 Google ML Kit。
  static bool get isMlKitSupported => Platform.isAndroid || Platform.isIOS;

  /// 判断当前平台是否为桌面端
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
