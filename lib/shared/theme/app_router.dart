// 应用路由配置
//
// 使用 GoRouter 定义所有页面路由，包括：
// - 底部导航三 Tab（清单/AI/我的）
// - 优惠详情/编辑页面
// - 搜索页面
// - 系统设置/云同步/本地备份/AI 设置页面
// 使用 StatefulShellRoute 保持 Tab 页面状态。

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/ui/ai_screen.dart';
import '../../features/ai/ui/ai_settings_screen.dart';
import '../../features/deals/ui/deal_list_screen.dart';
import '../../features/deals/ui/deal_detail_screen.dart';
import '../../features/deals/ui/deal_form_screen.dart';
import '../../features/mcp/ui/mcp_management_screen.dart';
import '../../features/ocr/ui/ocr_test_screen.dart';
import '../../features/search/ui/search_screen.dart';
import '../../features/prompts/ui/prompts_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/settings/ui/about_screen.dart';
import '../../features/cloud/ui/cloud_sync_screen.dart';
import '../../features/backup/ui/backup_screen.dart';
import '../widgets/main_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 清单 Tab
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DealListScreen(),
              routes: [
                GoRoute(
                  path: 'search',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const SearchScreen(),
                ),
                GoRoute(
                  path: 'deal/new',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const DealFormScreen(),
                ),
                GoRoute(
                  path: 'deal/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return DealDetailScreen(dealId: id);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return DealFormScreen(dealId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // AI Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ai',
              builder: (context, state) => const AiScreen(),
            ),
          ],
        ),
        // 我的 Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const _ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'settings',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'cloud',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CloudSyncScreen(),
                ),
                GoRoute(
                  path: 'backup',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const BackupScreen(),
                ),
                GoRoute(
                  path: 'ai-settings',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const AiSettingsScreen(),
                ),
                GoRoute(
                  path: 'mcp-management',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const McpManagementScreen(),
                ),
                GoRoute(
                  path: 'prompts',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const PromptsScreen(),
                ),
                GoRoute(
                  path: 'ocr-test',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const OcrTestScreen(),
                ),
                GoRoute(
                  path: 'about',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const AboutScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// "我的"页面
///
/// 展示数据管理、AI 设置、系统设置、关于等入口。
class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSection(
            context,
            title: '工具',
            children: [
              _buildTile(
                context,
                icon: Icons.text_snippet_outlined,
                title: 'OCR 识别测试',
                subtitle: '测试图片文字识别功能 (Google ML Kit)',
                onTap: () => context.push('/profile/ocr-test'),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '数据管理',
            children: [
              _buildTile(
                context,
                icon: Icons.backup_outlined,
                title: '本地备份',
                subtitle: '导入 / 导出备份文件',
                onTap: () => context.push('/profile/backup'),
              ),
              _buildTile(
                context,
                icon: Icons.cloud_sync_outlined,
                title: '云同步',
                subtitle: 'WebDAV / COS / OSS',
                onTap: () => context.push('/profile/cloud'),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'AI 设置',
            children: [
              _buildTile(
                context,
                icon: Icons.smart_toy_outlined,
                title: 'AI 对话',
                subtitle: '服务商 / API Key / 协议 / Agent',
                onTap: () => context.push('/profile/ai-settings'),
              ),
              _buildTile(
                context,
                icon: Icons.text_snippet_outlined,
                title: '提示词',
                subtitle: '管理提示词模板',
                onTap: () => context.push('/profile/prompts'),
              ),
              _buildTile(
                context,
                icon: Icons.cable,
                title: 'MCP 管理',
                subtitle: '工具服务 / 各工具开关',
                onTap: () => context.push('/profile/mcp-management'),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '设置',
            children: [
              _buildTile(
                context,
                icon: Icons.settings_outlined,
                title: '系统设置',
                subtitle: '主题 / 排序 / 货币 / 偏好',
                onTap: () => context.push('/profile/settings'),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '关于',
            children: [
              _buildTile(
                context,
                icon: Icons.info_outline,
                title: '关于折多多',
                subtitle: '版本说明 / 检查更新',
                onTap: () => context.push('/profile/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      visualDensity: VisualDensity.compact,
      minLeadingWidth: 40,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
