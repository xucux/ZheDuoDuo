
## UI 设计规范

> 以下规范基于当前 Flutter 项目实际代码梳理，涵盖主题、颜色、字体、组件、布局、交互等方面，用于指导后续开发及原型设计。

### 1. 设计原则

- **设计体系**：基于 Ant Design 5.0 设计规范，Material 3 组件适配
- **平台风格**：移动端优先，iOS/Android 统一体验
- **信息密度**：中高密度，单屏展示尽可能多的有效信息
- **视觉层次**：通过颜色深浅、字号大小、间距留白建立清晰的层级关系

### 2. 色彩体系

#### 2.1 品牌色

| 名称 | 色值 | 用途 |
|------|------|------|
| Primary | `#46C01B` | 主按钮、激活状态、链接、价格强调 |
| Primary Hover | `#5CD32E` | 悬停状态 |
| Primary Active | `#3AA816` | 按下状态 |
| Primary BG | `#F0FFF0` | 轻量背景、选中态底色 |
| Primary BG Hover | `#D7F0CD` | 悬停背景 |
| Primary Border | `#B7EB8F` | 边框强调 |

#### 2.2 功能色

| 名称 | 色值 | 用途 |
|------|------|------|
| Success | `#52C41A` | 成功状态、正向反馈 |
| Warning | `#FAAD14` | 警告、优惠券标识 |
| Error | `#FF4D4F` | 错误、删除操作、原价删除线旁的价格 |
| Info | `#1677FF` | 信息提示 |

#### 2.3 折扣/促销专属色

| 名称 | 色值 | 用途 |
|------|------|------|
| Discount BG | `#FFF7E6` | 折扣标签背景（亮） |
| Discount Text | `#D46B08` | 折扣标签文字（亮） |
| Discount BG Dark | `#332200` | 折扣标签背景（暗） |
| Discount Text Dark | `#FFAA33` | 折扣标签文字（暗） |
| 史低 BG | `#E8F5E9` | 史低标识背景 |
| 史低 Text | `#2E7D32` | 史低标识文字 |
| 券 BG | `#FFF3E0` | 优惠券标签背景 |
| 券 Text | `#E65100` | 优惠券标签文字 |

#### 2.4 中性色（亮色模式）

| 层级 | 色值 | 用途 |
|------|------|------|
| Text Base | `#141414` | 最强调文字 |
| Text | `#1F1F1F` | 主标题、正文 |
| Text Secondary | `#595959` | 副标题、次要信息 |
| Text Tertiary | `#8C8C8C` | 辅助说明、占位符 |
| Text Quaternary | `#BFBFBF` | 禁用状态、分割线 |
| BG Base | `#FFFFFF` | 页面底层背景 |
| BG | `#F5F5F5` | 页面背景、分组背景 |
| BG Elevated | `#FFFFFF` | 浮层背景 |
| BG Container | `#FFFFFF` | 卡片背景 |
| BG Layout | `#F5F5F5` | 整体布局背景 |
| Border | `#D9D9D9` | 边框 |
| Border Secondary | `#E8E8E8` | 轻量边框 |
| Split | `#F0F0F0` | 分割线 |

#### 2.5 暗色模式映射

暗色模式采用对应层级的反色逻辑，背景以 `#141414` 为基底，文字以 90%/70%/50%/30% 透明度的白色递进。

#### 2.6 平台品牌色

| 平台 | 色值 |
|------|------|
| 京东 | `#E2231A` |
| 淘宝 | `#FF6A00` |
| 天猫 | `#FF0036` |
| 拼多多 | `#E02E24` |
| 抖音 | `#000000` |
| 快手 | `#FF4906` |
| 得物 | `#1A1A1A` |
| 苏宁 | `#E60012` |
| 其他 | `#8C8C8C` |

### 3. 字体规范

#### 3.1 字体栈

```dart
fontFamily: '-apple-system',
fontFamilyFallback: [
  'BlinkMacSystemFont', 'Segoe UI', 'PingFang SC',
  'Hiragino Sans GB', 'Microsoft YaHei',
  'Helvetica Neue', 'Noto Sans SC', 'Roboto',
]
```

#### 3.2 字号体系

| Token | 字号 | 字重 | 用途 |
|-------|------|------|------|
| displayLarge | 28 | w600 | 超大标题 |
| displayMedium | 24 | w600 | 大标题 |
| displaySmall | 20 | w600 | 页面标题 |
| headlineLarge | 20 | w600 | 模块标题 |
| headlineMedium | 18 | w600 | 卡片标题 |
| headlineSmall | 16 | w600 | 小标题 |
| titleLarge | 16 | w600 | 列表标题 |
| titleMedium | 15 | w500 | 按钮文字、标签 |
| titleSmall | 14 | w500 | 表单标签 |
| bodyLarge | 16 | normal | 大段正文 |
| bodyMedium | 14 | normal | 标准正文 |
| bodySmall | 14 | normal | 辅助正文（灰色） |
| labelLarge | 14 | w500 | 按钮、标签 |
| labelMedium | 12 | w500 | 小标签、时间戳 |
| labelSmall | 12 | normal | 辅助说明 |

**实际开发常用字号映射**：
- 页面标题：`17-20px`，`w600`
- 卡片标题：`13-14px`，`w500-600`
- 正文内容：`13-14px`，`normal`
- 辅助文字：`10-12px`，`normal`
- 标签/徽章：`9-10px`，`w500-600`

### 4. 间距与圆角

#### 4.1 圆角

| Token | 值 | 用途 |
|-------|-----|------|
| radiusXS | 2 | 极小元素 |
| radiusSM | 4 | 标签、徽章 |
| radius | 6 | 按钮、输入框、小卡片 |
| radiusLG | 8 | 标准卡片、弹窗 |
| radiusXL | 12 | 底部弹窗、大卡片 |
| radiusRound | 999 | 圆形按钮、头像 |

#### 4.2 间距

| Token | 值 | 用途 |
|-------|-----|------|
| marginXS | 8 | 紧凑间距 |
| marginSM | 12 | 元素间小间距 |
| margin | 16 | 标准页面边距 |
| marginLG | 24 | 模块间距 |
| marginXL | 32 | 大块间距 |

#### 4.3 页面边距规范

- 列表页卡片边距：`horizontal: 16`
- 详情页内容边距：`all: 16`
- 表单项间距：`height: 14`
- 卡片内边距：`all: 12-16`
- 底部安全区：`bottom: 32`

### 5. 组件规范

#### 5.1 AppBar

```dart
AppBarTheme(
  backgroundColor: colorScheme.surface,  // 白色/暗色表面
  foregroundColor: colorScheme.onSurface,
  elevation: 0,
  scrolledUnderElevation: 1,
  surfaceTintColor: Colors.transparent,
  centerTitle: true,
  titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
  iconTheme: IconThemeData(size: 22),
)
```

- 标题居中，字号 17px， semibold
- 无阴影（elevation: 0），滚动时轻微提升
- 背景与页面表面色一致

#### 5.2 底部导航 NavigationBar

```dart
NavigationBarThemeData(
  height: 56,
  elevation: 0,
  indicatorColor: Colors.transparent,
  labelTextStyle: WidgetStateProperty.resolveWith((states) {
    final isSelected = states.contains(WidgetState.selected);
    return TextStyle(
      fontSize: 11,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      color: isSelected ? primary : outline,
    );
  }),
  iconTheme: WidgetStateProperty.resolveWith((states) {
    final isSelected = states.contains(WidgetState.selected);
    return IconThemeData(size: 22, color: isSelected ? primary : outline);
  }),
)
```

- 三 Tab：清单 / AI / 我的
- 图标 22px，文字 11px
- 选中时加粗 + 品牌色

#### 5.3 卡片 Card

```dart
CardThemeData(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),  // radiusLG
    side: BorderSide(color: borderSecondary, width: 1),
  ),
  margin: EdgeInsets.zero,
)
```

- 无阴影，依赖边框区分
- 圆角 8px
- 边框色 `Border Secondary`
- 列表页卡片可叠加 `Clip.antiAlias`

#### 5.4 按钮

**Primary Button (FilledButton)**
```dart
FilledButton.styleFrom(
  backgroundColor: primary,
  foregroundColor: Colors.white,
  elevation: 0,
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
)
```

**Default Button (OutlinedButton)**
```dart
OutlinedButton.styleFrom(
  foregroundColor: text,
  elevation: 0,
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  side: BorderSide(color: border),
)
```

**Text Button**
```dart
TextButton.styleFrom(
  foregroundColor: primary,
  elevation: 0,
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
)
```

- 统一圆角 6px
- 文字 14px，medium 字重
- 无阴影风格

#### 5.5 输入框

```dart
InputDecorationTheme(
  filled: true,
  fillColor: isLight ? Colors.transparent : darkBgContainer,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: BorderSide(color: border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: BorderSide(color: primary, width: 1.5),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
)
```

- 圆角 6px
- 聚焦时边框变为品牌色，宽度 1.5
- 填充色透明（亮色）/暗色容器（暗色）

#### 5.6 标签 Chip / Badge

```dart
ChipThemeData(
  backgroundColor: bg,
  selectedColor: primaryBg,
  labelStyle: TextStyle(fontSize: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(4),  // radiusSM
    side: BorderSide(color: border),
  ),
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
)
```

**平台标签**
- 背景：`primary.withOpacity(0.12)`
- 文字：`primary`
- 圆角：4px
- 字号：10-13px

**分类标签**
- 背景：`surfaceContainerHighest`
- 文字：`onSurfaceVariant`
- 圆角：4px

**优惠券标签**
- 背景：`#FFF3E0`
- 文字：`#E65100`
- 图标：`confirmation_num_outlined`

**折扣标签**
- 背景：`#FFF7E6`
- 文字：`#D46B08`
- 圆角：4-6px

**史低标签**
- 背景：`#E8F5E9`
- 文字：`#2E7D32`
- 图标：`trending_down`

#### 5.7 列表项 ListTile

```dart
ListTileThemeData(
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
  subtitleTextStyle: TextStyle(fontSize: 13, color: onSurfaceVariant, height: 1.5),
  iconColor: textSecondary,
)
```

- 标题 15px medium
- 副标题 13px，灰色
- 内容区左右边距 16px
- 视觉密度 `compact`

#### 5.8 底部弹窗 BottomSheet

```dart
BottomSheetThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),  // radiusXL
  ),
  showDragHandle: true,
  dragHandleColor: textQuaternary,
)
```

- 顶部圆角 12px
- 显示拖拽指示条
- 背景与表面色一致

#### 5.9 弹窗 Dialog

```dart
DialogThemeData(
  elevation: 3,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
  contentTextStyle: TextStyle(fontSize: 14, height: 1.57),
)
```

- 圆角 8px
- 标题 17px semibold
- 内容 14px，行高 1.57

#### 5.10 SnackBar

```dart
SnackBarThemeData(
  backgroundColor: isLight ? Color(0xFF1F1F1F) : Color(0xFF424242),
  contentTextStyle: TextStyle(color: Colors.white, fontSize: 14, height: 1.57),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  behavior: SnackBarBehavior.floating,
  elevation: 2,
)
```

- 深色背景 + 白色文字
- 圆角 6px
- 浮动行为，底部居中

### 6. 页面布局规范

#### 6.1 三栏导航结构

```
┌─────────────────┐
│    AppBar       │  ← 标题居中，返回/操作图标
├─────────────────┤
│                 │
│   内容区域       │  ← ListView / CustomScrollView
│                 │
├─────────────────┤
│  BottomNavBar   │  ← 清单 / AI / 我的
└─────────────────┘
```

- 底部导航高度 56px
- 内容区底部预留安全区

#### 6.2 优惠清单列表页

**正常列表模式**
```
┌─────────────────────────────┐
│ 优惠清单              🔍 ⚙️ │
│ 共 6 条                     │
├─────────────────────────────┤
│ [全部] [平台▼] [分类▼] [排序▼] │  ← 快捷筛选 Chip，横向滚动
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ 商品标题文字...     [有图]│ │  ← 标题 + 视觉标识
│ │ [京东] [百亿补贴] [2张券] │ │  ← 平台 + 标签 + 券
│ │ ¥7499  ~~¥8999~~  [8.3折]│ │  ← 价格 + 原价 + 折扣
│ │ ─────────────────────── │ │
│ │ 06-01              ✏️ 🗑️│ │  ← 日期 + 史低 + 操作
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

- 卡片圆角 10px（代码中），细边框
- 标题最多 2 行截断
- 标签最多展示 2 个分类标签
- 底部操作按钮（编辑/删除）阻止点击冒泡

**卡片网格模式（两列）**
```
┌─────────────┬─────────────┐
│ 商品标题... │ 商品标题... │
│             │             │
│ [京东]      │ [拼多多]    │
│ ¥7499       │ ¥3699       │
│         [图]│         [图]│
└─────────────┴─────────────┘
```

- 两列网格，间距 6px
- 卡片宽高比约 1.3
- 右侧展示 48×48 缩略图或 ASCII 缩略图
- 底部对齐价格和图片

#### 6.3 优惠详情页

```
┌─────────────────────────────┐
│ ← 优惠详情          ⋮       │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │                         │ │  ← SliverAppBar 可折叠头图
│ │      [商品图片]          │ │    高度 280（有图）/ 120（无图）
│ │                    [🔍] │ │
│ └─────────────────────────┘ │
│ [京东] [数码]                │  ← 平台色标签 + 分类标签
│ 商品完整标题名称...           │  ← 20px semibold
│ ┌─────────────────────────┐ │
│ │ 到手价              ¥xxx│ │  ← 价格卡片
│ │ ─────────────────────── │ │
│ │ 原价: ¥xxx      [x.x折] │ │
│ │ 页面展示价         ¥xxx │ │
│ │ [↓ 历史最低价]          │ │
│ └─────────────────────────┘ │
│ 优惠券                      │  ← 分组标题 16px semibold
│ ┌─────────────────────────┐ │
│ │ [2张]  满3000减300      │ │  ← 优惠券卡片 ListTile
│ │        平台满减          │ │
│ └─────────────────────────┘ │
│ 促销权益                    │
│ ┌─────────────────────────┐ │
│ │ ✅ 文案1                │ │
│ │ ✅ 文案2                │ │
│ └─────────────────────────┘ │
│ 标签 [百亿补贴] [限时]      │  ← Wrap 布局 Chip
│ 详细信息                    │
│ ┌─────────────────────────┐ │
│ │ 物流      京东物流      │ │  ← 信息行：标签 80px + 内容
│ │ 创建时间  2026-06-01    │ │
│ │ 链接      https://... 🔗│ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

- 使用 `CustomScrollView` + `SliverAppBar`
- 头图可点击放大查看
- 价格卡片使用 `Card` 包裹
- 信息行左侧固定 80px 标签宽度
- 链接可点击跳转浏览器

#### 6.4 表单页

- 顶部 `TabBar` 切换：YAML 解析 / 表单填写
- 两列布局使用 `Row` + `Expanded`（如平台+分类）
- 标签输入：逗号分隔，单行文本框
- 促销权益：多行文本框，每行一项
- 优惠券：动态增删卡片组
- 视觉内容：三选一 Toggle（无 / 图片 / ASCII）
- 底部保存按钮：`FilledButton`，全宽，padding vertical 12

### 7. 交互规范

#### 7.1 转场动画

- 页面跳转：使用 GoRouter 默认的 Material 页面转场（iOS/Cupertino 侧滑返回）
- 底部弹窗：`showModalBottomSheet`，顶部圆角滑入
- 列表滚动：`phone-scroll` 弹性滚动

#### 7.2 微交互

| 场景 | 效果 | 参数 |
|------|------|------|
| 卡片点击 | 缩放反馈 | `active:scale-[.98]` |
| 按钮点击 | 缩放反馈 | `active:scale-95` |
| 列表侧滑 | 编辑/删除操作 | `Slidable` + `BehindMotion` |
| 发送消息滚动 | 平滑滚动到底部 | `duration: 200ms`, `Curves.easeOut` |
| AI 加载指示 | 三个圆点跳动动画 | `TweenAnimationBuilder`, `duration: 600ms` |
| 图片查看 | 全屏预览 | `GestureDetector` + 渐变遮罩 |

#### 7.3 加载状态

- 页面级加载：`Center(child: CircularProgressIndicator())`
- 按钮内加载：`SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))`
- 列表空状态：图标 + 文字 + 添加引导

#### 7.4 空状态规范

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.local_offer_outlined, size: 56, color: outlineVariant),
    SizedBox(height: 12),
    Text('暂无优惠记录', style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
    SizedBox(height: 16),
    GestureDetector(
      onTap: () => context.push('/deal/new'),
      child: Text('+ 添加第一条', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: brandColor)),
    ),
  ],
)
```

- 图标 56px，灰色
- 文字 14px，灰色
- 引导操作：品牌色，14px medium

### 8. 暗色模式适配

- 所有颜色通过 `ColorScheme` 自动映射
- 卡片背景：`surface` → `darkBgContainer`
- 文字颜色：`onSurface` → `darkText`
- 边框颜色：`border` → `darkBorder`
- 折扣/促销标签使用暗色专属色值
- 图片预览遮罩、底部弹窗拖拽条等细节同步适配

### 9. 文件对应关系

| 规范项 | 代码文件 |
|--------|----------|
| 颜色定义 | `lib/shared/theme/antd_colors.dart` |
| 颜色兼容层 | `lib/shared/theme/app_colors.dart` |
| 主题配置 | `lib/shared/theme/app_theme.dart` |
| 主题状态 | `lib/shared/theme/theme_provider.dart` |
| 路由结构 | `lib/shared/theme/app_router.dart` |
| 底部导航 | `lib/shared/widgets/main_scaffold.dart` |
| 列表/卡片 UI | `lib/features/deals/ui/deal_list_screen.dart` |
| 详情页 UI | `lib/features/deals/ui/deal_detail_screen.dart` |
| 表单 UI | `lib/features/deals/ui/deal_form_screen.dart` |
| AI 对话 UI | `lib/features/ai/ui/ai_screen.dart` |
| 设置页 UI | `lib/features/settings/ui/settings_screen.dart` |
