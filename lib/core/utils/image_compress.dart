// 图片压缩与存储工具
//
// 负责将用户选择的图片压缩后保存到应用图片目录，
// 并返回压缩结果信息（路径、尺寸、大小）。
// 使用 flutter_image_compress 执行实际压缩，压缩参数从数据库配置读取。

import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../database/daos/image_compress_settings_dao.dart';

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

  /// 压缩率百分比（如 65 表示压缩后体积为原来的 65%）
  double get compressionRatio =>
      originalSize > 0 ? (compressedSize / originalSize * 100) : 100;
}

/// 图片处理工具类
///
/// 提供图片目录获取、图片压缩/存储、图片删除等静态方法。
/// 压缩时根据文件大小从 ImageCompressSettings 表匹配对应档位的压缩参数。
class ImageUtils {
  static const _uuid = Uuid();

  /// 获取存储根目录（Android 使用应用外部私有目录）
  static Future<Directory> getRootDir() async {
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return externalDir;
      }
    }
    return getApplicationDocumentsDirectory();
  }

  /// 将数据库中存储的图片路径解析为当前设备的绝对路径
  ///
  /// 新版数据存储相对路径（如 `images/xxx.jpg`），
  /// 旧版数据可能存储了绝对路径，保持兼容。
  static Future<String> resolveImagePath(String path) async {
    if (path.contains(':\\') || path.startsWith('/') || path.startsWith('\\')) {
      return path;
    }
    final imgDir = await getImagesDirectory();
    return p.join(imgDir.path, p.basename(path));
  }

  /// 获取图片存储目录
  static Future<Directory> getImagesDirectory() async {
    final rootDir = await getRootDir();
    final imgDir = Directory(p.join(rootDir.path, 'zheduoduo_data', 'images'));
    if (!imgDir.existsSync()) {
      imgDir.createSync(recursive: true);
    }
    return imgDir;
  }

  /// 压缩并保存图片到应用图片目录
  ///
  /// 根据 [compressDao] 中按文件大小分档的配置自动选择压缩参数。
  /// 压缩流程：
  /// 1. 读取原始文件大小，从数据库匹配压缩档位（quality、maxWidth）
  /// 2. 使用 flutter_image_compress 执行 JPEG 压缩
  /// 3. 将压缩结果写入图片目录
  ///
  /// [sourceFile] 原始图片文件
  /// [compressDao] 压缩配置 DAO，用于读取分档配置
  /// [dealId] 可选，关联优惠 ID，用作文件名
  static Future<ImageCompressResult?> prepareImage(
    File sourceFile, {
    String? dealId,
    required ImageCompressSettingsDao compressDao,
  }) async {
    try {
      final imgDir = await getImagesDirectory();
      final id = dealId ?? _uuid.v4();
      final targetPath = p.join(imgDir.path, '$id.jpg');

      final originalSize = await sourceFile.length();

      // flutter_image_compress 不支持 Windows/Linux，直接复制
      if (Platform.isWindows || Platform.isLinux) {
        final targetFile = await sourceFile.copy(targetPath);
        final copiedSize = await targetFile.length();
        return ImageCompressResult(
          filePath: targetPath,
          width: 0,
          height: 0,
          originalSize: originalSize,
          compressedSize: copiedSize,
          quality: 100,
        );
      }

      // 从数据库获取匹配当前文件大小的压缩配置
      final setting = await compressDao.getSettingForSize(originalSize);
      final quality = setting.quality;
      final maxWidth = setting.maxWidth > 0 ? setting.maxWidth : 1600;

      // 使用 flutter_image_compress 压缩
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        sourceFile.absolute.path,
        minWidth: maxWidth,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (compressedBytes == null) {
        // 压缩失败，回退到直接复制
        final targetFile = await sourceFile.copy(targetPath);
        final copiedSize = await targetFile.length();
        return ImageCompressResult(
          filePath: targetPath,
          width: 0,
          height: 0,
          originalSize: originalSize,
          compressedSize: copiedSize,
          quality: 100,
        );
      }

      // 写入压缩后的数据
      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(compressedBytes);

      return ImageCompressResult(
        filePath: targetPath,
        width: 0,
        height: 0,
        originalSize: originalSize,
        compressedSize: compressedBytes.length,
        quality: quality,
      );
    } catch (e) {
      return null;
    }
  }

  /// 删除图片文件
  static Future<void> deleteImage(String imagePath) async {
    final resolved = await resolveImagePath(imagePath);
    final file = File(resolved);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// 清理已标记删除的图片文件
  ///
  /// [deletedImages] 数据库中 deleted != 0 的图片路径列表。
  /// 删除本地文件后返回 (deletedCount, freedBytes)。
  static Future<({int deletedCount, int freedBytes})> cleanupOrphanedImages(
    List<String> imagePaths,
  ) async {
    int deletedCount = 0;
    int freedBytes = 0;

    for (final path in imagePaths) {
      final resolved = await resolveImagePath(path);
      final file = File(resolved);
      if (file.existsSync()) {
        freedBytes += await file.length();
        await file.delete();
        deletedCount++;
      }
    }

    return (deletedCount: deletedCount, freedBytes: freedBytes);
  }

  /// 格式化文件大小为可读字符串
  ///
  /// 例如：1024 → "1.0 KB"，1048576 → "1.0 MB"
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
