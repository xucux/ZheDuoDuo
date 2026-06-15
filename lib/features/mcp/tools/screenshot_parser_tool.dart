// MCP 工具：商品截图解析与录入
//
// 解析 LLM 从商品截图中提取的结构化数据，自动创建折扣记录。
// 支持同时写入促销权益、优惠券和图片关联数据。
// 在单个数据库事务中完成所有写入，保证数据一致性。

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../models/mcp_tool.dart';

/// 商品截图解析 MCP 工具
///
/// 接收 LLM 从商品截图解析出的结构化数据（标题、价格、平台等），
/// 自动计算折扣率并写入数据库，同时关联促销权益、优惠券和图片。
class ScreenshotParserTool extends McpTool {
  final AppDatabase _db;

  ScreenshotParserTool(this._db);

  @override
  final String name = 'screenshot_parser_add_deal';

  @override
  final String description = '解析商品截图元数据并新增折扣信息记录';

  @override
  final bool enabled = true;

  @override
  final Map<String, dynamic> inputSchema = {
    'type': 'object',
    'properties': {
      'title': {
        'type': 'string',
        'description': '商品名称',
      },
      'current_price': {
        'type': 'number',
        'description': '当前价/到手价',
      },
      'original_price': {
        'type': 'number',
        'description': '商品原价',
      },
      'display_price': {
        'type': 'number',
        'description': '展示价/活动价',
      },
      'platform': {
        'type': 'string',
        'description': '平台名称（淘宝/京东/拼多多/天猫/抖音/唯品会/小红书）',
      },
      'category': {
        'type': 'string',
        'description': '商品分类',
      },
      'currency': {
        'type': 'string',
        'description': '货币符号（默认 ¥）',
      },
      'logistics': {
        'type': 'string',
        'description': '物流信息',
      },
      'link': {
        'type': 'string',
        'description': '商品链接',
      },
      'note': {
        'type': 'string',
        'description': '备注',
      },
      'promotions': {
        'type': 'array',
        'items': {'type': 'string'},
        'description': '促销权益文案列表(618大促、满减、跨店满减、会员价、百亿补贴、多多会员、淘宝88VIP、京东Plus会员价、黑色星期五等)',
      },
      'coupon_strength': {
        'type': 'string',
        'description': '优惠券力度描述（如 满100减20、9折最高减50）',
      },
      'coupon_source': {
        'type': 'string',
        'description': '优惠券来源',
      },
      'image_path': {
        'type': 'string',
        'description': '截图图片路径',
      },
      'tags': {
        'type': 'array',
        'items': {'type': 'string'},
        'description': '标签列表（如 数码、日用、食品等）',
      },
    },
    'required': ['title', 'current_price'],
  };

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> arguments) async {
    try {
      final title = arguments['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        return {'success': false, 'error': '商品名称不能为空'};
      }

      final now = DateTime.now();
      final dealId = 'deal_mcp_${now.millisecondsSinceEpoch}';

      final currentPrice = _toDouble(arguments['current_price']) ?? 0.0;
      final originalPrice = _toDouble(arguments['original_price']);
      final displayPrice = _toDouble(arguments['display_price']);
      final platform = arguments['platform'] as String? ?? '';
      final category = arguments['category'] as String? ?? '';
      final currency = arguments['currency'] as String? ?? '¥';
      String? discount;
      if (originalPrice != null && originalPrice > 0 && currentPrice > 0) {
        discount = '${(currentPrice / originalPrice * 10).toStringAsFixed(1)}折';
      }
      final logistics = arguments['logistics'] as String?;
      final link = arguments['link'] as String?;
      final note = arguments['note'] as String?;
      final promotionsRaw = arguments['promotions'];
      final couponStrength = arguments['coupon_strength'] as String?;
      final couponSource = arguments['coupon_source'] as String?;
      final imagePath = arguments['image_path'] as String?;
      final tagsRaw = arguments['tags'];

      final promotions = (promotionsRaw is List)
          ? promotionsRaw.whereType<String>().toList()
          : <String>[];

      await _db.transaction(() async {
        await _db.into(_db.deals).insert(DealsCompanion(
          id: Value(dealId),
          title: Value(title.trim()),
          platform: Value(platform.isNotEmpty ? platform : '其他'),
          category: Value(category.isNotEmpty ? category : '其他'),
          currentPrice: Value(currentPrice),
          originalPrice: Value(originalPrice),
          displayPrice: Value(displayPrice),
          currency: Value(currency),
          discount: Value(discount),
          logistics: Value(logistics),
          link: Value(link),
          note: Value(note),
          createdAt: Value(now),
          updatedAt: Value(now),
        ));

        for (var i = 0; i < promotions.length; i++) {
          await _db.into(_db.dealPromotions).insert(DealPromotionsCompanion(
            dealId: Value(dealId),
            sortOrder: Value(i),
            textContent: Value(promotions[i]),
          ));
        }

        if ((couponStrength != null && couponStrength.isNotEmpty) ||
            (couponSource != null && couponSource.isNotEmpty)) {
          await _db.into(_db.coupons).insert(CouponsCompanion(
            dealId: Value(dealId),
            sortOrder: const Value(0),
            source: Value(couponSource ?? ''),
            strength: Value(couponStrength ?? ''),
            note: const Value('MCP 自动解析录入'),
          ));
        }

        if (imagePath != null && imagePath.isNotEmpty) {
          await _db.into(_db.dealImages).insert(DealImagesCompanion(
            dealId: Value(dealId),
            imagePath: Value(imagePath),
            updatedAt: Value(now),
          ));
        }

        final tags = (tagsRaw is List)
            ? tagsRaw.whereType<String>().where((t) => t.trim().isNotEmpty).toList()
            : <String>[];
        for (final tag in tags) {
          await _db.into(_db.dealTags).insert(DealTagsCompanion(
            dealId: Value(dealId),
            tag: Value(tag.trim()),
          ));
        }
      });

      return {
        'success': true,
        'deal_id': dealId,
        'title': title.trim(),
      };
    } catch (e) {
      return {'success': false, 'error': '创建折扣记录失败: $e'};
    }
  }

  /// 将动态值转为 double
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
