// 折多多应用主题配置
//
// 基于 Ant Design 5.0 设计规范，提供亮色和暗色两套主题。
// 涵盖 ColorScheme、文字主题、AppBar、Card、NavigationBar、
// Input、Chip、Dialog、BottomSheet、SnackBar、Button 等组件样式。
// 所有颜色值来自 AntdColors 色板定义。

import 'package:flutter/material.dart';
import 'antd_colors.dart';

/// 折多多主题 - 基于 Ant Design 5.0 设计规范
///
/// 提供 [lightTheme] 和 [darkTheme] 两套完整的 ThemeData，
/// 统一管理应用的全局视觉风格。
class AppTheme {
  /// 亮色主题
  static ThemeData lightTheme() {
    // AntdColors used directly

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AntdColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AntdColors.primaryBgHover,
      onPrimaryContainer: AntdColors.primaryActive,
      secondary: const Color(0xFF5CD32E),
      onSecondary: Colors.white,
      secondaryContainer: AntdColors.primaryBg,
      onSecondaryContainer: AntdColors.primaryActive,
      tertiary: AntdColors.warning,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFFBE6),
      onTertiaryContainer: const Color(0xFF874D00),
      error: AntdColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFF2F0),
      onErrorContainer: const Color(0xFF820014),
      surface: AntdColors.bgContainer,
      onSurface: AntdColors.text,
      onSurfaceVariant: AntdColors.textSecondary,
      outline: AntdColors.textTertiary,
      outlineVariant: AntdColors.border,
      surfaceContainerHighest: AntdColors.bg,
      surfaceContainerHigh: const Color(0xFFFAFAFA),
      surfaceContainer: const Color(0xFFF5F5F5),
      surfaceContainerLow: AntdColors.bgContainer,
      surfaceContainerLowest: AntdColors.bgContainer,
      inverseSurface: const Color(0xFF1F1F1F),
      onInverseSurface: const Color(0xFFF5F5F5),
      scrim: Colors.black,
      shadow: Colors.black,
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  /// 暗色主题
  static ThemeData darkTheme() {
    // AntdColors used directly

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AntdColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0x3346C01B),
      onPrimaryContainer: const Color(0xFF95DE64),
      secondary: const Color(0xFF73D13D),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0x2246C01B),
      onSecondaryContainer: const Color(0xFF95DE64),
      tertiary: const Color(0xFFFFC53D),
      onTertiary: Colors.black,
      tertiaryContainer: const Color(0x33FAAD14),
      onTertiaryContainer: const Color(0xFFFFD666),
      error: const Color(0xFFFF7875),
      onError: Colors.white,
      errorContainer: const Color(0x33FF4D4F),
      onErrorContainer: const Color(0xFFFFA39E),
      surface: AntdColors.darkBgContainer,
      onSurface: AntdColors.darkText,
      onSurfaceVariant: AntdColors.darkTextSecondary,
      outline: AntdColors.darkTextTertiary,
      outlineVariant: AntdColors.darkBorder,
      surfaceContainerHighest: const Color(0xFF303030),
      surfaceContainerHigh: const Color(0xFF262626),
      surfaceContainer: AntdColors.darkBgElevated,
      surfaceContainerLow: AntdColors.darkBgBase,
      surfaceContainerLowest: AntdColors.darkBg,
      inverseSurface: const Color(0xFFF5F5F5),
      onInverseSurface: const Color(0xFF1F1F1F),
      scrim: Colors.black,
      shadow: Colors.black,
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  /// 根据亮暗模式构建完整 ThemeData
  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isLight ? AntdColors.bgLayout : AntdColors.darkBgLayout,

      // 字体 - Ant Design 默认字体栈
      fontFamily: '-apple-system',
      fontFamilyFallback: const [
        'BlinkMacSystemFont',
        'Segoe UI',
        'PingFang SC',
        'Hiragino Sans GB',
        'Microsoft YaHei',
        'Helvetica Neue',
        'Noto Sans SC',
        'Roboto',
      ],

      // 文字主题 - Ant Design 字号体系
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: colorScheme.onSurface, height: 1.3),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: colorScheme.onSurface, height: 1.3),
        displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colorScheme.onSurface, height: 1.4),
        headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colorScheme.onSurface, height: 1.4),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface, height: 1.4),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface, height: 1.5),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface, height: 1.5),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colorScheme.onSurface, height: 1.5),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurface, height: 1.5),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: colorScheme.onSurface, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: colorScheme.onSurface, height: 1.57),
        bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: colorScheme.onSurfaceVariant, height: 1.57),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurface, height: 1.57),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurface, height: 1.67),
        labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: colorScheme.onSurfaceVariant, height: 1.67),
      ),

      // AppBar - Ant Design 顶栏风格
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
      ),

      // Card - Ant Design Card 组件风格
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AntdColors.radiusLG),
          side: BorderSide(color: isLight ? AntdColors.borderSecondary : AntdColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // NavigationBar - Ant Design TabBar 风格
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        height: 56,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AntdColors.primary : colorScheme.outline,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: isSelected ? AntdColors.primary : colorScheme.outline,
          );
        }),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AntdColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),

      // Input - Ant Design Input 风格
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.transparent : AntdColors.darkBgContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AntdColors.radius),
          borderSide: BorderSide(color: isLight ? AntdColors.border : AntdColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AntdColors.radius),
          borderSide: BorderSide(color: isLight ? AntdColors.border : AntdColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AntdColors.radius),
          borderSide: const BorderSide(color: AntdColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AntdColors.radius),
          borderSide: const BorderSide(color: AntdColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle: TextStyle(
          color: isLight ? AntdColors.textQuaternary : AntdColors.darkTextQuaternary,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: isLight ? AntdColors.textSecondary : AntdColors.darkTextSecondary,
          fontSize: 14,
        ),
      ),

      // Chip - Ant Design Tag 风格
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? AntdColors.bg : AntdColors.darkBgElevated,
        selectedColor: AntdColors.primaryBg,
        labelStyle: TextStyle(
          fontSize: 12,
          color: isLight ? AntdColors.text : AntdColors.darkText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AntdColors.radiusSM),
          side: BorderSide(color: isLight ? AntdColors.border : AntdColors.darkBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isLight ? AntdColors.split : AntdColors.darkSplit,
        thickness: 1,
        space: 1,
      ),

      // Dialog - Ant Design Modal 风格
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AntdColors.radiusLG),
        ),
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
          height: 1.57,
        ),
      ),

      // BottomSheet - Ant Design Drawer 风格
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AntdColors.radiusLG)),
        ),
        showDragHandle: true,
        dragHandleColor: isLight ? AntdColors.textQuaternary : AntdColors.darkTextQuaternary,
      ),

      // SnackBar - Ant Design Message 风格
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? const Color(0xFF1F1F1F) : const Color(0xFF424242),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14, height: 1.57),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AntdColors.radius)),
        behavior: SnackBarBehavior.floating,
        elevation: 2,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
        subtitleTextStyle: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant, height: 1.5),
        iconColor: isLight ? AntdColors.textSecondary : AntdColors.darkTextSecondary,
      ),

      // FilledButton - Ant Design Primary Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AntdColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AntdColors.radius),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // OutlinedButton - Ant Design Default Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AntdColors.text,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AntdColors.radius),
          ),
          side: BorderSide(color: isLight ? AntdColors.border : AntdColors.darkBorder),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // TextButton - Ant Design Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AntdColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AntdColors.radius),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // Material tap target size
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
