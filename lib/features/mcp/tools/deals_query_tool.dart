// MCP 工具：查询折扣信息列表
//
// 支持多维度筛选（平台、分类、关键词模糊搜索、价格范围、时间范围）
// 支持排序和分页，返回折扣记录及其关联数据。

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../models/mcp_tool.dart';

/// 查询折扣信息列表 MCP 工具
///
/// 为 LLM 提供灵活的折扣记录查询能力，支持：
/// - 平台/分类精确筛选
/// - 标题/平台/分类/备注模糊搜索
/// - 价格范围筛选（最低/最高到手价）
/// - 创建时间范围筛选
/// - 多字段排序（创建时间/更新时间/价格/标题）
class DealsQueryTool extends McpTool {
  final AppDatabase _db;

  DealsQueryTool(this._db);

  @override
  final String name = 'deals_query';

  @override
  final String description = '查询折扣信息列表，支持平台、分类、关键词模糊搜索、价格范围、时间范围筛选和排序';

  @override
  final bool enabled = true;

  @override
  final Map<String, dynamic> inputSchema = {
    'type': 'object',
    'properties': {
      'platform': {
        'type': 'string',
        'description': '按平台筛选（如 淘宝、京东、拼多多）',
      },
      'category': {
        'type': 'string',
        'description': '按分类筛选（如 数码、家居、食品）',
      },
      'title_query': {
        'type': 'string',
        'description': '按标题模糊搜索',
      },
      'search_query': {
        'type': 'string',
        'description': '关键词模糊搜索（匹配平台、分类、备注，不含标题）',
      },
      'min_price': {
        'type': 'number',
        'description': '最低到手价（含）',
      },
      'max_price': {
        'type': 'number',
        'description': '最高到手价（含）',
      },
      'is_lowest_price': {
        'type': 'boolean',
        'description': '是否仅查询历史最低价',
      },
      'start_date': {
        'type': 'string',
        'description': '创建时间起始（ISO8601 格式，如 2024-01-01）',
      },
      'end_date': {
        'type': 'string',
        'description': '创建时间截止（ISO8601 格式，如 2024-12-31）',
      },
      'sort_by': {
        'type': 'string',
        'description': '排序字段',
        'enum': ['created_at', 'updated_at', 'price', 'title'],
        'default': 'created_at',
      },
      'ascending': {
        'type': 'boolean',
        'description': '是否升序排列',
        'default': false,
      },
      'limit': {
        'type': 'integer',
        'description': '返回最大条数（默认 50，最大 200）',
        'default': 50,
      },
      'offset': {
        'type': 'integer',
        'description': '分页偏移量',
        'default': 0,
      },
    },
  };

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> arguments) async {
    try {
      final platform = arguments['platform'] as String?;
      final category = arguments['category'] as String?;
      final titleQuery = arguments['title_query'] as String?;
      final searchQuery = arguments['search_query'] as String?;
      final minPrice = _toDouble(arguments['min_price']);
      final maxPrice = _toDouble(arguments['max_price']);
      final isLowestPrice = arguments['is_lowest_price'] as bool?;
      final startDate = _parseDate(arguments['start_date'] as String?);
      final endDate = _parseDate(arguments['end_date'] as String?);
      final sortBy = arguments['sort_by'] as String? ?? 'created_at';
      final ascending = arguments['ascending'] as bool? ?? false;
      final limit = (arguments['limit'] as int?)?.clamp(1, 200) ?? 50;
      final offset = (arguments['offset'] as int?) ?? 0;

      var query = _db.select(_db.deals)
        ..where((t) => t.deleted.equals(0));

      if (platform != null && platform.isNotEmpty) {
        query.where((t) => t.platform.equals(platform));
      }
      if (category != null && category.isNotEmpty) {
        query.where((t) => t.category.equals(category));
      }
      if (titleQuery != null && titleQuery.isNotEmpty) {
        query.where((t) => t.title.like('%$titleQuery%'));
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final pattern = '%$searchQuery%';
        query.where((t) =>
          t.platform.like(pattern) |
          t.category.like(pattern) |
          t.note.like(pattern)
        );
      }
      if (minPrice != null) {
        query.where((t) => t.currentPrice.isBiggerOrEqualValue(minPrice));
      }
      if (maxPrice != null) {
        query.where((t) => t.currentPrice.isSmallerOrEqualValue(maxPrice));
      }
      if (isLowestPrice == true) {
        query.where((t) => t.isLowestPrice.equals(1));
      }
      if (startDate != null && endDate != null) {
        query.where((t) => t.createdAt.isBetweenValues(startDate, endDate));
      } else if (startDate != null) {
        query.where((t) => t.createdAt.isBiggerOrEqualValue(startDate));
      } else if (endDate != null) {
        query.where((t) => t.createdAt.isSmallerOrEqualValue(endDate));
      }

      switch (sortBy) {
        case 'price':
          query.orderBy([(t) => OrderingTerm(expression: t.currentPrice, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
          break;
        case 'title':
          query.orderBy([(t) => OrderingTerm(expression: t.title, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
          break;
        case 'updated_at':
          query.orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
          break;
        default:
          query.orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
      }

      query.limit(limit, offset: offset);

      final deals = await query.get();
      final results = <Map<String, dynamic>>[];

      for (final deal in deals) {
        final tags = await _getTagsForDeal(deal.id);
        final promotions = await _getPromotionsForDeal(deal.id);
        final coupons = await _getCouponsForDeal(deal.id);

        results.add({
          'id': deal.id,
          'title': deal.title,
          'platform': deal.platform,
          'category': deal.category,
          'current_price': deal.currentPrice,
          'original_price': deal.originalPrice,
          'display_price': deal.displayPrice,
          'currency': deal.currency,
          'discount': deal.discount,
          'logistics': deal.logistics,
          'link': deal.link,
          'note': deal.note,
          'is_lowest_price': deal.isLowestPrice == 1,
          'tags': tags,
          'promotions': promotions,
          'coupons': coupons.map((c) => {
            'source': c.source,
            'strength': c.strength,
            'note': c.note,
          }).toList(),
          'created_at': deal.createdAt.toIso8601String(),
          'updated_at': deal.updatedAt.toIso8601String(),
        });
      }

      return {
        'success': true,
        'total': results.length,
        'offset': offset,
        'limit': limit,
        'data': results,
      };
    } catch (e) {
      return {'success': false, 'error': '查询折扣列表失败: $e'};
    }
  }

  Future<List<String>> _getTagsForDeal(String dealId) async {
    final query = _db.select(_db.dealTags)
      ..where((t) => t.dealId.equals(dealId));
    final rows = await query.get();
    return rows.map((r) => r.tag).toList();
  }

  Future<List<String>> _getPromotionsForDeal(String dealId) async {
    final query = _db.select(_db.dealPromotions)
      ..where((t) => t.dealId.equals(dealId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    final rows = await query.get();
    return rows.map((r) => r.textContent).toList();
  }

  Future<List<Coupon>> _getCouponsForDeal(String dealId) async {
    final query = _db.select(_db.coupons)
      ..where((t) => t.dealId.equals(dealId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.get();
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
