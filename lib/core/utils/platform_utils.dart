// 平台适配工具
//
// 提供跨平台差异的统一处理方法，包括：
// - 判断当前平台是否为桌面端
// - 判断是否支持摄像头拍照
// - 获取图片（自动适配相册/文件选择器/摄像头）
// - 平台特定的 UI 适配建议
//
// 使用条件编译和 Platform API 实现平台分支，
// 不修改移动端原有逻辑，仅对桌面端做降级处理。

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// 平台适配工具类
///
/// 封装移动端/桌面端的差异逻辑，调用方无需关心平台细节。
class PlatformUtils {
  PlatformUtils._();

  /// 判断当前平台是否为桌面端（Windows / macOS / Linux）
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// 判断当前平台是否为移动端（Android / iOS）
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// 判断当前平台是否支持摄像头拍照
  ///
  /// 桌面端一般无摄像头或摄像头支持有限，返回 false。
  static bool get isCameraSupported => isMobile;

  /// 从相册/文件选择器选择图片
  ///
  /// - 移动端：使用 [ImagePicker] 从相册选择
  /// - 桌面端：使用 [FilePicker] 选择图片文件
  ///
  /// 返回选中图片的路径，未选择返回 null。
  static Future<String?> pickImageFromGallery() async {
    if (isMobile) {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: ImageSource.gallery);
      return xFile?.path;
    }

    // 桌面端：使用文件选择器
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      return result.files.single.path;
    }
    return null;
  }

  /// 使用摄像头拍照
  ///
  /// - 移动端：使用 [ImagePicker] 调用摄像头
  /// - 桌面端：不支持拍照，回退到文件选择器
  ///
  /// 返回拍摄/选中图片的路径，未选择返回 null。
  static Future<String?> pickImageFromCamera() async {
    if (isMobile) {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: ImageSource.camera);
      return xFile?.path;
    }

    // 桌面端无摄像头，回退到文件选择器
    return pickImageFromGallery();
  }

  /// 通用图片选择方法
  ///
  /// 根据 [source] 自动选择平台适配的图片获取方式：
  /// - [ImageSource.gallery]：相册 / 文件选择器
  /// - [ImageSource.camera]：摄像头 / 文件选择器（桌面端回退）
  ///
  /// 返回选中图片的路径，未选择返回 null。
  static Future<String?> pickImage(ImageSource source) async {
    switch (source) {
      case ImageSource.gallery:
        return pickImageFromGallery();
      case ImageSource.camera:
        return pickImageFromCamera();
    }
  }
}
