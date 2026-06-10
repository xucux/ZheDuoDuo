// 优惠列表 Provider
//
// 提供 Riverpod Provider 用于：
// - DealDao 实例的依赖注入
// - 筛选条件状态管理（DealFilters / DealFiltersNotifier）
// - 优惠列表的响应式监听（dealsProvider）
// - 单条优惠/平台/分类/标签/数量的异步查询

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/daos/deal_dao.dart';
import '../../../shared/theme/theme_provider.dart';

final dealDaoProvider = Provider<DealDao>((ref) {
  final db = ref.watch(databaseProvider);
  return DealDao(db);
});

/// Deal list filters state
class DealFilters {
  final String? platform;
  final String? category;
  final String? searchQuery;
  final String sortBy;
  final bool ascending;
  final String displayMode; // 'normal' or 'simple'

  const DealFilters({
    this.platform,
    this.category,
    this.searchQuery,
    this.sortBy = 'created_at',
    this.ascending = false,
    this.displayMode = 'normal',
  });

  DealFilters copyWith({
    String? platform,
    String? category,
    String? searchQuery,
    String? sortBy,
    bool? ascending,
    String? displayMode,
    bool clearPlatform = false,
    bool clearCategory = false,
    bool clearSearch = false,
  }) {
    return DealFilters(
      platform: clearPlatform ? null : (platform ?? this.platform),
      category: clearCategory ? null : (category ?? this.category),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      displayMode: displayMode ?? this.displayMode,
    );
  }
}

class DealFiltersNotifier extends StateNotifier<DealFilters> {
  DealFiltersNotifier() : super(const DealFilters());

  void setPlatform(String? platform) {
    state = state.copyWith(platform: platform, clearPlatform: platform == null);
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category, clearCategory: category == null);
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

  void reset() {
    state = const DealFilters();
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
    searchQuery: filters.searchQuery,
    sortBy: filters.sortBy,
    ascending: filters.ascending,
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
