// 密钥密码表定义
//
// 统一存储所有敏感凭证信息，包括 API Key、WebDAV 密码等。
// 所有密钥以明文存储，不进行加密。
// category 字段用于区分不同类型的凭证（ai / webdav / cos / oss 等）。

import 'package:drift/drift.dart';

/// 密钥密码表
class Secrets extends Table {
  /// 自增主键
  IntColumn get id => integer().autoIncrement()();
  /// 凭证类别（ai / webdav / cos / oss / other）
  TextColumn get category => text()();
  /// 凭证键名（如 api_key / password / access_key / secret_key）
  TextColumn get keyName => text()();
  /// 凭证值（明文存储）
  TextColumn get keyValue => text()();
  /// 关联实体 ID（如 AI 配置 ID、WebDAV 配置名等，可选）
  TextColumn get entityId => text().nullable()();
  /// 备注
  TextColumn get note => text().nullable()();
  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();
  /// 更新时间
  DateTimeColumn get updatedAt => dateTime()();
}
