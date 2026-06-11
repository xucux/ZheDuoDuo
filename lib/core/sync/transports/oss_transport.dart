// 阿里云 OSS 云同步传输实现
//
// 基于阿里云 OSS（Object Storage Service）RESTful API 实现 SyncTransport 接口。
// 使用 HMAC-SHA1 签名算法进行请求认证，支持上传、下载、列举和连接测试。

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../../utils/logger_util.dart';
import 'sync_transport.dart';

/// 阿里云 OSS 传输实现
///
/// 通过 OSS RESTful API 实现文件的上传、下载、列举和连接测试。
/// 认证方式为阿里云 V1 签名（Authorization: OSS AccessKeyId:Signature）。
class OssTransport implements SyncTransport {
  /// 存储桶名称
  final String _bucket;
  /// AccessKey ID
  final String _accessKeyId;
  /// AccessKey Secret
  final String _accessKeySecret;
  /// HTTP 客户端
  final Dio _dio;
  /// OSS 服务基础 URL
  late final String _baseUrl;

  /// 创建 OSS 传输实例
  ///
  /// [bucket] 存储桶名称，[region] 地域（如 cn-hangzhou），
  /// [accessKeyId] 阿里云 AccessKey ID，[accessKeySecret] 阿里云 AccessKey Secret。
  OssTransport({
    required String bucket,
    required String region,
    required String accessKeyId,
    required String accessKeySecret,
    Duration connectTimeout = const Duration(seconds: 15),
  })  : _bucket = bucket,
        _accessKeyId = accessKeyId,
        _accessKeySecret = accessKeySecret,
        _dio = Dio(
          BaseOptions(
            connectTimeout: connectTimeout,
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 120),
          ),
        ) {
    _baseUrl = 'https://$bucket.oss-$region.aliyuncs.com';
  }

  @override
  Future<void> upload(String remotePath, Uint8List data) async {
    final path = _normalizePath(remotePath);
    final date = _httpDate();
    final contentType = 'application/octet-stream';
    final contentMd5 = _md5Base64(data);
    final resource = '/$_bucket$path';
    final auth = _buildAuth('PUT', contentMd5, contentType, date, resource);

    try {
      AppLogger.instance.i('[OSS] 上传: PUT $_baseUrl$path');
      await _dio.put(
        '$_baseUrl$path',
        data: Stream.fromIterable([data]),
        options: Options(headers: {
          'Authorization': auth,
          'Date': date,
          'Content-Type': contentType,
          'Content-MD5': contentMd5,
          'Content-Length': data.length.toString(),
        }),
      );
      AppLogger.instance.i('[OSS] 上传成功');
    } on DioException catch (e) {
      AppLogger.instance.e('[OSS] 上传失败: ${e.type} ${e.message}');
      AppLogger.instance.e('[OSS] 响应: ${e.response?.statusCode} ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<Uint8List> download(String remotePath) async {
    final path = _normalizePath(remotePath);
    final date = _httpDate();
    final resource = '/$_bucket$path';
    final auth = _buildAuth('GET', '', '', date, resource);

    try {
      AppLogger.instance.i('[OSS] 下载: GET $_baseUrl$path');
      final response = await _dio.get(
        '$_baseUrl$path',
        options: Options(
          headers: {'Authorization': auth, 'Date': date},
          responseType: ResponseType.bytes,
        ),
      );
      AppLogger.instance.i('[OSS] 下载成功: ${response.statusCode}');
      return Uint8List.fromList(response.data as List<int>);
    } on DioException catch (e) {
      AppLogger.instance.e('[OSS] 下载失败: ${e.type} ${e.message}');
      AppLogger.instance.e('[OSS] 响应: ${e.response?.statusCode} ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<List<String>> list(String prefix) async {
    final query = 'prefix=${Uri.encodeComponent(_normalizePath(prefix).substring(1))}';
    final date = _httpDate();
    final canonicalResource = '/$_bucket/';
    final auth = _buildAuth('GET', '', '', date, '', query, canonicalResource);

    try {
      AppLogger.instance.i('[OSS] 列举: GET $_baseUrl/?$query');
      final response = await _dio.get(
        '$_baseUrl/?$query',
        options: Options(
          headers: {'Authorization': auth, 'Date': date},
          responseType: ResponseType.plain,
        ),
      );
      AppLogger.instance.i('[OSS] 列举成功: ${response.statusCode}');
      return _parseListResult(response.data as String);
    } on DioException catch (e) {
      AppLogger.instance.e('[OSS] 列举失败: ${e.type} ${e.message}');
      AppLogger.instance.e('[OSS] 响应: ${e.response?.statusCode} ${e.response?.data}');
      return [];
    }
  }

  @override
  Future<bool> testConnection() async {
    const testPath = '/test_zheduoduo.txt';
    final testContent = utf8.encode('zheduoduo connection test ${DateTime.now().millisecondsSinceEpoch}');

    // 1. 上传测试文件
    try {
      AppLogger.instance.i('[OSS] 测试连接: 上传测试文件 $testPath');
      await upload(testPath, Uint8List.fromList(testContent));
    } on DioException catch (e) {
      _logDioError('测试上传', e);
      throw Exception('上传失败: ${_buildErrorMessage(e)}');
    }

    // 2. 下载测试文件并校验内容
    try {
      AppLogger.instance.i('[OSS] 测试连接: 下载测试文件 $testPath');
      final downloaded = await download(testPath);
      if (downloaded.length != testContent.length ||
          _md5Base64(downloaded) != _md5Base64(testContent)) {
        throw Exception('下载内容与上传内容不一致');
      }
      AppLogger.instance.i('[OSS] 测试连接成功: 上传下载校验通过');
      return true;
    } on DioException catch (e) {
      _logDioError('测试下载', e);
      throw Exception('下载失败: ${_buildErrorMessage(e)}');
    }
  }

  /// 统一的 Dio 错误日志输出
  void _logDioError(String operation, DioException e) {
    AppLogger.instance.e('[OSS] $operation失败: ${e.type}');
    AppLogger.instance.e('[OSS] 错误信息: ${e.message}');
    final statusCode = e.response?.statusCode;
    AppLogger.instance.e('[OSS] 响应状态码: $statusCode');
    final body = _safeBodyString(e.response?.data);
    if (body.isNotEmpty) {
      AppLogger.instance.e('[OSS] 响应体: $body');
    }
    AppLogger.instance.e('[OSS] 请求URL: ${e.requestOptions.uri}');
  }

  /// 从 DioException 构建用户友好的错误消息
  String _buildErrorMessage(DioException e) {
    final detail = StringBuffer();
    if (e.response?.statusCode != null) detail.write('HTTP ${e.response!.statusCode}');
    final body = _safeBodyString(e.response?.data);
    if (body.isNotEmpty) {
      final msg = _extractOssError(body);
      if (msg != null) detail.write(' $msg');
    }
    return detail.isEmpty ? e.message ?? '未知错误' : detail.toString();
  }

  /// 安全地将响应体转为字符串
  String _safeBodyString(dynamic data) {
    if (data == null) return '';
    if (data is List<int>) return utf8.decode(data, allowMalformed: true);
    return data.toString();
  }

  String? _extractOssError(String xml) {
    try {
      final codeMatch = RegExp(r'<Code>(.*?)</Code>').firstMatch(xml);
      final msgMatch = RegExp(r'<Message>(.*?)</Message>').firstMatch(xml);
      if (codeMatch != null || msgMatch != null) {
        final code = codeMatch?.group(1);
        final msg = msgMatch?.group(1);
        return [code, msg].where((x) => x != null && x.isNotEmpty).join(' - ');
      }
    } catch (_) {}
    return null;
  }

  /// 规范化路径：确保以斜杠开头
  String _normalizePath(String path) {
    if (!path.startsWith('/')) path = '/$path';
    return path;
  }

  /// 构建阿里云 OSS 请求签名（HMAC-SHA1）
  ///
  /// [verb] HTTP 方法，[contentMd5] 内容 MD5，[contentType] 内容类型，
  /// [date] HTTP 日期，[resource] 资源路径，
  /// [query] 可选查询参数，[canonicalResource] 可选规范化资源路径。
  String _buildAuth(
    String verb,
    String contentMd5,
    String contentType,
    String date,
    String resource,
    [String query = '',
    String canonicalResource = '',
  ]) {
    final cr = canonicalResource.isNotEmpty ? canonicalResource : resource;
    final canonicalString = '$verb\n$contentMd5\n$contentType\n$date\n$cr';

    final hmacSha1 = Hmac(sha1, utf8.encode(_accessKeySecret));
    final digest = hmacSha1.convert(utf8.encode(canonicalString));
    final signature = base64Encode(digest.bytes);

    return 'OSS $_accessKeyId:$signature';
  }

  /// 生成 HTTP 日期字符串（UTC）
  String _httpDate() {
    final dateStr = DateTime.now().toUtc().toString().replaceFirst(' ', 'T');
    return dateStr;
  }

  /// 计算数据的 MD5 并返回 Base64 编码
  String _md5Base64(Uint8List data) {
    final digest = md5.convert(data);
    return base64Encode(digest.bytes);
  }

  /// 解析 OSS 列举结果 XML，提取 zip 文件名
  List<String> _parseListResult(String xml) {
    final keys = <String>[];
    final keyRegex = RegExp(r'<Key>(.*?)</Key>', caseSensitive: false);
    final matches = keyRegex.allMatches(xml);
    for (final m in matches) {
      final key = m.group(1)!.trim();
      if (key.endsWith('.zip')) {
        keys.add(Uri.decodeComponent(key.split('/').last));
      }
    }
    return keys;
  }
}
