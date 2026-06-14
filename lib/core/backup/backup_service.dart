// 本地备份服务
//
// 负责优惠数据的导出/导入/管理，包括：
// - 导出备份为 zip（包含数据库、图片、manifest）
// - 从 zip 导入备份（覆盖当前数据）
// - 列出/删除/查询备份文件
// - 统计数据库和图片的存储大小

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../database/daos/deal_dao.dart';

/// 备份操作结果
class BackupResult {
  /// 是否成功
  final bool success;
  /// 备份文件路径（成功时）
  final String? filePath;
  /// 备份文件大小（字节）
  final int? fileSize;
  /// 包含的优惠记录数
  final int? dealCount;
  /// 错误信息（失败时）
  final String? error;

  BackupResult.success({this.filePath, this.fileSize, this.dealCount})
      : success = true,
        error = null;

  BackupResult.failure(this.error)
      : success = false,
        filePath = null,
        fileSize = null,
        dealCount = null;
}

/// 本地备份服务
///
/// 提供优惠数据的 zip 格式导出/导入，以及备份文件管理。
/// 数据存储在外部存储（Android）或应用文档目录的 zheduoduo_data/ 下。
class BackupService {
  AppDatabase _db;

  BackupService(this._db);

  /// 获取存储根目录（Android 使用应用外部私有目录）
  Future<Directory> _getRootDir() async {
    if (Platform.isAndroid) {
      // getExternalStorageDirectory() 已返回 /storage/emulated/0/Android/data/<package>/files/
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return externalDir;
      }
    }
    return getApplicationDocumentsDirectory();
  }

  /// 获取数据库文件的实际路径
  Future<String> _getDbFilePath() async {
    final rootDir = await _getRootDir();
    // drift_flutter 存储在 rootDir/zheduoduo_data/zheduoduo.sqlite
    return p.join(rootDir.path, 'zheduoduo_data', 'zheduoduo.sqlite');
  }

  /// 获取数据根目录
  Future<Directory> _getDataDir() async {
    final rootDir = await _getRootDir();
    final dataDir = Directory(p.join(rootDir.path, 'zheduoduo_data'));
    if (!dataDir.existsSync()) {
      dataDir.createSync(recursive: true);
    }
    return dataDir;
  }

  /// 获取备份目录
  Future<Directory> _getBackupsDir() async {
    final rootDir = await _getRootDir();
    final backupDir = Directory(p.join(rootDir.path, 'zheduoduo_data', 'backups'));
    if (!backupDir.existsSync()) {
      backupDir.createSync(recursive: true);
    }
    return backupDir;
  }

  /// 获取图片目录
  Future<Directory> _getImagesDir() async {
    final rootDir = await _getRootDir();
    final imgDir = Directory(p.join(rootDir.path, 'zheduoduo_data', 'images'));
    if (!imgDir.existsSync()) {
      imgDir.createSync(recursive: true);
    }
    return imgDir;
  }

  /// 导出备份为 zip
  Future<BackupResult> exportBackup({String? customPath}) async {
    try {
      final dbPath = await _getDbFilePath();
      final dbFile = File(dbPath);

      developer.log('数据库路径: $dbPath', name: 'BackupService');
      developer.log('数据库文件存在: ${dbFile.existsSync()}', name: 'BackupService');

      // 列出数据目录下的文件
      final dataDir = await _getDataDir();
      if (dataDir.existsSync()) {
        final files = dataDir.listSync();
        developer.log('数据目录文件: ${files.map((f) => f.path).toList()}', name: 'BackupService');
      }

      if (!dbFile.existsSync()) {
        return BackupResult.failure('数据库文件不存在: $dbPath');
      }

      // 统计 deals 数量
      final dealDao = DealDao(_db);
      final dealCount = await dealDao.countDeals();

      // 创建压缩包
      final archive = Archive();

      // 添加数据库文件
      final dbBytes = await dbFile.readAsBytes();
      archive.addFile(ArchiveFile('zheduoduo.sqlite', dbBytes.length, dbBytes));

      // 添加图片目录
      final imagesDir = await _getImagesDir();
      if (imagesDir.existsSync()) {
        await for (final entity in imagesDir.list()) {
          if (entity is File) {
            final bytes = await entity.readAsBytes();
            final fileName = p.basename(entity.path);
            archive.addFile(ArchiveFile('images/$fileName', bytes.length, bytes));
          }
        }
      }

      // 添加 manifest
      final manifest = jsonEncode({
        'version': '1.0.0',
        'createdAt': DateTime.now().toIso8601String(),
        'dealCount': dealCount,
        'platform': Platform.operatingSystem,
      });
      final manifestBytes = utf8.encode(manifest);
      archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));

      // 压缩
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) {
        return BackupResult.failure('压缩失败');
      }

      // 保存文件
      String filePath;
      if (customPath != null) {
        filePath = customPath;
      } else {
        final backupDir = await _getBackupsDir();
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        filePath = p.join(backupDir.path, 'backup_$timestamp.zip');
      }

      final file = File(filePath);
      await file.writeAsBytes(zipBytes);

      developer.log('备份成功: $filePath', name: 'BackupService');

      return BackupResult.success(
        filePath: filePath,
        fileSize: zipBytes.length,
        dealCount: dealCount,
      );
    } catch (e, stack) {
      developer.log('备份失败', name: 'BackupService', error: e, stackTrace: stack);
      return BackupResult.failure('导出失败: $e');
    }
  }

  /// 从 zip 导入备份
  Future<BackupResult> importBackup(String zipPath) async {
    try {
      final zipFile = File(zipPath);
      if (!zipFile.existsSync()) {
        return BackupResult.failure('备份文件不存在');
      }

      final zipBytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipBytes);

      final dataDir = await _getDataDir();
      final imagesDir = await _getImagesDir();

      // 关闭数据库再替换
      await _db.close();

      int? dealCount;

      for (final file in archive) {
        final fileName = file.name;

        if (fileName == 'zheduoduo.sqlite' || fileName == 'zheduoduo.db') {
          final dbPath = p.join(dataDir.path, 'zheduoduo.sqlite');
          await File(dbPath).writeAsBytes(file.content as List<int>);
        } else if (fileName.startsWith('images/') && file.isFile) {
          final imgName = fileName.substring(7);
          if (imgName.isNotEmpty) {
            await File(p.join(imagesDir.path, imgName)).writeAsBytes(file.content as List<int>);
          }
        } else if (fileName == 'manifest.json') {
          try {
            final manifestStr = utf8.decode(file.content as List<int>);
            final manifest = jsonDecode(manifestStr) as Map<String, dynamic>;
            dealCount = manifest['dealCount'] as int?;
          } catch (_) {}
        }
      }

      return BackupResult.success(
        filePath: zipPath,
        fileSize: zipBytes.length,
        dealCount: dealCount,
      );
    } catch (e, stack) {
      developer.log('导入失败', name: 'BackupService', error: e, stackTrace: stack);
      return BackupResult.failure('导入失败: $e');
    }
  }

  /// 列出所有备份
  Future<List<FileSystemEntity>> listBackups() async {
    final backupDir = await _getBackupsDir();
    if (!backupDir.existsSync()) return [];

    final files = backupDir.listSync().where((f) => f.path.endsWith('.zip')).toList();
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return files;
  }

  /// 删除备份
  Future<bool> deleteBackup(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 获取备份信息
  Future<Map<String, dynamic>?> getBackupInfo(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      String? manifestStr;
      for (final f in archive) {
        if (f.name == 'manifest.json') {
          manifestStr = utf8.decode(f.content as List<int>);
          break;
        }
      }

      if (manifestStr != null) {
        return jsonDecode(manifestStr) as Map<String, dynamic>;
      }

      return {'fileSize': bytes.length, 'createdAt': file.statSync().modified.toIso8601String()};
    } catch (_) {
      return null;
    }
  }

  /// 获取图片目录大小
  Future<int> getImagesSize() async {
    final imagesDir = await _getImagesDir();
    if (!imagesDir.existsSync()) return 0;

    int totalSize = 0;
    await for (final entity in imagesDir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  /// 获取图片文件数量
  Future<int> getImagesCount() async {
    final imagesDir = await _getImagesDir();
    if (!imagesDir.existsSync()) return 0;

    int count = 0;
    await for (final entity in imagesDir.list()) {
      if (entity is File) count++;
    }
    return count;
  }

  /// 获取数据库文件大小
  Future<int> getDatabaseSize() async {
    final dbPath = await _getDbFilePath();
    final dbFile = File(dbPath);
    if (!dbFile.existsSync()) return 0;
    return await dbFile.length();
  }
}
