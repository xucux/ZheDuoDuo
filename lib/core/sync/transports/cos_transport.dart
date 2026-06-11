// 腾讯云 COS 云同步传输实现
//
// 基于腾讯云 COS（Cloud Object Storage）RESTful API 实现 SyncTransport 接口。
// 使用 HMAC-SHA1 签名算法进行请求认证，支持上传、下载、列举和连接测试。

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../../utils/logger_util.dart';
import 'sync_transport.dart';

/// 腾讯云 COS 传输实现
///
/// 通过 COS XML API 实现文件的上传、下载、列举和连接测试。
/// 认证方式为腾讯云 HMAC-SHA1 签名（q-sign-algorithm=sha1）。
class CosTransport implements SyncTransport {
  /// 存储桶名称
  final String _bucket;
  /// SecretId
  final String _secretId;
  /// SecretKey
  final String _secretKey;
  /// HTTP 客户端
  final Dio _dio;
  /// COS 服务基础 URL
  late final String _baseUrl;

  /// 创建 COS 传输实例
  ///
  /// [bucket] 存储桶名称，[region] 地域（如 ap-guangzhou），
  /// [secretId] 腾讯云 SecretId，[secretKey] 腾讯云 SecretKey，
  /// [appId] 可选的 AppId，用于拼接 bucket-appid 格式的域名。
  CosTransport({
    required String bucket,
    required String region,
    required String secretId,
    required String secretKey,
    String? appId,
    Duration connectTimeout = const Duration(seconds: 15),
  })  : _bucket = bucket,
        _secretId = secretId,
        _secretKey = secretKey,
        _dio = Dio(
          BaseOptions(
            connectTimeout: connectTimeout,
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 120),
          ),
        ) {
    final host = appId != null && appId.isNotEmpty
        ? '$_bucket-$appId.cos.$region.myqcloud.com'
        : '$_bucket.cos.$region.myqcloud.com';
    _baseUrl = 'https://$host';
    // 请求拦截：记录实际发送的请求头，用于排查签名问题
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.instance.d('[COS] 实际请求: ${options.method} ${options.uri}');
        AppLogger.instance.d('[COS] 实际请求头: ${options.headers}');
        handler.next(options);
      },
    ));
  }

  @override
  Future<void> upload(String remotePath, Uint8List data) async {
    final path = _normalizePath(remotePath);
    final method = 'PUT';
    // 只签名 COS 要求的 header，不包含 Referer
    final signHeaders = <String, String>{
      'Host': Uri.parse(_baseUrl).host,
      'Content-Type': 'application/octet-stream',
      'Content-Length': data.length.toString(),
    };

    final auth = _buildAuth(method, path, signHeaders);
    final requestHeaders = Map<String, String>.from(signHeaders)
      ..['Authorization'] = auth;

    try {
      AppLogger.instance.i('[COS] 上传: $method $_baseUrl$path');
      await _dio.put(
        '$_baseUrl$path',
        data: data,
        options: Options(headers: requestHeaders),
      );
      AppLogger.instance.i('[COS] 上传成功');
    } on DioException catch (e) {
      _logDioError('上传', e);
      rethrow;
    }
  }

  @override
  Future<Uint8List> download(String remotePath) async {
    final path = _normalizePath(remotePath);
    final method = 'GET';
    final signHeaders = <String, String>{
      'Host': Uri.parse(_baseUrl).host,
    };

    final auth = _buildAuth(method, path, signHeaders);
    final requestHeaders = Map<String, String>.from(signHeaders)
      ..['Authorization'] = auth;

    try {
      AppLogger.instance.i('[COS] 下载: $method $_baseUrl$path');
      final response = await _dio.get(
        '$_baseUrl$path',
        options: Options(
          headers: requestHeaders,
          responseType: ResponseType.bytes,
        ),
      );
      AppLogger.instance.i('[COS] 下载成功: ${response.statusCode}');
      return Uint8List.fromList(response.data as List<int>);
    } on DioException catch (e) {
      _logDioError('下载', e);
      rethrow;
    }
  }

  @override
  Future<List<String>> list(String prefix) async {
    final path = _normalizePath(prefix);
    final query = 'prefix=${Uri.encodeComponent(path)}';
    final method = 'GET';
    final signHeaders = <String, String>{
      'Host': Uri.parse(_baseUrl).host,
    };
    final auth = _buildAuth(method, '/', signHeaders, queryParams: query);
    final requestHeaders = Map<String, String>.from(signHeaders)
      ..['Authorization'] = auth;

    try {
      AppLogger.instance.i('[COS] 列举: $method $_baseUrl/?$query');
      final response = await _dio.get(
        '$_baseUrl/?$query',
        options: Options(
          headers: requestHeaders,
          responseType: ResponseType.plain,
        ),
      );
      AppLogger.instance.i('[COS] 列举成功: ${response.statusCode}');
      return _parseListResult(response.data as String);
    } on DioException catch (e) {
      _logDioError('列举', e);
      return [];
    }
  }

  @override
  Future<bool> testConnection() async {
    const testPath = '/test_zheduoduo.txt';
    final testContent = utf8.encode('zheduoduo connection test ${DateTime.now().millisecondsSinceEpoch}');

    // 1. 上传测试文件
    try {
      AppLogger.instance.i('[COS] 测试连接: 上传测试文件 $testPath');
      await upload(testPath, Uint8List.fromList(testContent));
    } on DioException catch (e) {
      _logDioError('测试上传', e);
      final detail = _buildErrorMessage(e, '上传');
      throw Exception(detail);
    }

    // 2. 下载测试文件并校验内容
    try {
      AppLogger.instance.i('[COS] 测试连接: 下载测试文件 $testPath');
      final downloaded = await download(testPath);
      if (downloaded.length != testContent.length ||
          _bytesToHex(downloaded) != _bytesToHex(testContent)) {
        throw Exception('下载内容与上传内容不一致');
      }
      AppLogger.instance.i('[COS] 测试连接成功: 上传下载校验通过');
      return true;
    } on DioException catch (e) {
      _logDioError('测试下载', e);
      final detail = _buildErrorMessage(e, '下载');
      throw Exception(detail);
    }
  }

  /// 从 DioException 构建用户友好的错误消息
  String _buildErrorMessage(DioException e, String operation) {
    final detail = StringBuffer('$operation失败');
    if (e.response?.statusCode != null) detail.write(' (HTTP ${e.response!.statusCode})');
    final body = _safeBodyString(e.response?.data);
    if (body.isNotEmpty) {
      final msg = _extractCosError(body);
      if (msg != null) detail.write(': $msg');
    }
    return detail.toString();
  }

  /// 安全地将响应体转为字符串
  String _safeBodyString(dynamic data) {
    if (data == null) return '';
    if (data is List<int>) return utf8.decode(data, allowMalformed: true);
    return data.toString();
  }

  /// 统一的 Dio 错误日志输出
  void _logDioError(String operation, DioException e) {
    final req = e.requestOptions;
    AppLogger.instance.e('[COS] $operation失败: ${e.type}');
    AppLogger.instance.e('[COS] 错误信息: ${e.message}');
    AppLogger.instance.e('[COS] 请求方法: ${req.method}');
    AppLogger.instance.e('[COS] 请求URL: ${req.uri}');
    AppLogger.instance.e('[COS] 请求头: ${req.headers}');
    final statusCode = e.response?.statusCode;
    AppLogger.instance.e('[COS] 响应状态码: $statusCode');
    final body = _safeBodyString(e.response?.data);
    if (body.isNotEmpty) {
      AppLogger.instance.e('[COS] 响应体: $body');
    }
  }

  String? _extractCosError(String xml) {
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

  /// 构建腾讯云 COS 请求签名（HMAC-SHA1）
  ///
  /// 签名格式基于腾讯云 COS Signature：
  /// - HttpString = method\npath\nparams\nheaders\n
  /// - headers 格式: key=value&key=value (值需 URL 编码)
  /// - params  格式: key=value&key=value (值需 URL 编码)
  ///
  /// [method] HTTP 方法，[path] 请求路径，[headers] 请求头，
  /// [queryParams] 可选的查询参数字符串（原始 query 部分）。
  String _buildAuth(
    String method,
    String path,
    Map<String, String> headers, {
    String queryParams = '',
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final startTime = now - 60;
    final endTime = now + 3600;
    final keyTime = '$startTime;$endTime';
    final signTime = keyTime;

    final signKey = Hmac(sha1, utf8.encode(_secretKey)).convert(utf8.encode(keyTime)).bytes;

    // 格式化 headers：key=value，值 URL 编码，用 & 连接
    final headerKeys = headers.keys.map((k) => k.toLowerCase()).toList()..sort();
    final lowerHeaders = headers.map((k, v) => MapEntry(k.toLowerCase(), v));
    final formatHeaders = headerKeys
        .map((k) => '$k=${Uri.encodeComponent(lowerHeaders[k]!.trim())}')
        .join('&');
    final signedHeaderList = headerKeys.join(';');

    // 格式化 query params：key=value，值 URL 编码，用 & 连接
    var urlParamList = '';
    var formatParameters = '';
    if (queryParams.isNotEmpty) {
      final params = queryParams.split('&').map((p) {
        final parts = p.split('=');
        final key = parts[0];
        // decodeComponent 还原原始值，再 encodeComponent 统一编码
        final value = parts.length > 1 ? Uri.decodeComponent(parts[1]) : '';
        return '$key=${Uri.encodeComponent(value)}';
      }).toList()..sort();
      formatParameters = params.join('&');
      urlParamList = params.map((p) => p.split('=')[0]).join(';');
    }

    // COS 要求 HttpString 中 method 使用小写
    final httpString = '${method.toLowerCase()}\n$path\n$formatParameters\n$formatHeaders\n';
    AppLogger.instance.d('[COS] HttpString: ${httpString.replaceAll('\n', '\\n')}');
    final httpStringSha1 = sha1.convert(utf8.encode(httpString)).toString();

    final stringToSign = 'sha1\n$signTime\n$httpStringSha1\n';
    final signatureBytes = Hmac(sha1, signKey).convert(utf8.encode(stringToSign)).bytes;
    final signature = _bytesToHex(signatureBytes);

    return 'q-sign-algorithm=sha1'
        '&q-ak=$_secretId'
        '&q-sign-time=$signTime'
        '&q-key-time=$keyTime'
        '&q-header-list=$signedHeaderList'
        '&q-url-param-list=$urlParamList'
        '&q-signature=$signature';
  }

  /// 字节数组转十六进制字符串
  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// 解析 COS 列举结果 XML，提取 zip 文件名
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
