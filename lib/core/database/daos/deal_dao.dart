// 优惠数据访问对象（DAO）
//
// 提供优惠记录的增删改查操作，包括：
// - 按平台/分类/关键词筛选并监听优惠列表
// - 获取/监听单条优惠详情（含标签、促销、优惠券、图片）
// - 保存优惠（含关联数据的 upsert）
// - 软删除/硬删除/恢复优惠
// - 获取所有平台/分类/标签/数量统计

import 'dart:convert';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/deals.dart';
import '../tables/deal_tags.dart';
import '../tables/deal_promotions.dart';
import '../tables/coupons.dart';
import '../tables/deal_images.dart';
import 'sync_dao.dart';
import '../../sync/change_logger.dart';

part 'deal_dao.g.dart';

/// 优惠记录及其关联数据的聚合模型
///
/// 包含优惠主体、标签列表、促销权益列表、优惠券列表和图片信息。
class DealWithDetails {
  final Deal deal;
  final List<String> tags;
  final List<String> promotions;
  final List<Coupon> coupons;
  final DealImage? image;

  DealWithDetails({
    required this.deal,
    required this.tags,
    required this.promotions,
    required this.coupons,
    this.image,
  });
}

/// 优惠数据访问对象
///
/// 提供优惠记录的 CRUD、筛选排序、软删除等数据库操作。
@DriftAccessor(tables: [Deals, DealTags, DealPromotions, Coupons, DealImages])
class DealDao extends DatabaseAccessor<AppDatabase> with _$DealDaoMixin {
  final SyncDao? _syncDao;
  final ChangeLogger? _changeLogger;

  DealDao(super.db, [this._syncDao, this._changeLogger]);

  /// 记录 deal 变更到 sync_changelog（用于增量同步）
  Future<void> _logChange(String entityId, String operation, {List<String>? imagePaths}) async {
    final logger = _changeLogger;
    if (logger != null) {
      await logger.logDeal(entityId, operation, imagePaths: imagePaths);
      return;
    }
    // 兼容旧方式
    final syncDao = _syncDao;
    if (syncDao == null) return;
    final deviceId = await syncDao.getDeviceIdOrNull();
    if (deviceId == null || deviceId.isEmpty) return;
    final revision = await syncDao.nextRevision();
    await syncDao.logChange(
      deviceId: deviceId,
      entityType: 'deals',
      entityId: entityId,
      operation: operation,
      revision: revision,
      hasAttachment: (imagePaths != null && imagePaths.isNotEmpty) ? 1 : 0,
      attachmentPaths: imagePaths != null ? jsonEncode(imagePaths) : null,
    );
  }

  /// Watch all deals with filters
  ///
  /// [platform] 平台筛选（传入 [searchQuery] 时忽略）
  /// [category] 分类筛选（传入 [searchQuery] 时忽略）
  /// [searchQuery] 模糊搜索关键字（标题/平台/分类/备注/标签）
  /// [tag] 标签精确匹配（传入 [searchQuery] 时忽略）
  /// [sortBy] 排序字段：'price' | 'title' | 'updated_at' | 'created_at'
  /// [ascending] 是否升序排序，默认降序
  /// [startDate] 创建时间起始筛选（传入 [searchQuery] 时忽略）
  /// [endDate] 创建时间截止筛选（传入 [searchQuery] 时忽略）
  /// [limit] 分页每页数量
  /// [offset] 分页偏移量
  Stream<List<DealWithDetails>> watchAllDeals({
    String? platform,
    String? category,
    String? searchQuery,
    String? tag,
    String sortBy = 'created_at',
    bool ascending = false,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int offset = 0,
  }) {
    final hasSearch = searchQuery != null && searchQuery.isNotEmpty;
    final query = select(deals)..where((t) => t.deleted.equals(0));

    if (!hasSearch) {
      if (platform != null && platform.isNotEmpty) {
        query.where((t) => t.platform.equals(platform));
      }
      if (category != null && category.isNotEmpty) {
        query.where((t) => t.category.equals(category));
      }
      if (startDate != null && endDate != null) {
        query.where((t) => t.createdAt.isBetweenValues(startDate, endDate));
      } else if (startDate != null) {
        query.where((t) => t.createdAt.isBiggerOrEqualValue(startDate));
      } else if (endDate != null) {
        query.where((t) => t.createdAt.isSmallerOrEqualValue(endDate));
      }
    }

    // Sorting
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

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.watch().asyncMap((dealList) async {
      final results = <DealWithDetails>[];
      for (final deal in dealList) {
        // Apply search filter after query (for tags)
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final lowerQuery = searchQuery.toLowerCase();
          final matchesTitle = deal.title.toLowerCase().contains(lowerQuery);
          final matchesPlatform = deal.platform.toLowerCase().contains(lowerQuery);
          final matchesCategory = deal.category.toLowerCase().contains(lowerQuery);
          final matchesNote = deal.note?.toLowerCase().contains(lowerQuery) ?? false;

          if (!matchesTitle && !matchesPlatform && !matchesCategory && !matchesNote) {
            // Check tags
            final tags = await _getTagsForDeal(deal.id);
            if (!tags.any((t) => t.toLowerCase().contains(lowerQuery))) {
              continue;
            }
          }
        }

        // Tag filter
        if (!hasSearch && tag != null && tag.isNotEmpty) {
          final tags = await _getTagsForDeal(deal.id);
          if (!tags.any((t) => t.toLowerCase() == tag.toLowerCase())) {
            continue;
          }
        }

        results.add(await _buildDealWithDetails(deal));
      }
      return results;
    });
  }

  /// Get a single deal by ID
  Future<DealWithDetails?> getDealById(String id) async {
    final query = select(deals)..where((t) => t.id.equals(id));
    final deal = await query.getSingleOrNull();
    if (deal == null) return null;
    return _buildDealWithDetails(deal);
  }

  /// Watch a single deal by ID
  Stream<DealWithDetails?> watchDealById(String id) {
    final query = select(deals)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull().asyncMap((deal) async {
      if (deal == null) return null;
      return _buildDealWithDetails(deal);
    });
  }

  /// Insert or update a deal with all related data
  Future<void> saveDeal(DealWithDetails dealWithDetails) async {
    final deal = dealWithDetails.deal;
    List<String>? imagePaths;
    await transaction(() async {
      // Upsert deal
      await into(deals).insertOnConflictUpdate(deal);

      // Replace tags
      await (delete(dealTags)..where((t) => t.dealId.equals(deal.id))).go();
      for (final tag in dealWithDetails.tags) {
        await into(dealTags).insert(DealTag(dealId: deal.id, tag: tag));
      }

      // Replace promotions
      await (delete(dealPromotions)..where((t) => t.dealId.equals(deal.id))).go();
      for (var i = 0; i < dealWithDetails.promotions.length; i++) {
        await into(dealPromotions).insert(
          DealPromotion(dealId: deal.id, sortOrder: i, textContent: dealWithDetails.promotions[i]),
        );
      }

      // Upsert coupons: 存在主键执行修改，不存在新增，提交入参中id不存在的数据删除
      final submittedIds = dealWithDetails.coupons
          .where((c) => c.id > 0)
          .map((c) => c.id)
          .toSet();

      // 删除数据库中存在但提交中不存在的优惠券
      await (delete(coupons)
            ..where((t) => t.dealId.equals(deal.id) & t.id.isNotIn(submittedIds)))
          .go();

      // Upsert 提交的优惠券
      for (var i = 0; i < dealWithDetails.coupons.length; i++) {
        final c = dealWithDetails.coupons[i];

        if (c.id > 0) {
          // 存在主键，执行更新
          final couponToSave = c.copyWith(dealId: deal.id, sortOrder: i);
          await update(coupons).replace(couponToSave);
        } else {
          // 不存在主键，执行新增（使用 Companion 不传入 id，让 autoIncrement 生成）
          await into(coupons).insert(CouponsCompanion(
            dealId: Value(deal.id),
            sortOrder: Value(i),
            count: Value(c.count),
            source: Value(c.source),
            strength: Value(c.strength),
            note: Value(c.note),
          ));
        }
      }

      // Upsert or mark deleted image
      if (dealWithDetails.image != null) {
        await into(dealImages).insertOnConflictUpdate(dealWithDetails.image!);
        imagePaths = [dealWithDetails.image!.imagePath];
      } else {
        final existing = await (select(dealImages)..where((t) => t.dealId.equals(deal.id))).getSingleOrNull();
        if (existing != null && existing.deleted == 0) {
          await (update(dealImages)..where((t) => t.dealId.equals(deal.id))).write(
            DealImagesCompanion(
              deleted: const Value(2),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    });
    // 记录变更日志（事务外，避免影响主事务性能）
    await _logChange(deal.id, 'upsert', imagePaths: imagePaths);
  }

  /// Soft delete a deal (pending_delete)
  Future<void> softDeleteDeal(String id) async {
    final now = DateTime.now();
    final deal = await (select(deals)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (deal == null) return;

    await transaction(() async {
      await (update(deals)..where((t) => t.id.equals(id))).write(
        DealsCompanion(
          deleted: const Value(2),
          deletedAt: Value(now),
          updatedAt: Value(now),
          revision: Value(deal.revision + 1),
        ),
      );

      // 同步逻辑删除关联图片
      await (update(dealImages)..where((t) => t.dealId.equals(id) & t.deleted.equals(0))).write(
        DealImagesCompanion(
          deleted: const Value(2),
          updatedAt: Value(now),
        ),
      );
    });
    await _logChange(id, 'pending_delete');
  }

  /// Hard delete a deal
  Future<void> hardDeleteDeal(String id) async {
    await (delete(deals)..where((t) => t.id.equals(id))).go();
    await (delete(dealTags)..where((t) => t.dealId.equals(id))).go();
    await (delete(dealPromotions)..where((t) => t.dealId.equals(id))).go();
    await (delete(coupons)..where((t) => t.dealId.equals(id))).go();
    await (delete(dealImages)..where((t) => t.dealId.equals(id))).go();
    await _logChange(id, 'delete');
  }

  /// Restore a soft-deleted deal
  Future<void> restoreDeal(String id) async {
    final now = DateTime.now();
    await transaction(() async {
      await (update(deals)..where((t) => t.id.equals(id))).write(
        DealsCompanion(
          deleted: const Value(0),
          deletedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );

      // 同步恢复关联图片
      await (update(dealImages)..where((t) => t.dealId.equals(id) & t.deleted.isNotValue(0))).write(
        DealImagesCompanion(
          deleted: const Value(0),
          updatedAt: Value(now),
        ),
      );
    });
    await _logChange(id, 'upsert');
  }

  /// Get all unique platforms
  Future<List<String>> getAllPlatforms() async {
    final query = selectOnly(deals, distinct: true)
      ..addColumns([deals.platform])
      ..where(deals.deleted.equals(0));
    final results = await query.get();
    return results.map((r) => r.read(deals.platform)!).toList();
  }

  /// Get all unique categories
  Future<List<String>> getAllCategories() async {
    final query = selectOnly(deals, distinct: true)
      ..addColumns([deals.category])
      ..where(deals.deleted.equals(0));
    final results = await query.get();
    return results.map((r) => r.read(deals.category)!).toList();
  }

  /// Get all unique tags
  Future<List<String>> getAllTags() async {
    final query = selectOnly(dealTags, distinct: true)
      ..addColumns([dealTags.tag]);
    final results = await query.get();
    return results.map((r) => r.read(dealTags.tag)!).toList();
  }

  /// Get all deal IDs that have active (non-deleted) images
  Future<Set<String>> getAllImageDealIds() async {
    final query = selectOnly(dealImages, distinct: true)
      ..addColumns([dealImages.dealId])
      ..where(dealImages.deleted.equals(0));
    final results = await query.get();
    return results.map((r) => r.read(dealImages.dealId)!).toSet();
  }

  /// Get all deleted (deleted != 0) image paths for cleanup
  Future<List<({String dealId, String imagePath})>> getDeletedImagePaths() async {
    final query = select(dealImages)..where((t) => t.deleted.isNotValue(0));
    final results = await query.get();
    return results.map((r) => (dealId: r.dealId, imagePath: r.imagePath)).toList();
  }

  /// Delete all deal_images records where deleted != 0 (after file cleanup)
  Future<int> purgeDeletedImages() async {
    final deleted = await (delete(dealImages)..where((t) => t.deleted.isNotValue(0))).go();
    return deleted;
  }

  /// Count total deals
  Future<int> countDeals() async {
    final query = selectOnly(deals)
      ..addColumns([deals.id.count()])
      ..where(deals.deleted.equals(0));
    final result = await query.getSingle();
    return result.read(deals.id.count()) ?? 0;
  }

  Future<List<String>> _getTagsForDeal(String dealId) async {
    final query = select(dealTags)..where((t) => t.dealId.equals(dealId));
    final results = await query.get();
    return results.map((r) => r.tag).toList();
  }

  Future<DealWithDetails> _buildDealWithDetails(Deal deal) async {
    final tags = await _getTagsForDeal(deal.id);

    final promoQuery = select(dealPromotions)
      ..where((t) => t.dealId.equals(deal.id))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    final promos = await promoQuery.get();

    final couponQuery = select(coupons)
      ..where((t) => t.dealId.equals(deal.id))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    final couponList = await couponQuery.get();

    final imgQuery = select(dealImages)..where((t) => t.dealId.equals(deal.id));
    final img = await imgQuery.getSingleOrNull();

    return DealWithDetails(
      deal: deal,
      tags: tags,
      promotions: promos.map((p) => p.textContent).toList(),
      coupons: couponList,
      image: img,
    );
  }
}
