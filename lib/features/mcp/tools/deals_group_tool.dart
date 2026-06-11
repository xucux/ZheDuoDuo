// MCP 工具：分组查询折扣信息列表
//
// 按指定维度（平台、分类、月份、年份）对折扣记录进行分组，
// 返回每组的数量及关键汇总信息。

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../models/mcp_tool.dart';

/// 分组查询折扣信息 MCP 工具
///
/// 为 LLM 提供折扣数据的分组分析能力，支持：
/// - 与 deals_query 相同的过滤条件
/// - 分组维度：platform / category / month / year
/// - 返回每组的数量、平均到手价、最低到手价、最高到手价
class DealsGroupTool extends McpTool {
  final AppDatabase _db;

  DealsGroupTool(this._db);

  @override
  final String name = 'deals_group';

  @override
  final String description = '分组查询折扣信息列表，支持按平台、分类、月份、年份分组统计';

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
      'group_by': {
        'type': 'string',
        'description': '分组维度',
        'enum': ['platform', 'category', 'month', 'year'],
        'default': 'platform',
      },
      'sort_by': {
        'type': 'string',
        'description': '排序方式',
        'enum': ['count', 'avg_price', 'min_price', 'max_price', 'group_key'],
        'default': 'count',
      },
      'ascending': {
        'type': 'boolean',
        'description': '是否升序排列',
        'default': false,
      },
      'limit': {
        'type': 'integer',
        'description': '返回最大组数（默认 50，最大 200）',
        'default': 50,
      },
    },
    'required': ['group_by'],
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
      final groupBy = arguments['group_by'] as String? ?? 'platform';
      final sortBy = arguments['sort_by'] as String? ?? 'count';
      final ascending = arguments['ascending'] as bool? ?? false;
      final limit = (arguments['limit'] as int?)?.clamp(1, 200) ?? 50;

      // 构建 WHERE 子句
      var whereExpr = _db.deals.deleted.equals(0);

      if (platform != null && platform.isNotEmpty) {
        whereExpr &= _db.deals.platform.equals(platform);
      }
      if (category != null && category.isNotEmpty) {
        whereExpr &= _db.deals.category.equals(category);
      }
      if (titleQuery != null && titleQuery.isNotEmpty) {
        whereExpr &= _db.deals.title.like('%$titleQuery%');
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final pattern = '%$searchQuery%';
        whereExpr &= (
          _db.deals.platform.like(pattern) |
          _db.deals.category.like(pattern) |
          _db.deals.note.like(pattern)
        );
      }
      if (minPrice != null) {
        whereExpr &= _db.deals.currentPrice.isBiggerOrEqualValue(minPrice);
      }
      if (maxPrice != null) {
        whereExpr &= _db.deals.currentPrice.isSmallerOrEqualValue(maxPrice);
      }
      if (isLowestPrice == true) {
        whereExpr &= _db.deals.isLowestPrice.equals(1);
      }
      if (startDate != null && endDate != null) {
        whereExpr &= _db.deals.createdAt.isBetweenValues(startDate, endDate);
      } else if (startDate != null) {
        whereExpr &= _db.deals.createdAt.isBiggerOrEqualValue(startDate);
      } else if (endDate != null) {
        whereExpr &= _db.deals.createdAt.isSmallerOrEqualValue(endDate);
      }

      // 分组表达式
      final Expression<String> groupExpr;
      switch (groupBy) {
        case 'month':
          groupExpr = const CustomExpression<String>("strftime('%Y-%m', created_at)");
          break;
        case 'year':
          groupExpr = const CustomExpression<String>("strftime('%Y', created_at)");
          break;
        case 'category':
          groupExpr = _db.deals.category;
          break;
        default:
          groupExpr = _db.deals.platform;
      }

      final countExpr = const CustomExpression<int>('COUNT(*)');
      final avgExpr = _db.deals.currentPrice.avg();
      final minExpr = _db.deals.currentPrice.min();
      final maxExpr = _db.deals.currentPrice.max();

      final query = _db.selectOnly(_db.deals)
        ..where(whereExpr)
        ..addColumns([groupExpr, countExpr, avgExpr, minExpr, maxExpr])
        ..groupBy([groupExpr]);

      // 排序
      final orderExpr = switch (sortBy) {
        'avg_price' => avgExpr,
        'min_price' => minExpr,
        'max_price' => maxExpr,
        'group_key' => groupExpr,
        _ => countExpr,
      };
      query.orderBy([OrderingTerm(expression: orderExpr, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);

      query.limit(limit);

      final rows = await query.get();
      final groups = rows.map((row) {
        return {
          'group_key': row.read(groupExpr),
          'count': row.read(countExpr),
          'avg_price': row.read(avgExpr),
          'min_price': row.read(minExpr),
          'max_price': row.read(maxExpr),
        };
      }).toList();

      return {
        'success': true,
        'group_by': groupBy,
        'total_groups': groups.length,
        'data': groups,
      };
    } catch (e) {
      return {'success': false, 'error': '分组查询失败: $e'};
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
