# 折多多 · Flutter 技术选型

> 基于产品需求（离线优先 SQLite + WebDAV/COS/OSS 同步 + 图片压缩 + YAML 解析）的 Flutter 框架选型。

---

## 一、技术栈总览

| 层 | 推荐方案 | 版本 | 说明 |
|---|---------|------|------|
| **数据库** | `drift` + `drift_flutter` | ~2.23.x | 类型安全 SQL + 响应式查询 + 内置迁移，底层用 sqflite |
| **状态管理** | `flutter_riverpod` + `riverpod_generator` | 2.6.x | 编译期安全 DI + 响应式数据流，与 drift reactive 查询天然配合 |
| **HTTP/同步** | `dio` | 5.x | WebDAV PUT/GET + COS/OSS REST API 统一用 Dio |
| **WebDAV** | `webdav_client_plus` | 3.0.2 | 支持 GET/PUT/DELETE/MKCOL/PROPFIND，Dio 为备选 |
| **图片压缩** | `flutter_image_compress_common` | 1.0.5 | 原生平台实现，支持 JPEG/PNG/WebP |
| **YAML 解析** | `yaml` | 3.1.x | Dart 官方包，YAML 1.2 全支持 |
| **主题** | `flex_color_scheme` + `dynamic_color` | latest | 38 套内置配色 + Material 3 + 暗色模式 + Material You |
| **路由** | `go_router` | 14.x | 声明式路由，支持深链接 |
| **JSON** | `json_annotation` + `json_serializable` | latest | JSON 序列化/反序列化 |
| **数据类** | `freezed` | latest | 不可变数据类 + union types |
| **DI** | Riverpod 内置 | — | Provider 即依赖注入，无需额外框架 |

### 辅助包

| 包 | 版本 | 用途 |
|---|------|------|
| `connectivity_plus` | ^6.0.5 | 检测网络状态，触发同步 |
| `path_provider` | ^2.1.5 | 本地文件路径（图片缓存、数据库目录） |
| `cached_network_image` | ^3.4.1 | 网络图片缓存加载 |
| `image_picker` | ^1.2.1 | 本地图片选择 |
| `url_launcher` | ^6.3.0 | 优惠链接跳转浏览器 |
| `crypto` | ^3.0.6 | sync_changelog payload_hash 校验 |
| `synchronized` | any | 并发控制，防同步 push 竞态 |
| `logger` | ^2.6.2 | 开发调试日志 |
| `skeletonizer` | ^2.1.2 | 列表加载骨架屏 |
| `share_plus` | ^10.1.0 | 系统分享（分享优惠给好友） |
| `flutter_slidable` | ^3.1.0 | 列表滑动操作（滑动删除/编辑） |
| `shimmer` | ^3.0.0 | 加载闪烁效果 |
| `animations` | ^2.0.0 | Material motion 转场动画 |

---

## 二、各层详细分析

### 2.1 数据库：drift

**选 drift 而非 sqflite / Isar / Hive 的理由：**

| 方案 | 类型安全 | 响应式 | 迁移支持 | 维护状态 | 推荐 |
|------|---------|--------|---------|---------|------|
| **drift** | ✅ 编译期校验 | ✅ Stream 查询 | ✅ 内置 | ✅ 活跃 | ✅ **推荐** |
| sqflite | ❌ 原始 SQL | ❌ 手动 | ❌ 手动 | ✅ 活跃 | 可用但不如 drift |
| Isar | ✅ | ✅ | ✅ | ⚠️ 原作者退出 | ❌ 不推荐 |
| Hive | ❌ KV 存储 | ❌ | ❌ | ⚠️ 维护减少 | ❌ 不适合关系型数据 |

**drift 核心优势：**

- 类型安全 SQL — Dart 代码生成，编译期捕获查询错误
- 响应式查询 — `watchXxx()` 返回 Stream，数据变更自动刷新 UI
- 内置迁移 — `schemaVersion` + `MigrationStrategy`，与文档中 `PRAGMA user_version` 对齐
- 跨平台 — Android / iOS / macOS / Windows / Linux / Web

**与现有表设计的适配：**

文档中的 DDL（`deals`、`sync_changelog`、`sync_meta` 等）可直接映射为 drift 的 Dart 表定义：

```dart
class Deals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get platform => text().withDefault(const Constant('其他'))();
  RealColumn get currentPrice => real()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();
  // ...
  @override
  Set<Column> get primaryKey => {id};
}
```

### 2.2 状态管理：Riverpod

**选 Riverpod 而非 BLoC / GetX / Provider 的理由：**

| 方案 | 样板代码 | 可测试性 | 社区活跃度 | 推荐 |
|------|---------|---------|-----------|------|
| **Riverpod** | 少（代码生成） | ✅ 极佳 | ✅ 最活跃 | ✅ **推荐** |
| BLoC | 多 | ✅ 好 | ✅ 活跃 | 项目复杂度过高时不必要 |
| GetX | 少 | ❌ 差 | ⚠️ 衰退 | ❌ 不推荐 |
| Provider | 中 | ✅ 好 | ⚠️ 已被 Riverpod 取代 | ❌ legacy |

**Riverpod 核心优势：**

- 编译期安全 — Provider 依赖关系在构建时检查
- 响应式 — 依赖变化自动重算，配合 drift 的 `watchXxx()` 形成完整响应链
- 可测试 — `ProviderScope(overrides: [...])` 轻松 mock 任意依赖
- 代码生成 — `@riverpod` 注解减少样板

**数据流示例：**

```
drift.watchAllDeals()  →  Stream<List<Deal>>
        ↓
Riverpod Provider  →  AsyncValue<List<Deal>>
        ↓
UI Widget  →  ref.watch(dealsProvider)  →  自动刷新列表
```

### 2.3 HTTP / 同步：dio

**WebDAV 方案对比：**

| 方案 | 说明 | 推荐 |
|------|------|------|
| `webdav_client_plus` | 封装好的 WebDAV 客户端，支持 GET/PUT/DELETE/MKCOL/PROPFIND | ✅ 首选 |
| `dio` 自定义 | WebDAV 本质是 HTTP + XML，用 Dio 拦截器封装 | ✅ 备选（更灵活） |
| `http` | Dart 原生 HTTP，功能较弱 | 可用但不推荐 |

**COS/OSS 方案：**

无官方 Flutter SDK。三种方案：

| 方案 | 说明 | 推荐 |
|------|------|------|
| `dio` + S3 REST API | COS/OSS 兼容 S3 协议，Dio 直接签名调用 | ✅ **推荐** |
| `dio` + 预签名 URL | 服务端生成签名 URL，客户端直接 PUT/GET | ✅ 安全性更高 |
| 社区包（`aliyun_oss`） | 封装原生 SDK，维护不活跃 | ❌ 不推荐 |

### 2.4 图片压缩

| 方案 | 平台支持 | 性能 | 推荐 |
|------|---------|------|------|
| `flutter_image_compress_common` | Android/iOS/Web | 原生实现，快 | ✅ **推荐** |
| `image`（纯 Dart） | 全平台 | 慢（纯 Dart） | 简单场景可用 |
| `flutter_native_image` | Android/iOS | 原生 | ⚠️ 维护减少 |

压缩参数与文档对齐：宽 ≤800px，JPEG quality 0.7。

### 2.5 YAML 解析

`yaml`（3.1.x）是 Dart 官方包，YAML 1.2 全支持，是唯一需要的包。

配套：
- `yaml_writer` — 序列化为 YAML
- `yaml_edit` — 保留注释的 YAML 编辑

### 2.6 UI / 主题

**不需要重型 UI Kit。** Flutter 内置 Material 3 + `flex_color_scheme` 足够：

- `flex_color_scheme` — 38 套预设配色，细粒度子主题定制，暗色模式一键切换
- `dynamic_color` — Android 12+ 壁纸取色（Material You）

**适配折多多原型的 UI 组件：**

| 原型功能 | Flutter 组件 |
|---------|-------------|
| 优惠卡片列表 | `ListView.builder` + `Card` |
| 简单/正常展示切换 | 条件渲染 + `AnimatedSwitcher` |
| 滑动删除/编辑 | `flutter_slidable` |
| 底部弹窗（筛选） | `showModalBottomSheet` + `DraggableScrollableSheet` |
| Tab 导航 | `BottomNavigationBar` 或 `NavigationBar` |
| 搜索页 | `SearchDelegate` 或自定义 |
| 图片选择 | `image_picker` |
| ASCII 图展示 | `SelectableText` + 等宽字体 |

---

## 三、推荐架构

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                       │
│  Material 3 + flex_color_scheme + go_router       │
├─────────────────────────────────────────────────┤
│                 State Layer                       │
│  flutter_riverpod + riverpod_generator             │
│  (providers → AsyncValue<T>)                      │
├─────────────────────────────────────────────────┤
│              Repository Layer                     │
│  DealRepository / SyncRepository / ImageRepository │
├──────────────┬──────────────────────────────────┤
│  Local Data  │         Remote Data               │
│  drift       │  dio / webdav_client_plus          │
│  (SQLite)    │  (WebDAV / COS / OSS)              │
├──────────────┴──────────────────────────────────┤
│              Infrastructure                       │
│  path_provider / connectivity_plus / synchronized │
│  crypto / logger / url_launcher / uuid            │
└─────────────────────────────────────────────────┘
```

### 目录结构

```
lib/
├── main.dart
├── app.dart                        # MaterialApp + ProviderScope + Theme
├── core/
│   ├── database/
│   │   ├── app_database.dart       # drift Database 类
│   │   ├── tables/                 # drift 表定义（对应 DDL）
│   │   └── daos/                   # drift DAO（查询封装）
│   ├── sync/
│   │   ├── sync_engine.dart        # 增量/全量同步核心逻辑
│   │   ├── changelog_manager.dart  # sync_changelog 读写
│   │   └── transports/
│   │       ├── webdav_transport.dart
│   │       ├── cos_transport.dart
│   │       └── oss_transport.dart
│   └── utils/
│       ├── image_compress.dart
│       └── yaml_parser.dart
├── features/
│   ├── deals/
│   │   ├── data/
│   │   │   └── deal_repository.dart
│   │   ├── providers/
│   │   │   └── deals_provider.dart  # @riverpod
│   │   └── ui/
│   │       ├── deal_list_screen.dart
│   │       ├── deal_detail_screen.dart
│   │       └── deal_form_screen.dart
│   ├── search/
│   ├── settings/
│   │   ├── data/
│   │   │   └── settings_repository.dart
│   │   └── ui/
│   │       └── settings_screen.dart
│   └── cloud/
│       ├── providers/
│       │   └── sync_provider.dart
│       └── ui/
│           ├── cloud_sync_screen.dart
│           ├── webdav_config_screen.dart
│           ├── cos_config_screen.dart
│           └── oss_config_screen.dart
└── shared/
    ├── models/                     # freezed 数据类
    ├── widgets/                    # 公共组件
    └── theme/                      # flex_color_scheme 配置
```

---

## 四、pubspec.yaml 核心依赖

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 数据库
  drift: ^2.23.0
  drift_flutter: ^1.0.0
  sqlite3_flutter_libs: ^0.5.0

  # 状态管理
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # 网络 / 同步
  dio: ^5.0.0
  webdav_client_plus: ^3.0.2
  connectivity_plus: ^6.0.5
  crypto: ^3.0.6              # payload_hash 签名校验
  synchronized: any           # 同步并发控制

  # 图片
  flutter_image_compress_common: ^1.0.5
  image_picker: ^1.2.1
  cached_network_image: ^3.4.1

  # 数据
  yaml: ^3.1.2
  json_annotation: ^4.9.0
  freezed_annotation: ^2.4.0

  # UI
  flex_color_scheme: ^8.1.0
  dynamic_color: ^1.8.1
  go_router: ^14.6.0
  flutter_slidable: ^3.1.0
  skeletonizer: ^2.1.2        # 加载骨架屏
  shimmer: ^3.0.0
  animations: ^2.0.0

  # 工具
  path_provider: ^2.1.5
  path: any
  share_plus: ^10.1.0
  url_launcher: ^6.3.0        # 优惠链接跳转浏览器
  logger: ^2.6.2              # 调试日志
  uuid: ^4.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  drift_dev: ^2.23.0
  riverpod_generator: ^2.6.1
  build_runner: ^2.4.0
  json_serializable: ^6.8.0
  freezed: ^2.5.0
```

---

## 五、参考项目：Kazumi

以下包经评估后从 [Kazumi](https://github.com/Predidit/Kazumi) 项目中选用，版本对齐 Kazumi 2.1.4：

| 包 | Kazumi 版本 | 折多多用途 |
|---|------------|-----------|
| `dio` | ^5.0.0 | WebDAV/COS/OSS HTTP 通信 |
| `connectivity_plus` | ^6.0.5 | 网络状态检测，触发同步 |
| `path_provider` | ^2.1.5 | 本地文件路径 |
| `cached_network_image` | ^3.4.1 | 远程图片缓存 |
| `dynamic_color` | ^1.8.1 | Material You 壁纸取色 |
| `image_picker` | ^1.2.1 | 本地图片选择 |
| `crypto` | ^3.0.6 | payload_hash 签名校验 |
| `synchronized` | any | 同步并发控制 |
| `logger` | ^2.6.2 | 调试日志 |
| `url_launcher` | ^6.3.0 | 优惠链接跳转 |
| `skeletonizer` | ^2.1.2 | 加载骨架屏 |

Kazumi 中不适用的包（视频/音频/桌面/弹幕专属）：`media_kit`、`audio_service`、`canvas_danmaku`、`dlna_dart`、`tray_manager`、`window_manager`、`flutter_inappwebview`、`screen_brightness_*`、`flutter_volume_controller`、`webview_windows`、`desktop_webview_window` 等。

Kazumi 中需替换的包：

| Kazumi 用 | 折多多替换为 | 原因 |
|-----------|------------|------|
| `provider` | `flutter_riverpod` | Riverpod 更现代，编译期安全 |
| `hive_ce` / `hive_ce_flutter` | `drift` | KV 存储不适合关系型数据 |
| `flutter_modular` | `go_router` | 与 Riverpod 路由方案冲突 |
| `mobx` / `flutter_mobx` | `riverpod` | 状态管理二选一 |

---

## 六、不推荐的方案（同 Kazumi 分析）

| 方案 | 原因 |
|------|------|
| **Isar** | 原作者 2024 年退出，社区 fork 维护不确定，新项目不建议采用 |
| **Hive** | KV 存储，不适合优惠/券/标签等关系型数据 |
| **GetX** | 魔法过多，可测试性差，社区衰退 |
| **BLoC** | 样板代码多，此项目复杂度用不上 |
| **Provider** | 已被同一作者的 Riverpod 取代，属 legacy |
| **重型 UI Kit** | 预制购物 UI 套件臃肿难定制，Material 3 + flex_color_scheme 足够 |

---

## 七、与现有文档的映射

| 现有设计 | Flutter 实现 |
|---------|-------------|
| `doc/数据库表设计.md` DDL | drift 表定义 + 代码生成 |
| `DealRepository` 接口 | Riverpod Provider + drift DAO |
| `sync_changelog` 表 | drift 表 + `changelog_manager.dart` |
| `sync_meta` 表 | drift 表 + `sync_engine.dart` |
| WebDAV push/pull 流程 | `webdav_transport.dart` 或 `dio` 封装 |
| COS/OSS 传输 | `cos_transport.dart` / `oss_transport.dart`（dio + S3 API） |
| 回收站机制（`deleted` 三态） | drift 表 `deleted` 字段 + 同步冲突处理 |
| 全量上传/下载 | `sync_engine.dart` 中 `fullPush()` / `fullDownload()` |
| 图片压缩（≤800px, JPEG 0.7） | `flutter_image_compress_common` |
| YAML 导入 | `yaml` 包 + `yaml_parser.dart` |
| `PRAGMA user_version` 迁移 | drift `MigrationStrategy` + `schemaVersion()` |
| 暗色/亮色主题 | `flex_color_scheme` + `ThemeMode` 切换 |

---

## 八、相关文档

- [数据持久化方案](./数据持久化方案.md) — 选型结论与同步策略
- [数据库表设计](./数据库表设计.md) — 完整 DDL、ER、CRUD、同步协议
- [同步策略评估](./同步策略评估.md) — 同步设计评估与修订记录
