import 'package:flutter/material.dart';
import 'antd_colors.dart';

/// 折多多扩展颜色 - 兼容层
/// 新代码请直接使用 AntdColors
class AppColors {
  // Brand color
  static const Color brandColor = AntdColors.primary;

  // Platform colors
  static Color getPlatformColor(String platform) {
    return AntdColors.getPlatformColor(platform);
  }

  // Status colors
  static const Color success = AntdColors.success;
  static const Color warning = AntdColors.warning;
  static const Color error = AntdColors.error;
  static const Color info = AntdColors.info;

  // Discount badge colors
  static const Color discountBg = Color(0xFFFFF7E6);
  static const Color discountText = Color(0xFFD46B08);
  static const Color discountBgDark = Color(0xFF332200);
  static const Color discountTextDark = Color(0xFFFFAA33);
}
