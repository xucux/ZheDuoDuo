// 折多多应用入口
//
// 初始化 Flutter 绑定并通过 Riverpod 的 ProviderScope 启动应用。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/utils/logger_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.instance.init();

  runApp(
    const ProviderScope(
      child: ZheDuoDuoApp(),
    ),
  );
}
