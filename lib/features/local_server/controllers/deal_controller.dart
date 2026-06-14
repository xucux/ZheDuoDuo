// 折扣 API Controller
//
// 基于 shelf_router 提供折扣信息的 RESTful API，
// 挂载到本地服务的 /api/deals 路径。

import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/deal_dao.dart';

/// 折扣 RESTful Controller
class DealController {
  final DealDao _dealDao;

  DealController(this._dealDao);

  /// 返回已配置好路由的 shelf Router（动作名词风格）
  Router get router {
    final r = Router();
    r.get('/list', _listDeals);
    r.post('/create', _createDeal);
    r.post('/batchCreate', _batchCreateDeals);
    r.get('/detail/<id>', _getDeal);
    r.post('/update/<id>', _updateDeal);
    r.post('/delete/<id>', _deleteDeal);
    r.post('/batchDelete', _batchDeleteDeals);
    return r;
  }

  // ==================== 列表查询 ====================

  Future<Response> _listDeals(Request request) async {
    final params = request.url.queryParameters;
    final page = int.tryParse(params['page'] ?? '1')?.clamp(1, 999999) ?? 1;
    final pageSize = int.tryParse(params['pageSize'] ?? '20')?.clamp(1, 200) ?? 20;
    final platform = params['platform'];
    final category = params['category'];
    final search = params['search'];
    final startTime = params['startTime'];
    final endTime = params['endTime'];

    // 构建基础查询（统计总数用）
    final countExpr = _dealDao.deals.id.count();
    final countQuery = _dealDao.selectOnly(_dealDao.deals)
      ..addColumns([countExpr])
      ..where(_dealDao.deals.deleted.equals(0));

    final baseQuery = _dealDao.select(_dealDao.deals)
      ..where((t) => t.deleted.equals(0));

    // 平台筛选
    if (platform != null && platform.isNotEmpty) {
      countQuery.where(_dealDao.deals.platform.equals(platform));
      baseQuery.where((t) => t.platform.equals(platform));
    }

    // 分类筛选
    if (category != null && category.isNotEmpty) {
      countQuery.where(_dealDao.deals.category.equals(category));
      baseQuery.where((t) => t.category.equals(category));
    }

    // 时间范围筛选
    if (startTime != null && startTime.isNotEmpty) {
      final dt = DateTime.tryParse(startTime);
      if (dt != null) {
        countQuery.where(_dealDao.deals.createdAt.isBiggerOrEqualValue(dt));
        baseQuery.where((t) => t.createdAt.isBiggerOrEqualValue(dt));
      }
    }
    if (endTime != null && endTime.isNotEmpty) {
      final dt = DateTime.tryParse(endTime);
      if (dt != null) {
        // 结束时间通常包含当天，加到当天最后一秒
        final endDt = DateTime(dt.year, dt.month, dt.day, 23, 59, 59);
        countQuery.where(_dealDao.deals.createdAt.isSmallerOrEqualValue(endDt));
        baseQuery.where((t) => t.createdAt.isSmallerOrEqualValue(endDt));
      }
    }

    // 获取总数
    final totalRow = await countQuery.getSingle();
    final total = totalRow.read(countExpr) ?? 0;

    // 分页查询
    final offset = (page - 1) * pageSize;
    baseQuery.orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    baseQuery.limit(pageSize, offset: offset);

    final dealList = await baseQuery.get();
    final results = <Map<String, dynamic>>[];

    for (final deal in dealList) {
      if (search != null && search.isNotEmpty) {
        final lower = search.toLowerCase();
        if (!deal.title.toLowerCase().contains(lower) &&
            !deal.platform.toLowerCase().contains(lower) &&
            !deal.category.toLowerCase().contains(lower)) {
          continue;
        }
      }
      results.add(_dealToJson(deal));
    }

    return _jsonResponse(200, {
      'data': results,
      'pagination': {
        'page': page,
        'pageSize': pageSize,
        'total': total,
        'pages': (total / pageSize).ceil(),
      },
    });
  }

  // ==================== 单个查询 ====================

  Future<Response> _getDeal(Request request, String id) async {
    final detail = await _dealDao.getDealById(id);
    if (detail == null) {
      return _jsonResponse(404, {'error': 'Deal not found'});
    }
    return _jsonResponse(200, {'data': _dealWithDetailsToJson(detail)});
  }

  // ==================== 单个新增 ====================

  Future<Response> _createDeal(Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body) as Map<String, dynamic>;

    final deal = _jsonToDeal(json);
    final detail = DealWithDetails(
      deal: deal,
      tags: _parseStringList(json['tags']),
      promotions: _parseStringList(json['promotions']),
      coupons: _parseCoupons(deal.id, json['coupons']),
      image: null,
    );

    await _dealDao.saveDeal(detail);
    return _jsonResponse(201, {'data': _dealToJson(deal)});
  }

  // ==================== 批量新增 ====================

  Future<Response> _batchCreateDeals(Request request) async {
    final body = await request.readAsString();
    final list = jsonDecode(body) as List;
    final results = <Map<String, dynamic>>[];

    for (final item in list) {
      final json = item as Map<String, dynamic>;
      final deal = _jsonToDeal(json);
      final detail = DealWithDetails(
        deal: deal,
        tags: _parseStringList(json['tags']),
        promotions: _parseStringList(json['promotions']),
        coupons: _parseCoupons(deal.id, json['coupons']),
        image: null,
      );
      await _dealDao.saveDeal(detail);
      results.add(_dealToJson(deal));
    }

    return _jsonResponse(201, {'data': results, 'count': results.length});
  }

  // ==================== 更新 ====================

  Future<Response> _updateDeal(Request request, String id) async {
    final existing = await _dealDao.getDealById(id);
    if (existing == null) {
      return _jsonResponse(404, {'error': 'Deal not found'});
    }

    final body = await request.readAsString();
    final json = jsonDecode(body) as Map<String, dynamic>;

    final deal = existing.deal.copyWith(
      title: json['title'] != null ? json['title'] as String : null,
      platform: json['platform'] != null ? json['platform'] as String : null,
      category: json['category'] != null ? json['category'] as String : null,
      currentPrice: json['currentPrice'] != null ? (json['currentPrice'] as num).toDouble() : null,
      originalPrice: json['originalPrice'] != null ? Value<double?>((json['originalPrice'] as num).toDouble()) : const Value<double?>.absent(),
      displayPrice: json['displayPrice'] != null ? Value<double?>((json['displayPrice'] as num).toDouble()) : const Value<double?>.absent(),
      currency: json['currency'] != null ? json['currency'] as String : null,
      discount: json['discount'] != null ? Value<String?>(json['discount'] as String?) : const Value<String?>.absent(),
      logistics: json['logistics'] != null ? Value<String?>(json['logistics'] as String?) : const Value<String?>.absent(),
      link: json['link'] != null ? Value<String?>(json['link'] as String?) : const Value<String?>.absent(),
      note: json['note'] != null ? Value<String?>(json['note'] as String?) : const Value<String?>.absent(),
      visualType: json['visualType'] != null ? json['visualType'] as String : null,
      asciiArt: json['asciiArt'] != null ? Value<String?>(json['asciiArt'] as String?) : const Value<String?>.absent(),
      salesJson: json['salesJson'] != null ? Value<String?>(json['salesJson'] as String?) : const Value<String?>.absent(),
      updatedAt: DateTime.now(),
    );

    final detail = DealWithDetails(
      deal: deal,
      tags: json.containsKey('tags') ? _parseStringList(json['tags']) : existing.tags,
      promotions: json.containsKey('promotions') ? _parseStringList(json['promotions']) : existing.promotions,
      coupons: json.containsKey('coupons') ? _parseCoupons(deal.id, json['coupons']) : existing.coupons,
      image: existing.image,
    );

    await _dealDao.saveDeal(detail);
    return _jsonResponse(200, {'data': _dealToJson(deal)});
  }

  // ==================== 单个删除（软删除） ====================

  Future<Response> _deleteDeal(Request request, String id) async {
    await _dealDao.softDeleteDeal(id);
    return _jsonResponse(200, {'message': 'Deleted'});
  }

  // ==================== 批量删除（软删除） ====================

  Future<Response> _batchDeleteDeals(Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final ids = (json['ids'] as List).cast<String>();

    for (final id in ids) {
      await _dealDao.softDeleteDeal(id);
    }

    return _jsonResponse(200, {'message': 'Batch deleted', 'count': ids.length});
  }

  // ==================== 工具方法 ====================

  Response _jsonResponse(int statusCode, Map<String, dynamic> data) {
    return Response(statusCode,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  Deal _jsonToDeal(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Deal(
      id: json['id'] ?? _generateId(),
      title: json['title'] ?? '',
      platform: json['platform'] ?? '其他',
      category: json['category'] ?? '其他',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      displayPrice: (json['displayPrice'] as num?)?.toDouble(),
      currency: json['currency'] ?? '¥',
      discount: json['discount'] as String?,
      logistics: json['logistics'] as String?,
      link: json['link'] as String?,
      note: json['note'] as String?,
      visualType: json['visualType'] ?? 'none',
      asciiArt: json['asciiArt'] as String?,
      salesJson: json['salesJson'] as String?,
      isLowestPrice: 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : now,
      updatedAt: now,
      revision: 1,
      deleted: 0,
      deletedAt: null,
      deviceId: null,
    );
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    return [];
  }

  List<Coupon> _parseCoupons(String dealId, dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.asMap().entries.map((e) {
        final json = e.value as Map<String, dynamic>;
        return Coupon(
          id: json['id'] ?? 0,
          dealId: dealId,
          sortOrder: e.key,
          count: (json['count'] as num?)?.toInt() ?? 1,
          source: json['source'] ?? '促销',
          strength: json['strength'] ?? '',
          note: json['note'] as String?,
        );
      }).toList();
    }
    return [];
  }

  Map<String, dynamic> _dealToJson(Deal deal) {
    return {
      'id': deal.id,
      'title': deal.title,
      'platform': deal.platform,
      'category': deal.category,
      'currentPrice': deal.currentPrice,
      'originalPrice': deal.originalPrice,
      'displayPrice': deal.displayPrice,
      'currency': deal.currency,
      'discount': deal.discount,
      'logistics': deal.logistics,
      'link': deal.link,
      'note': deal.note,
      'visualType': deal.visualType,
      'asciiArt': deal.asciiArt,
      'salesJson': deal.salesJson,
      'isLowestPrice': deal.isLowestPrice,
      'createdAt': deal.createdAt.toIso8601String(),
      'updatedAt': deal.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _dealWithDetailsToJson(DealWithDetails detail) {
    return {
      ..._dealToJson(detail.deal),
      'tags': detail.tags,
      'promotions': detail.promotions,
      'coupons': detail.coupons.map((c) => {
        'id': c.id,
        'count': c.count,
        'source': c.source,
        'strength': c.strength,
        'note': c.note,
      }).toList(),
      'image': detail.image != null ? {
        'dealId': detail.image!.dealId,
        'imagePath': detail.image!.imagePath,
        'thumbPath': detail.image!.thumbPath,
      } : null,
    };
  }

  String _generateId() {
    final now = DateTime.now();
    final random = Random.secure().nextInt(999999).toString().padLeft(6, '0');
    return 'deal_${now.millisecondsSinceEpoch}_$random';
  }
}
