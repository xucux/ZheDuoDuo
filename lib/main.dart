// 折多多应用入口
//
// 初始化 Flutter 绑定并通过 Riverpod 的 ProviderScope 启动应用。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: ZheDuoDuoApp(),
    ),
  );
}
