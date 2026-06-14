// 折多多应用入口
//
// 初始化 Flutter 绑定并通过 Riverpod 的 ProviderScope 启动应用。
// 桌面端（Windows / macOS / Linux）额外初始化窗口管理器，
// 设置默认窗口大小、最小尺寸和标题。

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/database/daos/deal_dao.dart';
import 'core/utils/logger_util.dart';
import 'features/local_server/controllers/deal_controller.dart';
import 'features/local_server/services/local_server_service.dart';
import 'features/mcp/services/mcp_server_service.dart';
import 'features/mcp/services/mcp_tool_registry.dart';
import 'features/ocr/services/ocr_service.dart';
import 'shared/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.instance.init();

  // 桌面端：初始化窗口管理器
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setSize(const Size(1024, 768));
      await windowManager.setMinimumSize(const Size(800, 600));
      await windowManager.setTitle('折多多');
      await windowManager.show();
    });
  }

  // 初始化数据库并注册本地服务端点
  final db = AppDatabase();
  final dealDao = DealDao(db);

  // 折扣 API
  LocalServerService.instance.router.mount('/api/deals/', DealController(dealDao).router.call);
  // MCP 服务
  final mcpRegistry = McpToolRegistry(db, ocrService: OcrService());
  McpServerService(mcpRegistry).registerTo(LocalServerService.instance.router);

  runApp(
    ProviderScope(
      overrides: [
        // 确保应用内使用同一个数据库实例
        databaseProvider.overrideWithValue(db),
      ],
      child: const ZheDuoDuoApp(),
    ),
  );
}
