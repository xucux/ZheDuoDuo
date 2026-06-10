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

part 'secrets_dao.g.dart';

/// 密钥密码数据访问对象
///
/// 管理所有敏感凭证的 CRUD 操作，支持按类别和关联实体查询。
@DriftAccessor(tables: [Secrets])
class SecretsDao extends DatabaseAccessor<AppDatabase> with _$SecretsDaoMixin {
  SecretsDao(super.db);

  /// 获取指定类别和键名的密钥值
  Future<String?> getValue(String category, String keyName) async {
    final query = select(secrets)
      ..where((t) => t.category.equals(category) & t.keyName.equals(keyName))
      ..limit(1);
    final result = await query.getSingleOrNull();
    return result?.keyValue;
  }

  /// 设置指定类别和键名的密钥值（upsert）
  Future<void> setValue(String category, String keyName, String keyValue, {String? entityId, String? note}) async {
    final existing = await getValue(category, keyName);
    if (existing != null) {
      await (update(secrets)..where((t) => t.category.equals(category) & t.keyName.equals(keyName)))
          .write(SecretsCompanion(
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
  }

  /// 删除指定类别和键名的密钥
  Future<void> deleteValue(String category, String keyName) async {
    await (delete(secrets)..where((t) => t.category.equals(category) & t.keyName.equals(keyName))).go();
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
    await (delete(secrets)..where((t) => t.category.equals(category))).go();
  }

  /// 删除指定关联实体的所有密钥
  Future<void> deleteByEntityId(String entityId) async {
    await (delete(secrets)..where((t) => t.entityId.equals(entityId))).go();
  }

  /// 获取指定类别和键名的密钥记录（含完整信息）
  Future<Secret?> getRecord(String category, String keyName) async {
    final query = select(secrets)
      ..where((t) => t.category.equals(category) & t.keyName.equals(keyName))
      ..limit(1);
    return query.getSingleOrNull();
  }
}
