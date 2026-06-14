import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/database/daos/deal_dao.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/deals_provider.dart';

class DealListScreen extends ConsumerStatefulWidget {
  const DealListScreen({super.key});

  @override
  ConsumerState<DealListScreen> createState() => _DealListScreenState();
}

class _DealListScreenState extends ConsumerState<DealListScreen> {
  @override
  Widget build(BuildContext context) {
    final dealsAsync = ref.watch(dealsProvider);
    final filters = ref.watch(dealFiltersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, filters, dealsAsync),
            _buildQuickFilters(context, filters),
            Expanded(
              child: dealsAsync.when(
                data: (deals) {
                  if (deals.isEmpty) return _buildEmptyState(context);
                  return _buildDealList(context, deals, filters.displayMode);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('加载失败: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  // ===== Header =====
  Widget _buildHeader(BuildContext context, DealFilters filters, AsyncValue<List<DealWithDetails>> dealsAsync) {
    final theme = Theme.of(context);
    final count = dealsAsync.whenOrNull(data: (d) => d.length) ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: theme.colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('优惠清单', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 2),
              Text('共 $count 条', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          Row(
            children: [
              _buildHeaderIcon(context, icon: filters.displayMode == 'grid' ? Icons.view_agenda_outlined : Icons.grid_view_outlined, onTap: () => ref.read(dealFiltersProvider.notifier).setDisplayMode(filters.displayMode == 'grid' ? 'normal' : 'grid')),
              const SizedBox(width: 4),
              _buildHeaderIcon(context, icon: Icons.search, onTap: () => context.push('/search')),
              const SizedBox(width: 4),
              _buildHeaderIcon(context, icon: Icons.tune, onTap: () => _showFilterSheet(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  // ===== Quick Filters =====
  Widget _buildQuickFilters(BuildContext context, DealFilters filters) {
    final theme = Theme.of(context);
    return Container(
      height: 44,
      color: theme.colorScheme.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _buildQuickChip(context, label: '全部', selected: filters.platform == null && filters.category == null && filters.tag == null, onTap: () => ref.read(dealFiltersProvider.notifier).reset()),
          const SizedBox(width: 8),
          _buildQuickChip(context, label: filters.platform ?? '平台', selected: filters.platform != null, onTap: () => _showPlatformPicker(context)),
          const SizedBox(width: 8),
          _buildQuickChip(context, label: filters.category ?? '分类', selected: filters.category != null, onTap: () => _showCategoryPicker(context)),
          const SizedBox(width: 8),
          _buildQuickChip(context, label: filters.tag ?? '标签', selected: filters.tag != null, onTap: () => _showTagPicker(context)),
          const SizedBox(width: 8),
          _buildQuickChip(context, label: _getSortLabel(filters.sortBy), selected: filters.sortBy != 'created_at', onTap: () => _showSortPicker(context)),
        ],
      ),
    );
  }

  Widget _buildQuickChip(BuildContext context, {required String label, required bool selected, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: selected ? AppColors.brandColor : theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant)),
      ),
    );
  }

  // ===== Empty State =====
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 56, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Text('暂无优惠记录', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push('/deal/new'),
            child: Text('+ 添加第一条', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.brandColor)),
          ),
        ],
      ),
    );
  }

  // ===== Deal List =====
  Widget _buildDealList(BuildContext context, List<DealWithDetails> deals, String displayMode) {
    if (displayMode == 'grid') {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1.3,
        ),
        itemCount: deals.length,
        itemBuilder: (context, index) => _buildGridDealCard(context, deals[index]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      itemCount: deals.length,
      itemBuilder: (context, index) {
        final dw = deals[index];
        return _buildNormalDealCard(context, dw);
      },
    );
  }

  // ===== Normal Card =====
  Widget _buildNormalDealCard(BuildContext context, DealWithDetails dw) {
    final deal = dw.deal;
    final theme = Theme.of(context);
    final hasDiscount = deal.originalPrice != null && deal.originalPrice! > deal.currentPrice;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        key: ValueKey(deal.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(onPressed: (_) => context.push('/deal/${deal.id}/edit'), backgroundColor: Colors.blue, foregroundColor: Colors.white, icon: Icons.edit, label: '编辑'),
            SlidableAction(onPressed: (_) => _confirmDelete(context, deal.id), backgroundColor: Colors.red, foregroundColor: Colors.white, icon: Icons.delete, label: '删除'),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5), width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/deal/${deal.id}'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Visual badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(deal.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3, color: theme.colorScheme.onSurface)),
                      ),
                      if (deal.visualType != 'none') ...[const SizedBox(width: 6), _buildVisualBadge(context, deal.visualType)],
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Platform + Tags + Coupon + Price
                  Row(
                    children: [
                      _buildPlatformBadge(context, deal.platform),
                      const SizedBox(width: 4),
                      ...dw.tags.take(2).map((t) => Padding(padding: const EdgeInsets.only(right: 4), child: _buildTag(context, t))),
                      if (dw.coupons.isNotEmpty) ...[const SizedBox(width: 2), _buildCouponBadge(context, dw.coupons.length)],
                      const Spacer(),
                      Text('${deal.currency}${deal.currentPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.brandColor)),
                      if (hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text('${deal.currency}${deal.originalPrice!.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline, decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(color: AppColors.discountBg, borderRadius: BorderRadius.circular(3)),
                          child: Text(deal.discount ?? _calcDiscount(deal.originalPrice!, deal.currentPrice), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.discountText)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 创建时间 + 史低标识
                  Row(
                    children: [
                      Text(
                        _formatDateShort(deal.createdAt),
                        style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
                      ),
                      const Spacer(),
                      if (deal.isLowestPrice == 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            '史低',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== Grid Card (2-column) =====
  Widget _buildGridDealCard(BuildContext context, DealWithDetails dw) {
    final deal = dw.deal;
    final theme = Theme.of(context);
    final hasDiscount = deal.originalPrice != null && deal.originalPrice! > deal.currentPrice;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/deal/${deal.id}'),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(deal.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.3, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 4),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 左侧：平台、券、价格
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              _buildPlatformBadge(context, deal.platform),
                              if (dw.coupons.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Text('券x${dw.coupons.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFE65100))),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${deal.currency}${deal.currentPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.brandColor)),
                              if (hasDiscount) ...[
                                const SizedBox(width: 4),
                                Text('${deal.currency}${deal.originalPrice!.toStringAsFixed(0)}', style: TextStyle(fontSize: 10, color: theme.colorScheme.outline, decoration: TextDecoration.lineThrough)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 右侧：缩略图或缩略 ASCII
                    if (dw.image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          File(dw.image!.imagePath),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(width: 48, height: 48),
                        ),
                      )
                    else if (deal.asciiArt != null && deal.asciiArt!.isNotEmpty)
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          deal.asciiArt!,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 5,
                            height: 1.0,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helper Widgets =====
  Widget _buildVisualBadge(BuildContext context, String visualType) {
    final theme = Theme.of(context);
    IconData icon; String text; Color bgColor; Color fgColor;
    switch (visualType) {
      case 'image': icon = Icons.image_outlined; text = '有图'; bgColor = theme.colorScheme.primaryContainer; fgColor = theme.colorScheme.onPrimaryContainer; break;
      case 'ascii': icon = Icons.code; text = 'ASCII'; bgColor = theme.colorScheme.tertiaryContainer; fgColor = theme.colorScheme.onTertiaryContainer; break;
      default: return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: fgColor),
        const SizedBox(width: 2),
        Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fgColor)),
      ]),
    );
  }

  Widget _buildPlatformBadge(BuildContext context, String platform) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AppColors.brandColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(3)),
      child: Text(platform, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.brandColor)),
    );
  }

  Widget _buildTag(BuildContext context, String tag) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(3)),
      child: Text(tag, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
    );
  }

  Widget _buildCouponBadge(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(3)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.confirmation_num_outlined, size: 10, color: Color(0xFFE65100)),
        const SizedBox(width: 2),
        Text('$count 张券', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFE65100))),
      ]),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push('/deal/new'),
      backgroundColor: AppColors.brandColor,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add, size: 28),
    );
  }

  // ===== Utility =====
  String _calcDiscount(double original, double current) {
    if (original <= 0) return '';
    return '${(current / original * 10).toStringAsFixed(1)}折';
  }

  String _formatDateShort(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'price': return '价格';
      case 'title': return '标题';
      case 'updated_at': return '更新时间';
      default: return '创建时间';
    }
  }

  // ===== Bottom Sheets =====
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 0.8, expand: false, builder: (context, scrollController) => _FilterSheet(scrollController: scrollController)),
    );
  }

  void _showPlatformPicker(BuildContext context) {
    ref.read(platformsProvider).whenData((platforms) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(padding: EdgeInsets.all(16), child: Text('选择平台', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                Expanded(
                  child: ListView.builder(
                    itemCount: platforms.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          title: const Text('全部平台'),
                          trailing: ref.read(dealFiltersProvider).platform == null ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                          onTap: () { ref.read(dealFiltersProvider.notifier).setPlatform(null); Navigator.pop(ctx); },
                        );
                      }
                      final p = platforms[index - 1];
                      return ListTile(
                        title: Text(p),
                        trailing: ref.read(dealFiltersProvider).platform == p ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                        onTap: () { ref.read(dealFiltersProvider.notifier).setPlatform(p); Navigator.pop(ctx); },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showCategoryPicker(BuildContext context) {
    ref.read(categoriesProvider).whenData((categories) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(padding: EdgeInsets.all(16), child: Text('选择分类', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          title: const Text('全部分类'),
                          trailing: ref.read(dealFiltersProvider).category == null ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                          onTap: () { ref.read(dealFiltersProvider.notifier).setCategory(null); Navigator.pop(ctx); },
                        );
                      }
                      final c = categories[index - 1];
                      return ListTile(
                        title: Text(c),
                        trailing: ref.read(dealFiltersProvider).category == c ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                        onTap: () { ref.read(dealFiltersProvider.notifier).setCategory(c); Navigator.pop(ctx); },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showSortPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('排序方式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
        _buildSortOption(ctx, '创建时间', 'created_at'),
        _buildSortOption(ctx, '更新时间', 'updated_at'),
        _buildSortOption(ctx, '价格从低到高', 'price', ascending: true),
        _buildSortOption(ctx, '价格从高到低', 'price', ascending: false),
        _buildSortOption(ctx, '标题', 'title', ascending: true),
        const SizedBox(height: 8),
      ])),
    );
  }

  Widget _buildSortOption(BuildContext context, String label, String sortBy, {bool ascending = false}) {
    final current = ref.read(dealFiltersProvider);
    final isSelected = current.sortBy == sortBy && current.ascending == ascending;
    return ListTile(title: Text(label), trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null, onTap: () { ref.read(dealFiltersProvider.notifier).setSortBy(sortBy, ascending: ascending); Navigator.pop(context); });
  }

  void _showTagPicker(BuildContext context) {
    ref.read(tagsProvider).whenData((tags) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(padding: EdgeInsets.all(16), child: Text('选择标签', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                Expanded(
                  child: ListView.builder(
                    itemCount: tags.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          title: const Text('全部标签'),
                          trailing: ref.read(dealFiltersProvider).tag == null ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                          onTap: () { ref.read(dealFiltersProvider.notifier).setTag(null); Navigator.pop(ctx); },
                        );
                      }
                      final t = tags[index - 1];
                      return ListTile(
                        title: Text(t),
                        trailing: ref.read(dealFiltersProvider).tag == t ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                        onTap: () { ref.read(dealFiltersProvider.notifier).setTag(t); Navigator.pop(ctx); },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _confirmDelete(BuildContext context, String dealId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条优惠记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async { Navigator.pop(ctx); await ref.read(dealDaoProvider).softDeleteDeal(dealId); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已删除'))); },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const _FilterSheet({required this.scrollController});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  bool _tagsExpanded = false;

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
    );
    if (picked != null) {
      ref.read(dealFiltersProvider.notifier).setDateRange(picked);
    }
  }

  String _dateRangeLabel(DateTimeRange range) {
    final s = '${range.start.month}/${range.start.day}';
    final e = '${range.end.month}/${range.end.day}';
    return '$s - $e';
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(dealFiltersProvider);
    final platformsAsync = ref.watch(platformsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final tagsAsync = ref.watch(tagsProvider);
    final theme = Theme.of(context);

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text('筛选与排序', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 16),
        Text('平台', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        platformsAsync.when(
          data: (platforms) => Wrap(spacing: 8, runSpacing: 6, children: [
            _buildSheetChip(context, ref, '全部', selected: filters.platform == null, onTap: () => ref.read(dealFiltersProvider.notifier).setPlatform(null)),
            ...platforms.map((p) => _buildSheetChip(context, ref, p, selected: filters.platform == p, onTap: () => ref.read(dealFiltersProvider.notifier).setPlatform(p))),
          ]),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        Text('分类', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        categoriesAsync.when(
          data: (categories) => Wrap(spacing: 8, runSpacing: 6, children: [
            _buildSheetChip(context, ref, '全部', selected: filters.category == null, onTap: () => ref.read(dealFiltersProvider.notifier).setCategory(null)),
            ...categories.map((c) => _buildSheetChip(context, ref, c, selected: filters.category == c, onTap: () => ref.read(dealFiltersProvider.notifier).setCategory(c))),
          ]),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => setState(() => _tagsExpanded = !_tagsExpanded),
          child: Row(
            children: [
              Text('标签', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.onSurface)),
              const SizedBox(width: 4),
              Icon(_tagsExpanded ? Icons.expand_less : Icons.expand_more, size: 16, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
        const SizedBox(height: 8),
        tagsAsync.when(
          data: (tags) {
            const maxCollapsed = 15;
            final showAll = _tagsExpanded || tags.length <= maxCollapsed;
            final displayTags = showAll ? tags : tags.take(maxCollapsed).toList();
            return Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildSheetChip(context, ref, '全部', selected: filters.tag == null, onTap: () => ref.read(dealFiltersProvider.notifier).setTag(null)),
                ...displayTags.map((t) => _buildSheetChip(context, ref, t, selected: filters.tag == t, onTap: () => ref.read(dealFiltersProvider.notifier).setTag(t))),
                if (!showAll)
                  GestureDetector(
                    onTap: () => setState(() => _tagsExpanded = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                      child: Text('+${tags.length - maxCollapsed}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        Text('时间范围', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, children: [
          _buildSheetChip(context, ref, '全部时间', selected: filters.dateRange == null, onTap: () => ref.read(dealFiltersProvider.notifier).setDateRange(null)),
          _buildSheetChip(context, ref, '最近一个月', selected: _isPresetRange(filters.dateRange, 30), onTap: () => ref.read(dealFiltersProvider.notifier).setDateRange(_presetRange(30))),
          _buildSheetChip(context, ref, '最近三个月', selected: _isPresetRange(filters.dateRange, 90), onTap: () => ref.read(dealFiltersProvider.notifier).setDateRange(_presetRange(90))),
          _buildSheetChip(context, ref, '最近半年', selected: _isPresetRange(filters.dateRange, 180), onTap: () => ref.read(dealFiltersProvider.notifier).setDateRange(_presetRange(180))),
          _buildSheetChip(context, ref, '一年内', selected: _isPresetRange(filters.dateRange, 365), onTap: () => ref.read(dealFiltersProvider.notifier).setDateRange(_presetRange(365))),
          _buildSheetChip(context, ref, '两年内', selected: _isPresetRange(filters.dateRange, 730), onTap: () => ref.read(dealFiltersProvider.notifier).setDateRange(_presetRange(730))),
          _buildSheetChip(
            context, ref,
            filters.dateRange != null && !_isAnyPreset(filters.dateRange) ? _dateRangeLabel(filters.dateRange!) : '自定义',
            selected: filters.dateRange != null && !_isAnyPreset(filters.dateRange),
            onTap: _pickCustomDateRange,
          ),
        ]),
        const SizedBox(height: 16),
        Text('排序', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, children: [
          _buildSheetChip(context, ref, '创建时间', selected: filters.sortBy == 'created_at' && !filters.ascending, onTap: () => ref.read(dealFiltersProvider.notifier).setSortBy('created_at', ascending: false)),
          _buildSheetChip(context, ref, '更新时间', selected: filters.sortBy == 'updated_at' && !filters.ascending, onTap: () => ref.read(dealFiltersProvider.notifier).setSortBy('updated_at', ascending: false)),
          _buildSheetChip(context, ref, '价格↑', selected: filters.sortBy == 'price' && filters.ascending, onTap: () => ref.read(dealFiltersProvider.notifier).setSortBy('price', ascending: true)),
          _buildSheetChip(context, ref, '价格↓', selected: filters.sortBy == 'price' && !filters.ascending, onTap: () => ref.read(dealFiltersProvider.notifier).setSortBy('price', ascending: false)),
          _buildSheetChip(context, ref, '标题', selected: filters.sortBy == 'title' && filters.ascending, onTap: () => ref.read(dealFiltersProvider.notifier).setSortBy('title', ascending: true)),
        ]),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: FilledButton.tonal(onPressed: () => ref.read(dealFiltersProvider.notifier).reset(), child: const Text('重置筛选'))),
      ],
    );
  }

  DateTimeRange? _presetRange(int days) {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return DateTimeRange(start: DateTime(start.year, start.month, start.day), end: DateTime(end.year, end.month, end.day, 23, 59, 59));
  }

  bool _isPresetRange(DateTimeRange? range, int days) {
    if (range == null) return false;
    final expected = _presetRange(days);
    if (expected == null) return false;
    final duration = range.end.difference(range.start).inDays;
    return duration >= days - 1 && duration <= days + 1;
  }

  bool _isAnyPreset(DateTimeRange? range) {
    if (range == null) return false;
    return _isPresetRange(range, 30) || _isPresetRange(range, 90) || _isPresetRange(range, 180) || _isPresetRange(range, 365) || _isPresetRange(range, 730);
  }

  Widget _buildSheetChip(BuildContext context, WidgetRef ref, String label, {required bool selected, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: selected ? AppColors.brandColor : theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant)),
      ),
    );
  }
}
