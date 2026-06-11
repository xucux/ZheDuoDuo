// MCP 工具：聚合统计折扣信息
//
// 在查询条件基础上对折扣数据进行汇总统计，
// 支持计数、求和、平均值、最小值、最大值等聚合方式。

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../models/mcp_tool.dart';

/// 聚合统计折扣信息 MCP 工具
///
/// 为 LLM 提供折扣数据的统计分析能力，支持：
/// - 与 deals_query 相同的过滤条件
/// - 多种聚合方式：count / sum / avg / min / max
/// - 可聚合字段：current_price / original_price / display_price
class DealsAggregateTool extends McpTool {
  final AppDatabase _db;

  DealsAggregateTool(this._db);

  @override
  final String name = 'deals_aggregate';

  @override
  final String description = '聚合统计折扣信息，支持计数、求和、平均值、最小值、最大值等汇总方式';

  @override
  final bool enabled = true;

  @override
  final Map<String, dynamic> inputSchema = {
    'type': 'object',
    'properties': {
      'platform': {
        'type': 'string',
        'description': '按平台筛选',
      },
      'category': {
        'type': 'string',
        'description': '按分类筛选',
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
        'description': '创建时间起始（ISO8601 格式）',
      },
      'end_date': {
        'type': 'string',
        'description': '创建时间截止（ISO8601 格式）',
      },
      'aggregate_by': {
        'type': 'string',
        'description': '聚合方式',
        'enum': ['count', 'sum', 'avg', 'min', 'max'],
        'default': 'count',
      },
      'field': {
        'type': 'string',
        'description': '聚合字段（count 时忽略）',
        'enum': ['current_price', 'original_price', 'display_price'],
        'default': 'current_price',
      },
    },
    'required': ['aggregate_by'],
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
      final aggregateBy = arguments['aggregate_by'] as String? ?? 'count';
      final field = arguments['field'] as String? ?? 'current_price';

      final query = _db.selectOnly(_db.deals)
        ..where(_db.deals.deleted.equals(0));

      if (platform != null && platform.isNotEmpty) {
        query.where(_db.deals.platform.equals(platform));
      }
      if (category != null && category.isNotEmpty) {
        query.where(_db.deals.category.equals(category));
      }
      if (titleQuery != null && titleQuery.isNotEmpty) {
        query.where(_db.deals.title.like('%$titleQuery%'));
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final pattern = '%$searchQuery%';
        query.where(
          _db.deals.platform.like(pattern) |
          _db.deals.category.like(pattern) |
          _db.deals.note.like(pattern)
        );
      }
      if (minPrice != null) {
        query.where(_db.deals.currentPrice.isBiggerOrEqualValue(minPrice));
      }
      if (maxPrice != null) {
        query.where(_db.deals.currentPrice.isSmallerOrEqualValue(maxPrice));
      }
      if (isLowestPrice == true) {
        query.where(_db.deals.isLowestPrice.equals(1));
      }
      if (startDate != null && endDate != null) {
        query.where(_db.deals.createdAt.isBetweenValues(startDate, endDate));
      } else if (startDate != null) {
        query.where(_db.deals.createdAt.isBiggerOrEqualValue(startDate));
      } else if (endDate != null) {
        query.where(_db.deals.createdAt.isSmallerOrEqualValue(endDate));
      }

      // 聚合计算
      final column = _resolveColumn(field);
      Expression<num> aggregateExpr;

      switch (aggregateBy) {
        case 'sum':
          aggregateExpr = column.sum();
          break;
        case 'avg':
          aggregateExpr = column.avg();
          break;
        case 'min':
          aggregateExpr = column.min();
          break;
        case 'max':
          aggregateExpr = column.max();
          break;
        default:
          aggregateExpr = const CustomExpression<int>('COUNT(*)');
      }

      query.addColumns([aggregateExpr]);

      final row = await query.getSingleOrNull();
      final value = row?.read(aggregateExpr);

      return {
        'success': true,
        'aggregate_by': aggregateBy,
        'field': field,
        'result': value,
      };
    } catch (e) {
      return {'success': false, 'error': '聚合统计失败: $e'};
    }
  }

  Expression<double> _resolveColumn(String field) {
    switch (field) {
      case 'original_price':
        return _db.deals.originalPrice;
      case 'display_price':
        return _db.deals.displayPrice;
      default:
        return _db.deals.currentPrice;
    }
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
