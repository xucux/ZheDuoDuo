// 搜索页面
//
// 提供优惠记录的全文搜索功能，包括：
// - 实时搜索（标题/平台/分类/备注/标签）
// - 搜索历史记录
// - 热门搜索推荐
// - 搜索结果卡片展示

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/daos/deal_dao.dart';
import '../../../shared/theme/antd_colors.dart';
import '../../../shared/theme/app_colors.dart';
import '../../deals/providers/deals_provider.dart';

const _kSearchHistoryKey = 'search_history';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    // 恢复之前的搜索状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentQuery = ref.read(dealFiltersProvider).searchQuery;
      if (currentQuery != null && currentQuery.isNotEmpty) {
        _searchController.text = currentQuery;
      }
    });
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_kSearchHistoryKey);
    if (saved != null) {
      setState(() => _searchHistory.addAll(saved));
    }
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kSearchHistoryKey, _searchHistory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ref.watch(dealFiltersProvider);
    final dealsAsync = ref.watch(dealsProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // 返回时清空搜索查询，避免影响优惠清单主页面
          ref.read(dealFiltersProvider.notifier).setSearchQuery(null);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: '搜索商品、平台、标签...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          onChanged: (value) {
            ref.read(dealFiltersProvider.notifier).setSearchQuery(
                  value.isEmpty ? null : value,
                );
          },
          onSubmitted: (value) {
            if (value.isNotEmpty && !_searchHistory.contains(value)) {
              setState(() {
                _searchHistory.insert(0, value);
                if (_searchHistory.length > 10) _searchHistory.removeLast();
              });
              _saveSearchHistory();
            }
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(dealFiltersProvider.notifier).setSearchQuery(null);
              },
            ),
        ],
      ),
      body: filters.searchQuery == null || filters.searchQuery!.isEmpty
          ? _buildSearchSuggestions(context)
          : dealsAsync.when(
              data: (deals) {
                if (deals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '未找到匹配的优惠',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    _buildSortBar(context, filters),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        itemCount: deals.length,
                        itemBuilder: (context, index) {
                          final dw = deals[index];
                          return _buildSearchResultCard(context, dw);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('搜索失败: $e')),
            ),
    ),
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_searchHistory.isNotEmpty) ...[
          Row(
            children: [
              Text(
                '搜索历史',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => _searchHistory.clear());
                  _saveSearchHistory();
                },
                child: const Text('清空'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _searchHistory.map((query) {
              return ActionChip(
                label: Text(query),
                onPressed: () {
                  _searchController.text = query;
                  ref.read(dealFiltersProvider.notifier).setSearchQuery(query);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          '热门搜索',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['京东', '淘宝', '数码', '美妆', '家电', '限时'].map((query) {
            return ActionChip(
              label: Text(query),
              onPressed: () {
                _searchController.text = query;
                ref.read(dealFiltersProvider.notifier).setSearchQuery(query);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortBar(BuildContext context, DealFilters filters) {
    final theme = Theme.of(context);
    final isTimeSort = filters.sortBy == 'created_at';
    final isPriceSort = filters.sortBy == 'price';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          _buildSortChip(
            theme: theme,
            label: '创建时间',
            isSelected: isTimeSort,
            onTap: () {
              ref.read(dealFiltersProvider.notifier).setSortBy('created_at', ascending: false);
            },
          ),
          const SizedBox(width: 8),
          _buildSortChip(
            theme: theme,
            label: isPriceSort && filters.ascending ? '价格↑' : '价格↓',
            isSelected: isPriceSort,
            onTap: () {
              if (isPriceSort) {
                ref.read(dealFiltersProvider.notifier).setSortBy('price', ascending: !filters.ascending);
              } else {
                ref.read(dealFiltersProvider.notifier).setSortBy('price', ascending: true);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip({
    required ThemeData theme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AntdColors.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(BuildContext context, DealWithDetails dw) {
    final deal = dw.deal;
    final theme = Theme.of(context);
    final platformColor = AppColors.getPlatformColor(deal.platform);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/deal/${deal.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: platformColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            deal.platform,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: platformColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            deal.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (deal.visualType != 'none') ...[
                          const SizedBox(width: 6),
                          _buildVisualBadge(context, deal.visualType),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deal.currency}${deal.currentPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('yy-MM-dd HH:mm').format(deal.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualBadge(BuildContext context, String visualType) {
    final theme = Theme.of(context);
    IconData icon;
    String text;
    Color bgColor;
    Color fgColor;
    switch (visualType) {
      case 'image':
        icon = Icons.image_outlined;
        text = '有图';
        bgColor = theme.colorScheme.primaryContainer;
        fgColor = theme.colorScheme.onPrimaryContainer;
        break;
      case 'ascii':
        icon = Icons.code;
        text = 'ASCII';
        bgColor = theme.colorScheme.tertiaryContainer;
        fgColor = theme.colorScheme.onTertiaryContainer;
        break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fgColor),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
