// 阿里云 OSS 云同步传输实现
//
// 基于阿里云 OSS（Object Storage Service）RESTful API 实现 SyncTransport 接口。
// 使用 OSS V4 签名算法（HMAC-SHA256）进行请求认证，支持上传、下载、列举和连接测试。
//
// V4 签名流程：
// 1. 构造规范化请求（Canonical Request）
// 2. 构造待签名字符串（String to Sign）
// 3. 派生签名密钥（Signing Key）
// 4. 计算签名（Signature）
//
// 参考：https://help.aliyun.com/zh/oss/developer-reference/recommend-to-use-signature-version-4

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../../utils/logger_util.dart';
import 'sync_transport.dart';

/// 阿里云 OSS 传输实现
///
/// 通过 OSS RESTful API 实现文件的上传、下载、列举和连接测试。
/// 认证方式为阿里云 V4 签名（OSS4-HMAC-SHA256）。
class OssTransport implements SyncTransport {
  /// AccessKey ID
  final String _accessKeyId;
  /// AccessKey Secret
  final String _accessKeySecret;
  /// 地域 ID（如 cn-hangzhou）
  final String _region;
  /// HTTP 客户端
  final Dio _dio;
  /// OSS 服务基础 URL
  late final String _baseUrl;

  /// 创建 OSS 传输实例
  ///
  /// [bucket] 存储桶名称，[region] 地域（支持 cn-hangzhou 或 oss-cn-hangzhou 格式），
  /// [accessKeyId] 阿里云 AccessKey ID，[accessKeySecret] 阿里云 AccessKey Secret。
  OssTransport({
    required String bucket,
    required String region,
    required String accessKeyId,
    required String accessKeySecret,
    Duration connectTimeout = const Duration(seconds: 15),
  })  : _accessKeyId = accessKeyId,
        _accessKeySecret = accessKeySecret,
        // 规范化 region：去掉 oss- 前缀，确保为 cn-hangzhou 格式
        _region = region.startsWith('oss-') ? region.substring(4) : region,
        _dio = Dio(
          BaseOptions(
            connectTimeout: connectTimeout,
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 120),
          ),
        ) {
    _baseUrl = 'https://$bucket.oss-$_region.aliyuncs.com';
    // 请求拦截：记录实际发送的请求头，用于排查签名问题
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.instance.d('[OSS] 实际请求: ${options.method} ${options.uri}');
        AppLogger.instance.d('[OSS] 实际请求头: ${options.headers}');
        handler.next(options);
      },
    ));
  }

  @override
  Future<void> upload(String remotePath, Uint8List data) async {
    final path = _normalizePath(remotePath);
    final timestamp = _iso8601Timestamp();
    final dateStamp = timestamp.substring(0, 8); // YYYYMMDD

    final signHeaders = <String, String>{
      'content-type': 'application/octet-stream',
      'content-length': data.length.toString(),
      'host': Uri.parse(_baseUrl).host,
      'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      'x-oss-date': timestamp,
    };

    final additionalHeaders = 'content-type;host;x-oss-content-sha256;x-oss-date';
    final canonicalQueryString = '';

    final auth = _buildV4Auth(
      method: 'PUT',
      path: path,
      queryString: canonicalQueryString,
      signHeaders: signHeaders,
      additionalHeaders: additionalHeaders,
      payloadHash: 'UNSIGNED-PAYLOAD',
      dateStamp: dateStamp,
      timestamp: timestamp,
    );

    final requestHeaders = <String, String>{
      'Authorization': auth,
      'Content-Type': 'application/octet-stream',
      'Content-Length': data.length.toString(),
      'Host': Uri.parse(_baseUrl).host,
      'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      'x-oss-date': timestamp,
    };

    try {
      AppLogger.instance.i('[OSS] 上传: PUT $_baseUrl$path');
      await _dio.put(
        '$_baseUrl$path',
        data: data,
        options: Options(headers: requestHeaders),
      );
      AppLogger.instance.i('[OSS] 上传成功');
    } on DioException catch (e) {
      _logDioError('上传', e);
      rethrow;
    }
  }

  @override
  Future<Uint8List> download(String remotePath) async {
    final path = _normalizePath(remotePath);
    final timestamp = _iso8601Timestamp();
    final dateStamp = timestamp.substring(0, 8);

    final signHeaders = <String, String>{
      'host': Uri.parse(_baseUrl).host,
      'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      'x-oss-date': timestamp,
    };

    final additionalHeaders = 'host;x-oss-content-sha256;x-oss-date';

    final auth = _buildV4Auth(
      method: 'GET',
      path: path,
      queryString: '',
      signHeaders: signHeaders,
      additionalHeaders: additionalHeaders,
      payloadHash: 'UNSIGNED-PAYLOAD',
      dateStamp: dateStamp,
      timestamp: timestamp,
    );

    final requestHeaders = <String, String>{
      'Authorization': auth,
      'Host': Uri.parse(_baseUrl).host,
      'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      'x-oss-date': timestamp,
    };

    try {
      AppLogger.instance.i('[OSS] 下载: GET $_baseUrl$path');
      final response = await _dio.get(
        '$_baseUrl$path',
        options: Options(
          headers: requestHeaders,
          responseType: ResponseType.bytes,
        ),
      );
      AppLogger.instance.i('[OSS] 下载成功: ${response.statusCode}');
      return Uint8List.fromList(response.data as List<int>);
    } on DioException catch (e) {
      _logDioError('下载', e);
      rethrow;
    }
  }

  @override
  Future<List<String>> list(String prefix) async {
    final path = _normalizePath(prefix);
    // prefix 参数值：去掉开头的斜杠，如 "zheduoduo/"
    final prefixValue = path.substring(1);
    final timestamp = _iso8601Timestamp();
    final dateStamp = timestamp.substring(0, 8);

    // 规范化查询参数：key 和 value 分别 URI 编码，按 key 字典序排列
    final canonicalQueryString = 'prefix=${_uriEncode(prefixValue)}';

    final signHeaders = <String, String>{
      'host': Uri.parse(_baseUrl).host,
      'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      'x-oss-date': timestamp,
    };

    final additionalHeaders = 'host;x-oss-content-sha256;x-oss-date';

    final auth = _buildV4Auth(
      method: 'GET',
      path: '/',
      queryString: canonicalQueryString,
      signHeaders: signHeaders,
      additionalHeaders: additionalHeaders,
      payloadHash: 'UNSIGNED-PAYLOAD',
      dateStamp: dateStamp,
      timestamp: timestamp,
    );

    final requestHeaders = <String, String>{
      'Authorization': auth,
      'Host': Uri.parse(_baseUrl).host,
      'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      'x-oss-date': timestamp,
    };

    try {
      AppLogger.instance.i('[OSS] 列举: GET $_baseUrl/?$canonicalQueryString');
      final response = await _dio.get(
        '$_baseUrl/?$canonicalQueryString',
        options: Options(
          headers: requestHeaders,
          responseType: ResponseType.plain,
        ),
      );
      AppLogger.instance.i('[OSS] 列举成功: ${response.statusCode}');
      return _parseListResult(response.data as String);
    } on DioException catch (e) {
      _logDioError('列举', e);
      return [];
    }
  }

  @override
  Future<bool> testConnection() async {
    const testPath = '/test_zheduoduo.txt';
    final testContent =
        utf8.encode('zheduoduo connection test ${DateTime.now().millisecondsSinceEpoch}');

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
          !_listEquals(downloaded, testContent)) {
        throw Exception('下载内容与上传内容不一致');
      }
      AppLogger.instance.i('[OSS] 测试连接成功: 上传下载校验通过');
      return true;
    } on DioException catch (e) {
      _logDioError('测试下载', e);
      throw Exception('下载失败: ${_buildErrorMessage(e)}');
    }
  }

  // ==================== V4 签名核心逻辑 ====================

  /// 构建 OSS V4 签名 Authorization 头
  ///
  /// 完整流程：
  /// 1. 构造规范化请求（Canonical Request）
  /// 2. 构造待签名字符串（String to Sign）
  /// 3. 派生签名密钥（Signing Key）
  /// 4. 计算签名（Signature）
  String _buildV4Auth({
    required String method,
    required String path,
    required String queryString,
    required Map<String, String> signHeaders,
    required String additionalHeaders,
    required String payloadHash,
    required String dateStamp,
    required String timestamp,
  }) {
    // Step 1: 构造规范化请求
    final canonicalHeaders = _buildCanonicalHeaders(signHeaders);
    final canonicalRequest = [
      method,
      _uriEncode(path),
      queryString,
      canonicalHeaders,
      additionalHeaders,
      payloadHash,
    ].join('\n');

    AppLogger.instance.d('[OSS] CanonicalRequest:\n$canonicalRequest');

    // Step 2: 构造待签名字符串
    final scope = '$dateStamp/$_region/oss/aliyun_v4_request';
    final canonicalRequestHash =
        sha256.convert(utf8.encode(canonicalRequest)).toString();
    final stringToSign = [
      'OSS4-HMAC-SHA256',
      timestamp,
      scope,
      canonicalRequestHash,
    ].join('\n');

    AppLogger.instance.d('[OSS] StringToSign:\n$stringToSign');

    // Step 3: 派生签名密钥
    final signingKey = _deriveSigningKey(dateStamp);

    // Step 4: 计算签名
    final signatureBytes =
        Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).bytes;
    final signature = _bytesToHex(signatureBytes);

    // 组装 Authorization 头
    return 'OSS4-HMAC-SHA256'
        ' Credential=$_accessKeyId/$scope'
        ', AdditionalHeaders=$additionalHeaders'
        ', Signature=$signature';
  }

  /// 派生 V4 签名密钥
  ///
  /// DateKey = HMAC-SHA256(("aliyun_v4" + SK), Date)
  /// DateRegionKey = HMAC-SHA256(DateKey, Region)
  /// DateRegionServiceKey = HMAC-SHA256(DateRegionKey, "oss")
  /// SigningKey = HMAC-SHA256(DateRegionServiceKey, "aliyun_v4_request")
  List<int> _deriveSigningKey(String dateStamp) {
    final dateKey = Hmac(sha256, utf8.encode('aliyun_v4$_accessKeySecret'))
        .convert(utf8.encode(dateStamp))
        .bytes;
    final dateRegionKey = Hmac(sha256, dateKey)
        .convert(utf8.encode(_region))
        .bytes;
    final dateRegionServiceKey = Hmac(sha256, dateRegionKey)
        .convert(utf8.encode('oss'))
        .bytes;
    final signingKey = Hmac(sha256, dateRegionServiceKey)
        .convert(utf8.encode('aliyun_v4_request'))
        .bytes;
    return signingKey;
  }

  /// 构造规范化请求头
  ///
  /// 格式：小写 key:value，按 key 字典序排列，每行一个，末尾换行
  String _buildCanonicalHeaders(Map<String, String> headers) {
    final sortedKeys = headers.keys.toList()..sort();
    final lines = <String>[];
    for (final key in sortedKeys) {
      // 值去除前后空格，连续空格合并为单个
      final value = headers[key]!.trim().replaceAll(RegExp(r'\s+'), ' ');
      lines.add('$key:$value');
    }
    return '${lines.join('\n')}\n';
  }

  // ==================== 工具方法 ====================

  /// 生成 ISO 8601 时间戳（UTC），格式：YYYYMMDDTHHmmssZ
  String _iso8601Timestamp() {
    final now = DateTime.now().toUtc();
    return '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        'T'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}'
        'Z';
  }

  /// URI 编码（V4 规范）：正斜线不编码
  String _uriEncode(String input) {
    return Uri.encodeComponent(input).replaceAll('%2F', '/');
  }

  /// 字节数组转十六进制字符串（小写）
  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// 比较两个字节数组内容是否一致
  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// 规范化路径：确保以斜杠开头
  String _normalizePath(String path) {
    if (!path.startsWith('/')) path = '/$path';
    return path;
  }

  /// 统一的 Dio 错误日志输出
  void _logDioError(String operation, DioException e) {
    final req = e.requestOptions;
    AppLogger.instance.e('[OSS] $operation失败: ${e.type}');
    AppLogger.instance.e('[OSS] 错误信息: ${e.message}');
    AppLogger.instance.e('[OSS] 请求方法: ${req.method}');
    AppLogger.instance.e('[OSS] 请求URL: ${req.uri}');
    AppLogger.instance.e('[OSS] 请求头: ${req.headers}');
    final statusCode = e.response?.statusCode;
    AppLogger.instance.e('[OSS] 响应状态码: $statusCode');
    final body = _safeBodyString(e.response?.data);
    if (body.isNotEmpty) {
      AppLogger.instance.e('[OSS] 响应体: $body');
    }
  }

  /// 从 DioException 构建用户友好的错误消息
  String _buildErrorMessage(DioException e) {
    final detail = StringBuffer();
    if (e.response?.statusCode != null) {
      detail.write('HTTP ${e.response!.statusCode}');
    }
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

  /// 从 OSS 错误 XML 中提取错误码和消息
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

  @override
  Future<void> delete(String remotePath) async {
    final path = _normalizePath(remotePath);
    final timestamp = _iso8601Timestamp();
    final dateStamp = timestamp.substring(0, 8);

    final signHeaders = <String, String>{
      'host': Uri.parse(_baseUrl).host,
      'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      'x-oss-date': timestamp,
    };

    final additionalHeaders = 'host;x-oss-content-sha256;x-oss-date';

    final auth = _buildV4Auth(
      method: 'DELETE',
      path: path,
      queryString: '',
      signHeaders: signHeaders,
      additionalHeaders: additionalHeaders,
      payloadHash: 'UNSIGNED-PAYLOAD',
      dateStamp: dateStamp,
      timestamp: timestamp,
    );

    final requestHeaders = <String, String>{
      'Authorization': auth,
      'Host': Uri.parse(_baseUrl).host,
      'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      'x-oss-date': timestamp,
    };

    try {
      AppLogger.instance.i('[OSS] 删除: DELETE $_baseUrl$path');
      await _dio.delete(
        '$_baseUrl$path',
        options: Options(headers: requestHeaders),
      );
      AppLogger.instance.i('[OSS] 删除成功');
    } on DioException catch (e) {
      _logDioError('删除', e);
      rethrow;
    }
  }

  @override
  Future<List<RemoteFileInfo>> listDetails(String prefix) async {
    final path = _normalizePath(prefix);
    final prefixValue = path.substring(1);
    final timestamp = _iso8601Timestamp();
    final dateStamp = timestamp.substring(0, 8);

    final canonicalQueryString = 'prefix=${_uriEncode(prefixValue)}';

    final signHeaders = <String, String>{
      'host': Uri.parse(_baseUrl).host,
      'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      'x-oss-date': timestamp,
    };

    final additionalHeaders = 'host;x-oss-content-sha256;x-oss-date';

    final auth = _buildV4Auth(
      method: 'GET',
      path: '/',
      queryString: canonicalQueryString,
      signHeaders: signHeaders,
      additionalHeaders: additionalHeaders,
      payloadHash: 'UNSIGNED-PAYLOAD',
      dateStamp: dateStamp,
      timestamp: timestamp,
    );

    final requestHeaders = <String, String>{
      'Authorization': auth,
      'Host': Uri.parse(_baseUrl).host,
      'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      'x-oss-date': timestamp,
    };

    try {
      AppLogger.instance.i('[OSS] 列举详情: GET $_baseUrl/?$canonicalQueryString');
      final response = await _dio.get(
        '$_baseUrl/?$canonicalQueryString',
        options: Options(
          headers: requestHeaders,
          responseType: ResponseType.plain,
        ),
      );
      AppLogger.instance.i('[OSS] 列举详情成功: ${response.statusCode}');
      return _parseListDetailsResult(response.data as String);
    } on DioException catch (e) {
      _logDioError('列举详情', e);
      return [];
    }
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

  List<RemoteFileInfo> _parseListDetailsResult(String xml) {
    final infos = <RemoteFileInfo>[];
    final contentsRegex = RegExp(r'<Contents>(.*?)</Contents>', caseSensitive: false, dotAll: true);
    for (final contentMatch in contentsRegex.allMatches(xml)) {
      final content = contentMatch.group(1)!;
      final keyMatch = RegExp(r'<Key>(.*?)</Key>', caseSensitive: false).firstMatch(content);
      final sizeMatch = RegExp(r'<Size>(\d+)</Size>', caseSensitive: false).firstMatch(content);
      final modifiedMatch = RegExp(r'<LastModified>(.*?)</LastModified>', caseSensitive: false).firstMatch(content);
      if (keyMatch == null) continue;
      final key = keyMatch.group(1)!.trim();
      if (!key.endsWith('.zip')) continue;
      final name = Uri.decodeComponent(key.split('/').last);
      final size = int.tryParse(sizeMatch?.group(1) ?? '0') ?? 0;
      final modifiedAt = DateTime.tryParse(modifiedMatch?.group(1) ?? '') ?? DateTime(1970);
      infos.add(RemoteFileInfo(name: name, size: size, modifiedAt: modifiedAt));
    }
    return infos;
  }
}
