// 密钥密码数据访问对象（DAO）
//
// 提供密钥密码的数据库操作，包括：
// - 按类别和键名获取/设置/删除密钥
// - 按类别列出所有密钥
// - 按关联实体 ID 查询密钥
// 所有密钥以明文存储，不进行加密。

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/secrets.dart';
import '../../sync/change_logger.dart';

part 'secrets_dao.g.dart';

/// 密钥密码数据访问对象
///
/// 管理所有敏感凭证的 CRUD 操作，支持按类别和关联实体查询。
@DriftAccessor(tables: [Secrets])
class SecretsDao extends DatabaseAccessor<AppDatabase> with _$SecretsDaoMixin {
  final ChangeLogger? _changeLogger;

  SecretsDao(super.db, [this._changeLogger]);

  /// 获取指定类别和键名的密钥值
  ///
  /// [entityId] 可选，用于区分不同实体（如不同 AI 服务商）的同类型密钥。
  Future<String?> getValue(String category, String keyName, {String? entityId}) async {
    final query = select(secrets)
      ..where((t) {
        var condition = t.category.equals(category) & t.keyName.equals(keyName);
        if (entityId != null) {
          condition &= t.entityId.equals(entityId);
        } else {
          condition &= t.entityId.isNull();
        }
        return condition;
      })
      ..limit(1);
    final result = await query.getSingleOrNull();
    return result?.keyValue;
  }

  /// 设置指定类别和键名的密钥值（upsert）
  ///
  /// [entityId] 可选，用于区分不同实体的同类型密钥。
  Future<void> setValue(String category, String keyName, String keyValue, {String? entityId, String? note}) async {
    final existing = await getValue(category, keyName, entityId: entityId);
    final compositeKey = entityId != null ? '$category|$keyName|$entityId' : '$category|$keyName';
    if (existing != null) {
      await (update(secrets)..where((t) {
        var condition = t.category.equals(category) & t.keyName.equals(keyName);
        if (entityId != null) {
          condition &= t.entityId.equals(entityId);
        } else {
          condition &= t.entityId.isNull();
        }
        return condition;
      })).write(SecretsCompanion(
            keyValue: Value(keyValue),
            updatedAt: Value(DateTime.now()),
            entityId: entityId != null ? Value(entityId) : const Value.absent(),
            note: note != null ? Value(note) : const Value.absent(),
          ));
    } else {
      await into(secrets).insert(SecretsCompanion.insert(
        category: category,
        keyName: keyName,
        keyValue: keyValue,
        entityId: entityId != null ? Value(entityId) : const Value.absent(),
        note: note != null ? Value(note) : const Value.absent(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    await _changeLogger?.logSecret(compositeKey, 'upsert');
  }

  /// 删除指定类别和键名的密钥
  ///
  /// [entityId] 可选，仅删除匹配该实体的密钥。
  Future<void> deleteValue(String category, String keyName, {String? entityId}) async {
    final compositeKey = entityId != null ? '$category|$keyName|$entityId' : '$category|$keyName';
    await (delete(secrets)..where((t) {
      var condition = t.category.equals(category) & t.keyName.equals(keyName);
      if (entityId != null) {
        condition &= t.entityId.equals(entityId);
      } else {
        condition &= t.entityId.isNull();
      }
      return condition;
    })).go();
    await _changeLogger?.logSecret(compositeKey, 'delete');
  }

  /// 获取指定类别的所有密钥
  Future<List<Secret>> getByCategory(String category) async {
    return (select(secrets)..where((t) => t.category.equals(category))).get();
  }

  /// 获取指定关联实体的所有密钥
  Future<List<Secret>> getByEntityId(String entityId) async {
    return (select(secrets)..where((t) => t.entityId.equals(entityId))).get();
  }

  /// 删除指定类别的所有密钥
  Future<void> deleteByCategory(String category) async {
    final records = await getByCategory(category);
    await (delete(secrets)..where((t) => t.category.equals(category))).go();
    for (final r in records) {
      final compositeKey = r.entityId != null ? '${r.category}|${r.keyName}|${r.entityId}' : '${r.category}|${r.keyName}';
      await _changeLogger?.logSecret(compositeKey, 'delete');
    }
  }

  /// 删除指定关联实体的所有密钥
  Future<void> deleteByEntityId(String entityId) async {
    final records = await getByEntityId(entityId);
    await (delete(secrets)..where((t) => t.entityId.equals(entityId))).go();
    for (final r in records) {
      final compositeKey = r.entityId != null ? '${r.category}|${r.keyName}|${r.entityId}' : '${r.category}|${r.keyName}';
      await _changeLogger?.logSecret(compositeKey, 'delete');
    }
  }

  /// 获取指定类别和键名的密钥记录（含完整信息）
  Future<Secret?> getRecord(String category, String keyName) async {
    final query = select(secrets)
      ..where((t) => t.category.equals(category) & t.keyName.equals(keyName))
      ..limit(1);
    return query.getSingleOrNull();
  }
}
