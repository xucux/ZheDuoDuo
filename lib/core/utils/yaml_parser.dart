// YAML 优惠信息解析器
//
// 将 YAML 格式的优惠信息解析为结构化的 ParsedDeal 对象。
// 支持结构化格式（product / prices / source / promotions / coupons / visual）
// 和扁平格式（title / price / platform 等顶级字段）。
// 自动从促销权益中提取标签和优惠券信息。

import 'package:yaml/yaml.dart';
import 'package:uuid/uuid.dart';

/// 解析后的优惠信息
class ParsedDeal {
  /// 唯一标识（自动生成 UUID）
  final String id;
  /// 商品名称
  final String title;
  /// 来源平台（京东/淘宝/拼多多等）
  final String platform;
  /// 商品分类（数码/美妆/家电等）
  final String category;
  /// 到手价
  final double currentPrice;
  /// 原价
  final double? originalPrice;
  /// 页面展示价
  final double? displayPrice;
  /// 货币符号
  final String currency;
  /// 折扣描述（如 "6.6折"）
  final String? discount;
  /// 物流信息
  final String? logistics;
  /// 购买链接
  final String? link;
  /// 备注
  final String? note;
  /// 视觉内容类型（none/image/ascii）
  final String visualType;
  /// ASCII 艺术图内容
  final String? asciiArt;
  /// 图片 URL
  final String? imageUrl;
  /// 销量信息
  final String? sales;
  /// 创建时间（ISO8601 字符串，可选）
  final DateTime? createdAt;
  /// 来源信息 JSON（如 '{"sourceType":"手动新增","sourceRemark":null}'）
  final String? sourceJson;
  /// 标签列表
  final List<String> tags;
  /// 促销权益列表
  final List<String> promotions;
  /// 优惠券列表
  final List<ParsedCoupon> coupons;

  ParsedDeal({
    required this.id,
    required this.title,
    this.platform = '其他',
    this.category = '其他',
    required this.currentPrice,
    this.originalPrice,
    this.displayPrice,
    this.currency = '¥',
    this.discount,
    this.logistics,
    this.link,
    this.note,
    this.visualType = 'none',
    this.asciiArt,
    this.imageUrl,
    this.sales,
    this.createdAt,
    this.sourceJson,
    this.tags = const [],
    this.promotions = const [],
    this.coupons = const [],
  });
}

/// 解析后的优惠券信息
class ParsedCoupon {
  /// 券数量
  final int count;
  /// 券来源（店铺券/平台券/直播间等）
  final String source;
  /// 优惠力度（满300减50 / 9折 / 直减100等）
  final String strength;
  /// 备注（券码、领取方式等）
  final String? note;

  ParsedCoupon({
    this.count = 1,
    this.source = '',
    this.strength = '',
    this.note,
  });
}

/// YAML 优惠信息解析器
///
/// 将 YAML 字符串解析为 ParsedDeal 对象，支持结构化和扁平两种格式。
/// 自动从促销权益中提取标签和优惠券。
class YamlParser {
  static const _uuid = Uuid();

  /// Parse YAML string into a ParsedDeal
  static ParsedDeal parse(String yamlStr) {
    final dynamic doc = loadYaml(yamlStr);
    if (doc is! Map) {
      throw FormatException('YAML must be a map, got ${doc.runtimeType}');
    }

    final map = Map<String, dynamic>.from(doc);

    // Extract fields with both structured and flat format support
    final title = _extractTitle(map);
    final currentPrice = _extractCurrentPrice(map);
    final platform = _extractString(map, ['source.platform', 'platform', '平台']) ?? '其他';
    final category = _extractString(map, ['product.category', 'category', '分类']) ?? '其他';
    final originalPrice = _extractDouble(map, ['prices.original_price', 'originalPrice', '原价']);
    final displayPrice = _extractDouble(map, ['prices.current_display_price', 'currentDisplayPrice']);
    final currency = _extractCurrency(map);
    final logistics = _extractString(map, ['source.logistics', 'logistics']);
    final link = _extractString(map, ['source.link', 'link', 'url', '链接']);
    final note = _extractString(map, ['note', '备注']);
    final discount = _extractString(map, ['discount', '折扣']);
    final sales = _extractSales(map);
    final createdAt = _extractCreatedAt(map);

    // Visual
    final visualType = _extractVisualType(map);
    final imageUrl = _extractString(map, ['visual.image_url', 'image_url', 'imageUrl']);
    final asciiArt = _extractString(map, ['visual.ascii_art', 'ascii_art', 'asciiArt']);

    // Promotions, tags, coupons
    final promotions = _extractPromotions(map);
    final tags = _extractTags(map, promotions);
    final coupons = _extractCoupons(map, promotions);
    final sourceJson = _extractSourceJson(map);

    return ParsedDeal(
      id: _uuid.v4(),
      title: title,
      platform: platform,
      category: category,
      currentPrice: currentPrice,
      originalPrice: originalPrice,
      displayPrice: displayPrice,
      currency: currency,
      discount: discount,
      logistics: logistics,
      link: link,
      note: note,
      visualType: visualType,
      asciiArt: asciiArt,
      imageUrl: imageUrl,
      sales: sales,
      createdAt: createdAt,
      sourceJson: sourceJson,
      tags: tags,
      promotions: promotions,
      coupons: coupons,
    );
  }

  static String _extractTitle(Map<String, dynamic> map) {
    // Structured: product.title
    if (map['product'] is Map) {
      final p = Map<String, dynamic>.from(map['product']);
      if (p['title'] != null) return p['title'].toString();
    }
    // Flat
    for (final key in ['title', 'name', '商品名称']) {
      if (map[key] != null) return map[key].toString();
    }
    throw FormatException('Missing required field: title');
  }

  static double _extractCurrentPrice(Map<String, dynamic> map) {
    // Structured: prices.discounted_price
    if (map['prices'] is Map) {
      final p = Map<String, dynamic>.from(map['prices']);
      for (final key in ['discounted_price', 'current_price']) {
        if (p[key] != null) return _toDouble(p[key]);
      }
    }
    // Flat
    for (final key in ['currentPrice', 'price', '现价']) {
      if (map[key] != null) return _toDouble(map[key]);
    }
    throw FormatException('Missing required field: currentPrice');
  }

  static String? _extractString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (key.contains('.')) {
        final parts = key.split('.');
        dynamic current = map;
        bool found = true;
        for (final part in parts) {
          if (current is Map) {
            final m = Map<String, dynamic>.from(current);
            if (m.containsKey(part)) {
              current = m[part];
            } else {
              found = false;
              break;
            }
          } else {
            found = false;
            break;
          }
        }
        if (found && current != null) return current.toString();
      } else {
        if (map[key] != null) return map[key].toString();
      }
    }
    return null;
  }

  static double? _extractDouble(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (key.contains('.')) {
        final parts = key.split('.');
        dynamic current = map;
        bool found = true;
        for (final part in parts) {
          if (current is Map) {
            final m = Map<String, dynamic>.from(current);
            if (m.containsKey(part)) {
              current = m[part];
            } else {
              found = false;
              break;
            }
          } else {
            found = false;
            break;
          }
        }
        if (found && current != null) return _toDouble(current);
      } else {
        if (map[key] != null) return _toDouble(map[key]);
      }
    }
    return null;
  }

  static String _extractCurrency(Map<String, dynamic> map) {
    String? raw;
    if (map['prices'] is Map) {
      final p = Map<String, dynamic>.from(map['prices']);
      raw = p['currency']?.toString();
    }
    raw ??= map['currency']?.toString();

    if (raw == null) return '¥';
    switch (raw.toUpperCase()) {
      case 'CNY':
      case 'RMB':
      case 'CNY/RMB':
        return '¥';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return raw;
    }
  }

  static String? _extractSales(Map<String, dynamic> map) {
    if (map['sales'] is Map) {
      final s = Map<String, dynamic>.from(map['sales'] as Map);
      return s['sold_30_days']?.toString() ?? s['sold30Days']?.toString();
    }
    return map['sales']?.toString();
  }

  static DateTime? _extractCreatedAt(Map<String, dynamic> map) {
    final raw = _extractString(map, ['created_at', 'createdAt']);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static String _extractVisualType(Map<String, dynamic> map) {
    if (map['visual'] is Map) {
      final v = Map<String, dynamic>.from(map['visual'] as Map);
      if (v['type'] != null) return v['type'].toString();
    }
    if (map['visualType'] != null) return map['visualType'].toString();

    // Infer from content
    if (_extractString(map, ['visual.image_url', 'image_url', 'imageUrl']) != null) return 'image';
    if (_extractString(map, ['visual.ascii_art', 'ascii_art', 'asciiArt']) != null) return 'ascii';
    return 'none';
  }

  static List<String> _extractPromotions(Map<String, dynamic> map) {
    if (map['promotions'] is List) {
      return (map['promotions'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  static List<String> _extractTags(Map<String, dynamic> map, List<String> promotions) {
    // Explicit tags
    if (map['tags'] is List) {
      return (map['tags'] as List).map((e) => e.toString()).toList();
    }

    // Auto-extract from promotions
    final tagKeywords = ['安装', '质保', '保价', '包邮', '免邮', '保修', '保障'];
    final tags = <String>[];
    for (final promo in promotions) {
      if (tagKeywords.any((kw) => promo.contains(kw))) {
        tags.add(promo);
      }
    }
    return tags;
  }

  static List<ParsedCoupon> _extractCoupons(Map<String, dynamic> map, List<String> promotions) {
    // Explicit coupons
    if (map['coupons'] is List) {
      return (map['coupons'] as List).map((e) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          return ParsedCoupon(
            count: m['count'] != null ? (m['count'] as num).toInt() : 1,
            source: m['source']?.toString() ?? '',
            strength: m['strength']?.toString() ?? '',
            note: m['note']?.toString(),
          );
        }
        return ParsedCoupon(strength: e.toString());
      }).toList();
    }

    // Auto-extract from promotions
    final couponKeywords = ['券', '减', '折', '直降', '到手价', '满', '赠送', 'PLUS'];
    final coupons = <ParsedCoupon>[];
    for (final promo in promotions) {
      if (couponKeywords.any((kw) => promo.contains(kw))) {
        coupons.add(ParsedCoupon(
          source: '促销',
          strength: promo,
          count: 1,
        ));
      }
    }
    return coupons;
  }

  static String? _extractSourceJson(Map<String, dynamic> map) {
    String? sourceType;
    String? sourceRemark;

    // 结构化 source.type / source.remark
    if (map['source'] is Map) {
      final s = Map<String, dynamic>.from(map['source']);
      sourceType ??= s['type']?.toString();
      sourceRemark ??= s['remark']?.toString();
    }

    // 根级简写
    sourceType ??= _extractString(map, ['sourceType', '来源类型']);
    sourceRemark ??= _extractString(map, ['sourceRemark', '来源备注']);

    if (sourceType == null && sourceRemark == null) return null;

    final buffer = StringBuffer();
    buffer.write('{');
    if (sourceType != null) {
      buffer.write('"sourceType":"$sourceType"');
      if (sourceRemark != null) {
        buffer.write(',"sourceRemark":"$sourceRemark"');
      }
    } else if (sourceRemark != null) {
      buffer.write('"sourceRemark":"$sourceRemark"');
    }
    buffer.write('}');
    return buffer.toString();
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.\-]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }
}
