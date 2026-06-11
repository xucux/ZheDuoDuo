// WebDAV 云同步传输实现
//
// 基于 WebDAV 协议实现 SyncTransport 接口，
// 支持坚果云、NextCloud 等 WebDAV 兼容的云存储服务。

import 'dart:typed_data';
import 'package:webdav_client_plus/webdav_client_plus.dart';
import '../../utils/logger_util.dart';
import 'sync_transport.dart';

/// WebDAV 传输实现
///
/// 使用 Basic Auth 认证方式连接 WebDAV 服务，
/// 超时设置：连接 15s、发送 120s、接收 60s。
class WebDavTransport implements SyncTransport {
  final WebdavClient _client;

  /// 创建 WebDAV 传输实例
  ///
  /// [baseUrl] WebDAV 服务地址，[username] 用户名，[password] 密码。
  WebDavTransport({
    required String baseUrl,
    required String username,
    required String password,
  }) : _client = WebdavClient.basicAuth(
          url: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
          user: username,
          pwd: password,
        ) {
    _client.setConnectTimeout(15000);
    _client.setSendTimeout(120000);
    _client.setReceiveTimeout(60000);
  }

  @override
  Future<void> upload(String remotePath, Uint8List data) async {
    final path = _normalizePath(remotePath);
    AppLogger.instance.i('[WebDAV] 上传: $path');
    try {
      await _client.write(path, data);
      AppLogger.instance.i('[WebDAV] 上传成功');
    } catch (e) {
      AppLogger.instance.e('[WebDAV] 上传失败', e);
      rethrow;
    }
  }

  @override
  Future<Uint8List> download(String remotePath) async {
    final path = _normalizePath(remotePath);
    AppLogger.instance.i('[WebDAV] 下载: $path');
    try {
      final data = await _client.read(path);
      AppLogger.instance.i('[WebDAV] 下载成功: ${data.length} bytes');
      return data;
    } catch (e) {
      AppLogger.instance.e('[WebDAV] 下载失败', e);
      rethrow;
    }
  }

  @override
  Future<List<String>> list(String prefix) async {
    try {
      AppLogger.instance.i('[WebDAV] 列举: $prefix');
      final files = await _client.readDir(_normalizePath(prefix));
      AppLogger.instance.i('[WebDAV] 列举成功: ${files.length} 条目');
      return files
          .where((f) => !f.isDir && f.name.endsWith('.zip'))
          .map((f) => f.name)
          .toList();
    } catch (e) {
      AppLogger.instance.e('[WebDAV] 列举失败', e);
      return [];
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      AppLogger.instance.i('[WebDAV] 测试连接');
      await _client.ping();
      AppLogger.instance.i('[WebDAV] 连接成功');
      return true;
    } catch (e) {
      AppLogger.instance.e('[WebDAV] 连接失败', e);
      throw Exception('连接失败: $e');
    }
  }

  /// 规范化路径：移除开头的斜杠（WebDAV 客户端已包含基础路径）
  String _normalizePath(String path) {
    if (path.startsWith('/')) path = path.substring(1);
    return path;
  }
}
