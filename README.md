# 折多多 (ZheDuoDuo)

商品折扣优惠记录工具。记录、管理、搜索商品优惠信息，支持本地备份与云同步。

## 技术栈

| 层级 | 技术 |
|------|------|
| 语言 | Dart 3.9 |
| 框架 | Flutter |
| 状态管理 | Riverpod 2 |
| 路由 | GoRouter (StatefulShellRoute) |
| 数据库 | Drift (SQLite ORM, schema v2) |
| 网络 | Dio |
| 主题 | Ant Design 5.0 / flex_color_scheme |

## 项目结构

```
lib/
├── main.dart                      # 入口，ProviderScope
├── app.dart                       # MaterialApp.router + 主题配置
│
├── core/                          # 核心基础设施
│   ├── database/
│   │   ├── app_database.dart      # Drift 数据库 (11 表)
│   │   ├── tables/                # 表定义 (deals, ai_configs, secrets…)
│   │   └── daos/                  # 数据访问对象 (CRUD)
│   ├── backup/
│   │   └── backup_service.dart    # 本地备份/恢复
│   ├── sync/
│   │   └── transports/            # 云同步传输层 (WebDAV/COS/OSS)
│   └── utils/
│       ├── image_compress.dart    # 图片压缩
│       └── yaml_parser.dart       # YAML 解析
│
├── features/                      # 业务模块 (按功能拆分)
│   ├── ai/                        # AI 对话
│   │   ├── models/                # (ChatMessage, ChatSession, AiProtocol…)
│   │   ├── services/              # (AIChatService, AiApiService)
│   │   └── ui/                    # (AiScreen, AiSettingsScreen)
│   ├── deals/                     # 商品清单 (主 Tab)
│   │   ├── providers/             # Riverpod 状态管理
│   │   └── ui/                    # 列表/详情/编辑页面
│   ├── search/                    # 搜索
│   ├── settings/                  # 系统设置
│   ├── cloud/                     # 云同步
│   └── backup/                    # 本地备份
│
├── shared/                        # 跨模块共享
│   ├── theme/                     # 主题、颜色、路由、全局 Provider
│   ├── models/                    # 共享数据模型
│   └── widgets/                   # (main_scaffold.dart 底部导航)
│
└── prototype/                     # HTML/CSS 原型 (Vue3, 供参考)
```

## 数据库表

| 表 | 说明 |
|----|------|
| `deals` | 商品优惠记录 |
| `deal_tags` | 标签多对多 |
| `deal_promotions` | 促销信息 |
| `coupons` | 优惠券 |
| `deal_images` | 商品图片 |
| `app_settings` | 应用设置 KV |
| `sync_meta` | 同步元数据 |
| `sync_changelog` | 同步变更日志 |
| `backup_records` | 备份记录 |
| `ai_configs` | AI 服务商配置 |
| `secrets` | 敏感凭证 (API Key 等) |

数据库文件位于 `{文档目录}/zheduoduo_data/zheduoduo.db`。

## 路由

| 路径 | 页面 | 导航 |
|------|------|------|
| `/` | 商品清单 | 底部 Tab |
| `/ai` | AI 对话 | 底部 Tab |
| `/profile` | 我的 | 底部 Tab |
| `/profile/settings` | 系统设置 | 全屏 |
| `/profile/cloud` | 云同步 | 全屏 |
| `/profile/backup` | 本地备份 | 全屏 |
| `/profile/ai-settings` | AI 设置 | 全屏 |
| `/profile/about` | 关于 | 全屏 |
| `/search` | 搜索 | 全屏 |
| `/deal/new` | 添加优惠 | 全屏 |
| `/deal/:id` | 优惠详情 | 全屏 |
| `/deal/:id/edit` | 编辑优惠 | 全屏 |

## 快速开始

```bash
# 1. 安装依赖
flutter pub get

# 2. 生成代码 (Drift + Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 3. 启动开发
flutter run

# 4. 构建 APK
flutter build apk --release

# 5. 构建 iOS
flutter build ios --release
```

```
flutter clean && dart run build_runner build --delete-conflicting-outputs && flutter run

flutter clean
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## 开发命令

```bash
flutter analyze          # 静态分析
dart run build_runner build   # 代码生成
dart run build_runner watch  # 监听模式代码生成
```

## AI 对话功能

支持三种协议：

- **OpenAI Chat** (`/v1/chat/completions`)
- **OpenAI Responses** (`/v1/responses`)
- **Anthropic** (`/v1/messages`)

内置服务商：DeepSeek、硅基流动、OpenAI、Claude、小米 MIMO、自定义。
Agent 角色：默认助手、购物参谋、YAML 解析器。

## 云同步

支持 WebDAV、腾讯云 COS、阿里云 OSS。使用增量同步 + 变更日志策略。
