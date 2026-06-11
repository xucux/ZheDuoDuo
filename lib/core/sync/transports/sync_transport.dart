// 云同步传输层抽象接口
//
// 定义云存储服务的统一操作接口，支持上传、下载、列举和连接测试。
// 具体实现包括 WebDAV、腾讯云 COS、阿里云 OSS 三种传输方式。

import 'dart:typed_data';

/// 云同步传输层接口
///
/// 所有云存储传输方式（WebDAV / COS / OSS）均需实现此接口。
/// 提供文件上传、下载、列举和连接测试四个核心操作。
abstract class SyncTransport {
  /// 上传数据到远端指定路径
  ///
  /// [remotePath] 远端文件路径，[data] 文件二进制内容。
  Future<void> upload(String remotePath, Uint8List data);

  /// 从远端下载指定路径的文件
  ///
  /// [remotePath] 远端文件路径，返回文件二进制内容。
  Future<Uint8List> download(String remotePath);

  /// 列出远端指定前缀下的所有 zip 文件名
  ///
  /// [prefix] 远端路径前缀，返回匹配的文件名列表。
  Future<List<String>> list(String prefix);

  /// 测试连接是否可用
  ///
  /// 返回 true 表示连接正常，false 表示连接失败。
  Future<bool> testConnection();
}
