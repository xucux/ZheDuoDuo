import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/daos/deal_dao.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/deals_provider.dart';

class DealDetailScreen extends ConsumerWidget {
  final String dealId;

  const DealDetailScreen({super.key, required this.dealId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealAsync = ref.watch(dealByIdProvider(dealId));

    return dealAsync.when(
      data: (dw) {
        if (dw == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('优惠详情')),
            body: const Center(child: Text('未找到该优惠记录')),
          );
        }
        return _buildContent(context, ref, dw);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('优惠详情')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('优惠详情')),
        body: Center(child: Text('加载失败: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DealWithDetails dw,
  ) {
    final deal = dw.deal;
    final theme = Theme.of(context);
    final platformColor = AppColors.getPlatformColor(deal.platform);
    final hasDiscount = deal.originalPrice != null &&
        deal.originalPrice! > deal.currentPrice;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image header
          SliverAppBar(
            expandedHeight: deal.visualType == 'image' ? 280 : 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: deal.visualType == 'image' && dw.image != null
                  ? GestureDetector(
                      onTap: () => _openImageViewer(context, dw.image!.imagePath),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            dw.image!.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black45],
                              ),
                            ),
                          ),
                          // 放大图标提示
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    )
                  : deal.visualType == 'ascii'
                      ? GestureDetector(
                          onTap: () => _openAsciiViewer(context, deal.asciiArt ?? ''),
                          child: Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            padding: const EdgeInsets.all(16),
                            child: Stack(
                              children: [
                                Center(
                                  child: SelectableText(
                                    deal.asciiArt ?? '',
                                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(Icons.fullscreen, color: Colors.white, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _buildPlaceholder(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/deal/${deal.id}/edit'),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'copy_link',
                    child: Text('复制链接'),
                  ),
                  const PopupMenuItem(
                    value: 'copy_title',
                    child: Text('复制标题'),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Text('分享'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('删除', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) => _handleMenuAction(context, ref, value, dw),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Platform + Category badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: platformColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          deal.platform,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: platformColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          deal.category,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    deal.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '到手价',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                deal.currency,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              Text(
                                deal.currentPrice.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                          if (hasDiscount) ...[
                            const Divider(height: 24),
                            Row(
                              children: [
                                Text(
                                  '原价: ${deal.currency}${deal.originalPrice!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.outline,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.discountBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    deal.discount ?? _calcDiscount(
                                      deal.originalPrice!,
                                      deal.currentPrice,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.discountText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (deal.displayPrice != null) ...[
                            const Divider(height: 24),
                            Row(
                              children: [
                                Text(
                                  '页面展示价',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${deal.currency}${deal.displayPrice!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Coupons
                  if (dw.coupons.isNotEmpty) ...[
                    _buildSectionTitle(context, '优惠券'),
                    ...dw.coupons.map((c) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${c.count}张',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              c.strength.isNotEmpty ? c.strength : '优惠券',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: c.source.isNotEmpty
                                ? Text(c.source)
                                : null,
                            trailing: c.note != null ? Text(c.note!) : null,
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],

                  // Promotions
                  if (dw.promotions.isNotEmpty) ...[
                    _buildSectionTitle(context, '促销权益'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: dw.promotions
                              .map((p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            p,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags
                  if (dw.tags.isNotEmpty) ...[
                    _buildSectionTitle(context, '标签'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dw.tags
                          .map((tag) => Chip(
                                label: Text(tag),
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Info section
                  _buildSectionTitle(context, '详细信息'),
                  Card(
                    child: Column(
                      children: [
                        if (deal.logistics != null)
                          _buildInfoRow(context, '物流', deal.logistics!),
                        _buildInfoRow(context, '创建时间',
                            DateFormat('yyyy-MM-dd HH:mm').format(deal.createdAt)),
                        _buildInfoRow(context, '更新时间',
                            DateFormat('yyyy-MM-dd HH:mm').format(deal.updatedAt)),
                        if (deal.link != null)
                          _buildInfoRow(context, '链接', deal.link!, isLink: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Note
                  if (deal.note != null && deal.note!.isNotEmpty) ...[
                    _buildSectionTitle(context, '备注'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          deal.note!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Sales info
                  if (deal.salesJson != null) ...[
                    _buildSectionTitle(context, '销量'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '30天销量: ${deal.salesJson}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: isLink
                  ? () async {
                      final uri = Uri.parse(value);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  : null,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isLink
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
          if (isLink)
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 18),
              onPressed: () async {
                final uri = Uri.parse(value);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
    );
  }

  String _calcDiscount(double original, double current) {
    if (original <= 0) return '';
    final discount = (current / original * 10).toStringAsFixed(1);
    return '${discount}折';
  }

  void _openImageViewer(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ImageViewerScreen(imagePath: imagePath),
      ),
    );
  }

  void _openAsciiViewer(BuildContext context, String asciiArt) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    const Text('ASCII 图', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () { Clipboard.setData(ClipboardData(text: asciiArt)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制'))); }),
                    IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(asciiArt, style: const TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    DealWithDetails dw,
  ) async {
    switch (action) {
      case 'copy_link':
        if (dw.deal.link != null) {
          await Clipboard.setData(ClipboardData(text: dw.deal.link!));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('链接已复制')),
            );
          }
        }
        break;
      case 'copy_title':
        await Clipboard.setData(ClipboardData(text: dw.deal.title));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('标题已复制')),
          );
        }
        break;
      case 'share':
        // TODO: Implement share
        break;
      case 'delete':
        _confirmDelete(context, ref, dw.deal.id);
        break;
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String dealId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条优惠记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final dealDao = ref.read(dealDaoProvider);
              await dealDao.softDeleteDeal(dealId);
              if (context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已删除')),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// 图片全屏查看器 - 支持双指缩放
class _ImageViewerScreen extends StatelessWidget {
  final String imagePath;

  const _ImageViewerScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white38, size: 64),
            ),
          ),
        ),
      ),
    );
  }
}
