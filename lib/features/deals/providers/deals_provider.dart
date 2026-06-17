// 优惠列表 Provider
//
// 提供 Riverpod Provider 用于：
// - DealDao 实例的依赖注入
// - 筛选条件状态管理（DealFilters / DealFiltersNotifier）
// - 优惠列表的响应式监听（dealsProvider）
// - 单条优惠/平台/分类/标签/数量的异步查询

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/daos/deal_dao.dart';
import '../../../shared/theme/theme_provider.dart';

final dealDaoProvider = Provider<DealDao>((ref) {
  final db = ref.watch(databaseProvider);
  final syncDao = ref.watch(syncDaoProvider);
  final logger = ref.watch(changeLoggerProvider);
  return DealDao(db, syncDao, logger);
});

/// Deal list filters state
class DealFilters {
  final String? platform;
  final String? category;
  final String? tag;
  final String? searchQuery;
  final String sortBy;
  final bool ascending;
  final String displayMode; // 'normal' or 'simple'
  final DateTimeRange? dateRange;

  const DealFilters({
    this.platform,
    this.category,
    this.tag,
    this.searchQuery,
    this.sortBy = 'created_at',
    this.ascending = false,
    this.displayMode = 'normal',
    this.dateRange,
  });

  /// 默认筛选条件（最近一年）
  factory DealFilters.defaultFilters() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 365));
    return DealFilters(
      dateRange: DateTimeRange(
        start: DateTime(start.year, start.month, start.day),
        end: DateTime(end.year, end.month, end.day, 23, 59, 59),
      ),
    );
  }

  DealFilters copyWith({
    String? platform,
    String? category,
    String? tag,
    String? searchQuery,
    String? sortBy,
    bool? ascending,
    String? displayMode,
    DateTimeRange? dateRange,
    bool clearPlatform = false,
    bool clearCategory = false,
    bool clearTag = false,
    bool clearSearch = false,
    bool clearDateRange = false,
  }) {
    return DealFilters(
      platform: clearPlatform ? null : (platform ?? this.platform),
      category: clearCategory ? null : (category ?? this.category),
      tag: clearTag ? null : (tag ?? this.tag),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      displayMode: displayMode ?? this.displayMode,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }
}

class DealFiltersNotifier extends StateNotifier<DealFilters> {
  DealFiltersNotifier() : super(DealFilters.defaultFilters());

  void setPlatform(String? platform) {
    state = state.copyWith(platform: platform, clearPlatform: platform == null);
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category, clearCategory: category == null);
  }

  void setTag(String? tag) {
    state = state.copyWith(tag: tag, clearTag: tag == null);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query, clearSearch: query == null);
  }

  void setSortBy(String sortBy, {bool? ascending}) {
    state = state.copyWith(sortBy: sortBy, ascending: ascending);
  }

  void setDisplayMode(String mode) {
    state = state.copyWith(displayMode: mode);
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range, clearDateRange: range == null);
  }

  void reset() {
    state = DealFilters.defaultFilters();
  }
}

final dealFiltersProvider = StateNotifierProvider<DealFiltersNotifier, DealFilters>((ref) {
  return DealFiltersNotifier();
});

/// Deals list stream provider
final dealsProvider = StreamProvider<List<DealWithDetails>>((ref) {
  final dealDao = ref.watch(dealDaoProvider);
  final filters = ref.watch(dealFiltersProvider);

  return dealDao.watchAllDeals(
    platform: filters.platform,
    category: filters.category,
    tag: filters.tag,
    searchQuery: filters.searchQuery,
    sortBy: filters.sortBy,
    ascending: filters.ascending,
    startDate: filters.dateRange?.start,
    endDate: filters.dateRange?.end,
  );
});

/// Single deal provider
final dealByIdProvider = StreamProvider.family<DealWithDetails?, String>((ref, id) {
  final dealDao = ref.watch(dealDaoProvider);
  return dealDao.watchDealById(id);
});

/// Available platforms
final platformsProvider = FutureProvider<List<String>>((ref) {
  final dealDao = ref.watch(dealDaoProvider);
  return dealDao.getAllPlatforms();
});

/// Available categories
final categoriesProvider = FutureProvider<List<String>>((ref) {
  final dealDao = ref.watch(dealDaoProvider);
  return dealDao.getAllCategories();
});

/// Available tags
final tagsProvider = FutureProvider<List<String>>((ref) {
  final dealDao = ref.watch(dealDaoProvider);
  return dealDao.getAllTags();
});

/// Deal count
final dealCountProvider = FutureProvider<int>((ref) {
  final dealDao = ref.watch(dealDaoProvider);
  return dealDao.countDeals();
});
