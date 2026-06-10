// 图片压缩与存储工具
//
// 负责将用户选择的图片复制到应用图片目录，
// 并返回压缩结果信息（路径、尺寸、大小）。
// 实际图片压缩需在 UI 层通过 flutter_image_compress 等库完成。

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// 图片压缩结果
class ImageCompressResult {
  /// 压缩后的文件路径
  final String filePath;
  /// 图片宽度（压缩后）
  final int width;
  /// 图片高度（压缩后）
  final int height;
  /// 原始文件大小（字节）
  final int originalSize;
  /// 压缩后文件大小（字节）
  final int compressedSize;
  /// 压缩质量（0-100）
  final int quality;

  ImageCompressResult({
    required this.filePath,
    required this.width,
    required this.height,
    required this.originalSize,
    required this.compressedSize,
    required this.quality,
  });
}

/// 图片处理工具类
///
/// 提供图片目录获取、图片文件复制/准备、图片删除等静态方法。
class ImageUtils {
  static const _uuid = Uuid();
  /// 最大图片宽度（超过此宽度需压缩）
  static const int maxWidth = 800;
  /// 默认压缩质量
  static const int defaultQuality = 70;

  /// Get the images directory
  static Future<Directory> getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imgDir = Directory(p.join(appDir.path, 'zheduoduo_data', 'images'));
    if (!imgDir.existsSync()) {
      imgDir.createSync(recursive: true);
    }
    return imgDir;
  }

  /// Copy and prepare an image file for storage
  /// Note: For full compression, use flutter_image_compress_common in the UI layer
  static Future<ImageCompressResult?> prepareImage(
    File sourceFile, {
    String? dealId,
    int quality = defaultQuality,
  }) async {
    try {
      final imgDir = await getImagesDirectory();
      final id = dealId ?? _uuid.v4();
      final ext = p.extension(sourceFile.path).toLowerCase();
      final targetPath = p.join(imgDir.path, '$id${ext.isEmpty ? '.jpg' : ext}');

      final originalSize = await sourceFile.length();

      // Copy file to images directory
      final targetFile = await sourceFile.copy(targetPath);
      final compressedSize = await targetFile.length();

      return ImageCompressResult(
        filePath: targetPath,
        width: 0,
        height: 0,
        originalSize: originalSize,
        compressedSize: compressedSize,
        quality: quality,
      );
    } catch (e) {
      return null;
    }
  }

  /// Delete an image file
  static Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
