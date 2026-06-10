import 'package:flutter/material.dart';

/// Ant Design 5.0 色板
/// 参考: https://ant.design/docs/spec/colors
class AntdColors {
  // ===== 品牌绿 (Volcano / Green) =====
  static const Color primary = Color(0xFF46C01B);
  static const Color primaryHover = Color(0xFF5CD32E);
  static const Color primaryActive = Color(0xFF3AA816);
  static const Color primaryBg = Color(0xFFF0FFF0);
  static const Color primaryBgHover = Color(0xFFD7F0CD);
  static const Color primaryBorder = Color(0xFFB7EB8F);
  static const Color primaryBorderHover = Color(0xFF73D13D);
  static const Color primaryText = Color(0xFF46C01B);
  static const Color primaryTextHover = Color(0xFF5CD32E);

  // ===== 功能色 =====
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color error = Color(0xFFFF4D4F);
  static const Color info = Color(0xFF1677FF);

  // ===== 中性色 - 亮色模式 =====
  static const Color textBase = Color(0xFF141414);
  static const Color text = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF595959);
  static const Color textTertiary = Color(0xFF8C8C8C);
  static const Color textQuaternary = Color(0xFFBFBFBF);

  static const Color bgBase = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFF5F5F5);
  static const Color bgElevated = Color(0xFFFFFFFF);
  static const Color bgContainer = Color(0xFFFFFFFF);
  static const Color bgLayout = Color(0xFFF5F5F5);
  static const Color bgSpotlight = Color(0xE6000000);

  static const Color border = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE8E8E8);
  static const Color split = Color(0xFFF0F0F0);

  // ===== 中性色 - 暗色模式 =====
  static const Color darkText = Color(0xE6FFFFFF);
  static const Color darkTextSecondary = Color(0xA6FFFFFF);
  static const Color darkTextTertiary = Color(0x73FFFFFF);
  static const Color darkTextQuaternary = Color(0x40FFFFFF);

  static const Color darkBgBase = Color(0xFF141414);
  static const Color darkBg = Color(0xFF000000);
  static const Color darkBgElevated = Color(0xFF1F1F1F);
  static const Color darkBgContainer = Color(0xFF1F1F1F);
  static const Color darkBgLayout = Color(0xFF000000);

  static const Color darkBorder = Color(0xFF424242);
  static const Color darkBorderSecondary = Color(0xFF303030);
  static const Color darkSplit = Color(0xFF303030);

  // ===== 填充色 =====
  static const Color fill = Color(0x0A000000);
  static const Color fillSecondary = Color(0x0F000000);
  static const Color fillTertiary = Color(0x14000000);
  static const Color fillQuaternary = Color(0x1A000000);

  static const Color darkFill = Color(0x1AFFFFFF);
  static const Color darkFillSecondary = Color(0x14FFFFFF);
  static const Color darkFillTertiary = Color(0x0FFFFFFF);
  static const Color darkFillQuaternary = Color(0x0AFFFFFF);

  // ===== 平台色 =====
  static const Map<String, Color> platformColors = {
    '京东': Color(0xFFE2231A),
    '淘宝': Color(0xFFFF6A00),
    '天猫': Color(0xFFFF0036),
    '拼多多': Color(0xFFE02E24),
    '抖音': Color(0xFF000000),
    '快手': Color(0xFFFF4906),
    '得物': Color(0xFF1A1A1A),
    '苏宁': Color(0xFFE60012),
    '其他': Color(0xFF8C8C8C),
  };

  static Color getPlatformColor(String platform) {
    return platformColors[platform] ?? platformColors['其他']!;
  }

  // ===== Ant Design 圆角 =====
  static const double radiusXS = 2;
  static const double radiusSM = 4;
  static const double radius = 6;
  static const double radiusLG = 8;
  static const double radiusXL = 12;
  static const double radiusRound = 999;

  // ===== Ant Design 间距 =====
  static const double marginXS = 8;
  static const double marginSM = 12;
  static const double margin = 16;
  static const double marginLG = 24;
  static const double marginXL = 32;

  // ===== Ant Design 字号 =====
  static const double fontSizeSM = 12;
  static const double fontSize = 14;
  static const double fontSizeLG = 16;
  static const double fontSizeXL = 20;
  static const double fontSizeHeading = 24;
}
