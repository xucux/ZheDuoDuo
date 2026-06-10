// 折多多应用根组件
//
// 配置 MaterialApp.router，包括：
// - 亮色/暗色主题（基于 Ant Design 5.0）
// - 路由配置（GoRouter）
// - 主题模式切换（跟随系统/亮色/暗色）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared/theme/app_theme.dart';
import 'shared/theme/app_router.dart';
import 'shared/theme/theme_provider.dart';

class ZheDuoDuoApp extends ConsumerWidget {
  const ZheDuoDuoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: '折多多',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
