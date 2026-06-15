// 本地备份页面
//
// 提供优惠数据的本地备份管理功能，包括：
// - 存储空间统计（数据库/图片大小）
// - 导出备份为 zip 文件
// - 从 zip 文件导入备份
// - 备份历史列表（查看详情/分享/删除）

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:restart_app/restart_app.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/image_compress.dart';
import '../../../core/utils/logger_util.dart';
import '../../../shared/theme/app_colors.dart';
import '../../deals/providers/deals_provider.dart';
import '../providers/backup_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backupsAsync = ref.watch(backupListProvider);
    final statsAsync = ref.watch(backupStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('本地备份')),
      body: ListView(
        children: [
          // Storage stats
          _buildStatsCard(context, statsAsync),
          const SizedBox(height: 12),

          // Export / Import buttons
          _buildActionButtons(context),
          const SizedBox(height: 20),

          // Backup history
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '备份历史',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          backupsAsync.when(
            data: (backups) {
              if (backups.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildBackupList(context, backups);
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text('加载失败: $e')),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, AsyncValue<Map<String, int>> statsAsync) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: statsAsync.when(
          data: (stats) {
            final dbSize = stats['dbSize'] ?? 0;
            final imgSize = stats['imgSize'] ?? 0;
            final imgCount = stats['imgCount'] ?? 0;
            final totalSize = stats['totalSize'] ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '存储空间',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatRow(context, '数据库', _formatSize(dbSize)),
                const SizedBox(height: 8),
                _buildStatRow(context, '图片', '${_formatSize(imgSize)}（$imgCount 张）'),
                const Divider(height: 24),
                _buildStatRow(context, '总计', _formatSize(totalSize), isBold: true),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _cleanupOrphanedImages(context),
                    icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                    label: const Text('清理未引用图片'),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('加载失败: $e'),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, {bool isBold = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isBold ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.upload_file,
              label: '导出备份',
              color: AppColors.brandColor,
              isLoading: _isExporting,
              onTap: _exportBackup,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.download,
              label: '导入备份',
              color: Theme.of(context).colorScheme.primary,
              isLoading: _isImporting,
              onTap: _importBackup,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.backup_outlined,
              size: 48,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              '暂无备份记录',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击「导出备份」创建第一个备份',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupList(BuildContext context, List<BackupInfo> backups) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: backups.length,
      itemBuilder: (context, index) {
        final backup = backups[index];
        return _buildBackupTile(context, backup);
      },
    );
  }

  Widget _buildBackupTile(BuildContext context, BackupInfo backup) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.brandColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.archive_outlined,
            color: AppColors.brandColor,
            size: 22,
          ),
        ),
        title: Text(
          backup.fileName,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${backup.dateText}  ·  ${backup.fileSizeText}${backup.dealCount != null ? '  ·  ${backup.dealCount}条' : ''}',
          style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, size: 18, color: theme.colorScheme.onSurfaceVariant),
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'restore', child: Text('恢复到此版本')),
            const PopupMenuItem(value: 'share', child: Text('分享')),
            const PopupMenuItem(value: 'delete', child: Text('删除', style: TextStyle(color: Colors.red))),
          ],
          onSelected: (value) => _handleBackupAction(context, value, backup),
        ),
        onTap: () => _showBackupInfo(context, backup),
      ),
    );
  }

  Future<void> _exportBackup() async {
    setState(() => _isExporting = true);

    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.exportBackup();

      if (mounted) {
        if (result.success) {
          ref.invalidate(backupListProvider);
          ref.invalidate(backupStatsProvider);

          _showSnackBar(
            '备份成功',
            action: SnackBarAction(
              label: '分享',
              onPressed: () {
                if (result.filePath != null) {
                  Share.shareXFiles([XFile(result.filePath!)]);
                }
              },
            ),
          );
        } else {
          _showSnackBar('备份失败: ${result.error}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('备份失败: $e');
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        dialogTitle: '选择备份文件',
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath == null) return;

      // Confirm import
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('导入备份'),
          content: const Text('导入将覆盖当前所有数据，确定继续吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确定导入', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() => _isImporting = true);

      final service = ref.read(backupServiceProvider);
      final importResult = await service.importBackup(filePath);

      if (mounted) {
        if (importResult.success) {
          _showRestartDialog('导入成功，共 ${importResult.dealCount ?? '?'} 条记录');
        } else {
          _showSnackBar('导入失败: ${importResult.error}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('导入失败: $e');
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _handleBackupAction(BuildContext context, String action, BackupInfo backup) {
    switch (action) {
      case 'restore':
        _restoreBackup(context, backup);
        break;
      case 'share':
        Share.shareXFiles([XFile(backup.filePath)]);
        break;
      case 'delete':
        _confirmDeleteBackup(context, backup);
        break;
    }
  }

  void _confirmDeleteBackup(BuildContext context, BackupInfo backup) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除备份'),
        content: Text('确定要删除备份 ${backup.fileName} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final service = ref.read(backupServiceProvider);
              final deleted = await service.deleteBackup(backup.filePath);
              if (deleted && mounted) {
                ref.invalidate(backupListProvider);
                _showSnackBar('已删除');
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup(BuildContext context, BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复备份'),
        content: const Text('恢复将覆盖当前所有数据，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确定恢复', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isImporting = true);

    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.importBackup(backup.filePath);

      if (mounted) {
        if (result.success) {
          _showRestartDialog('恢复成功，共 ${result.dealCount ?? '?'} 条记录');
        } else {
          _showSnackBar('恢复失败: ${result.error}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('恢复失败: $e');
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _showBackupInfo(BuildContext context, BackupInfo backup) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '备份详情',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('文件名', backup.fileName),
              _buildInfoRow('大小', backup.fileSizeText),
              _buildInfoRow('存储位置', backup.filePath, maxLines: 3),
              _buildInfoRow('创建时间', backup.dateText),
              if (backup.dealCount != null)
                _buildInfoRow('记录数', '${backup.dealCount} 条'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _restoreBackup(context, backup);
                      },
                      icon: const Icon(Icons.restore, size: 16),
                      label: const Text('恢复'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Share.shareXFiles([XFile(backup.filePath)]);
                      },
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('分享'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmDeleteBackup(context, backup);
                      },
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      label: const Text('删除', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _cleanupOrphanedImages(BuildContext context) async {
    final dealDao = ref.read(dealDaoProvider);
    final deletedEntries = await dealDao.getDeletedImagePaths();

    if (deletedEntries.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有需要清理的孤立图片')),
      );
      return;
    }

    int totalSize = 0;
    for (final e in deletedEntries) {
      final resolved = await ImageUtils.resolveImagePath(e.imagePath);
      final f = File(resolved);
      totalSize += f.existsSync() ? f.lengthSync() : 0;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清理未引用图片'),
        content: Text(
          '发现 ${deletedEntries.length} 个已标记删除的图片文件\n'
          '预计释放空间: ${ImageUtils.formatFileSize(totalSize)}\n\n'
          '此操作不可撤销，是否继续？',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('开始清理')),
        ],
      ),
    );
    if (confirmed != true) return;

    final paths = deletedEntries.map((e) => e.imagePath).toList();
    final result = await ImageUtils.cleanupOrphanedImages(paths);

    await dealDao.purgeDeletedImages();

    if (!context.mounted) return;
    AppLogger.instance.i('清理孤立图片: 删除${result.deletedCount}个文件，释放${ImageUtils.formatFileSize(result.freedBytes)}');

    ref.invalidate(backupStatsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已清理 ${result.deletedCount} 个孤立图片，释放 ${ImageUtils.formatFileSize(result.freedBytes)}')),
    );
  }

  void _showRestartDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('需要重启'),
        content: Text('$message\n\n数据库已替换，请重启应用以恢复数据连接。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('稍后再说'),
          ),
          FilledButton(
            onPressed: () => Restart.restartApp(),
            child: const Text('立即重启'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), action: action),
    );
  }
}
