// 本地 HTTP 服务
//
// 基于 shelf + shelf_router + shelf_static 提供统一的本地 HTTP 服务端，
// 支持后台运行和模块化路由挂载。默认端口 28256，可通过设置持久化修改。
// 静态资源从 assets/web/ 目录提供，支持 Token 鉴权（根路径 /mcp /sse 除外）。

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle, FlutterError;
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

/// 本地 HTTP 服务
///
/// 在 127.0.0.1 上启动 HTTP 服务器，使用 [Router] 注册各模块路由。
/// 使用单例模式确保全局唯一实例。
class LocalServerService {
  static LocalServerService? _instance;
  static LocalServerService get instance => _instance ??= LocalServerService._();
  LocalServerService._();

  HttpServer? _server;
  bool _running = false;
  int _port = 28256;

  /// 访问凭证 Token（默认 zheduoduo）
  String token = 'zheduoduo';

  /// 路由注册表，各模块直接在此注册路由
  final Router router = Router();

  /// 静态文件 Handler（从 assets/web/ 解压到临时目录后提供）
  Handler? _staticHandler;

  bool get isRunning => _running;
  int get port => _port;
  String get address => 'http://127.0.0.1:$_port';

  /// 启动本地服务器
  ///
  /// [port] 为 0 时尝试默认端口 28256，若被占用则递增尝试。
  Future<void> start({int port = 28256}) async {
    if (_running) return;

    // 初始化静态文件服务
    await _initStaticHandler();

    int tryPort = port;
    const maxAttempts = 10;
    for (int i = 0; i < maxAttempts; i++) {
      try {
        _server = await shelf_io.serve(_buildHandler(), InternetAddress.loopbackIPv4, tryPort);
        break;
      } on SocketException {
        tryPort++;
      }
    }

    if (_server == null) {
      throw Exception('无法绑定本地端口 $port ~ ${tryPort - 1}');
    }

    _port = _server!.port;
    _running = true;
  }

  /// 停止本地服务器
  Future<void> stop() async {
    _running = false;
    await _server?.close(force: true);
    _server = null;
  }

  /// 将 assets/web/ 下的文件解压到临时目录，并创建 shelf_static Handler
  Future<void> _initStaticHandler() async {
    final tempDir = await getTemporaryDirectory();
    final webDir = Directory('${tempDir.path}/zheduoduo_web');

    // 清理旧文件并重建
    if (webDir.existsSync()) {
      await webDir.delete(recursive: true);
    }
    await webDir.create(recursive: true);

    // 从 asset bundle 中提取所有 assets/web/ 下的文件
    List<String> webAssets;
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final assetMap = jsonDecode(manifest) as Map<String, dynamic>;
      webAssets = assetMap.keys
          .where((key) => key.startsWith('assets/web/'))
          .toList();
    } catch (_) {
      // Windows Debug 模式下 AssetManifest.json 可能缺失，回退到已知文件
      webAssets = const ['assets/web/index.html'];
    }

    for (final assetPath in webAssets) {
      final relativePath = assetPath.replaceFirst('assets/web/', '');
      final file = File('${webDir.path}/$relativePath');

      // 确保父目录存在
      await file.parent.create(recursive: true);

      final data = await rootBundle.load(assetPath);
      await file.writeAsBytes(data.buffer.asUint8List());
    }

    _staticHandler = createStaticHandler(
      webDir.path,
      defaultDocument: 'index.html',
    );
  }

  /// 构建最终的 shelf Handler
  Handler _buildHandler() {
    // Token 鉴权中间件
    final pipeline = const Pipeline()
        .addMiddleware(_authMiddleware())
        .addHandler(_routeHandler);
    return pipeline;
  }

  /// 路由分发：静态文件优先，然后走 Router
  Future<Response> _routeHandler(Request request) async {
    final path = request.url.path;

    // 静态文件路由：/ /index /index.html 及 assets/ 子路径
    if (_staticHandler != null &&
        (path == '' || path == '/' || path == 'index' || path == 'index.html' || path.startsWith('assets/'))) {
      // 将 / 和 /index 重写为 /index.html
      Request rewritten = request;
      if (path == '' || path == '/' || path == 'index') {
        rewritten = Request('GET', request.requestedUri.replace(path: '/index.html'),
            headers: request.headers, context: request.context);
      }
      final response = await _staticHandler!(rewritten);
      if (response.statusCode != HttpStatus.notFound) {
        return response;
      }
    }

    // 其他路由走 Router
    return router.call(request);
  }

  /// 鉴权中间件：根路径 /mcp /sse 及其子路径公开，其余需校验 Bearer Token
  Middleware _authMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        final path = request.url.path;

        // 公开路径
        if (path == '' || path == '/' || path == 'index' || path == 'index.html' ||
            path.startsWith('assets/') ||
            path == 'mcp' || path.startsWith('mcp/') ||
            path == 'sse' || path.startsWith('sse/')) {
          return innerHandler(request);
        }

        final authHeader = request.headers['Authorization'];
        final valid = authHeader != null && authHeader.startsWith('Bearer ') && authHeader.substring(7) == token;
        if (!valid) {
          return Response.unauthorized(
            jsonEncode({'error': 'Unauthorized', 'message': '缺少或无效的访问凭证'}),
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return innerHandler(request);
      };
    };
  }
}
