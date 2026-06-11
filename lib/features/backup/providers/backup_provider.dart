// 备份功能 Provider
//
// 提供 Riverpod Provider 用于：
// - BackupService 实例的依赖注入
// - 备份列表的异步加载（backupListProvider）
// - 存储空间统计（backupStatsProvider）

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/backup/backup_service.dart';
import '../../../shared/theme/theme_provider.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(db);
});

/// 备份信息展示模型
///
/// 封装备份文件的元信息，提供格式化的文件大小和日期文本。
class BackupInfo {
  final String filePath;
  final String fileName;
  final int fileSize;
  final DateTime createdAt;
  final int? dealCount;

  BackupInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.createdAt,
    this.dealCount,
  });

  String get fileSizeText {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get dateText => DateFormat('yyyy-MM-dd HH:mm').format(createdAt);
}

final backupListProvider = FutureProvider<List<BackupInfo>>((ref) async {
  final service = ref.watch(backupServiceProvider);
  final files = await service.listBackups();

  final list = <BackupInfo>[];
  for (final file in files) {
    final stat = file.statSync();
    final info = await service.getBackupInfo(file.path);
    list.add(BackupInfo(
      filePath: file.path,
      fileName: file.path.split(Platform.pathSeparator).last,
      fileSize: stat.size,
      createdAt: stat.modified,
      dealCount: info?['dealCount'] as int?,
    ));
  }
  return list;
});

final backupStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(backupServiceProvider);
  final dbSize = await service.getDatabaseSize();
  final imgSize = await service.getImagesSize();
  final imgCount = await service.getImagesCount();
  return {
    'dbSize': dbSize,
    'imgSize': imgSize,
    'imgCount': imgCount,
    'totalSize': dbSize + imgSize,
  };
});
