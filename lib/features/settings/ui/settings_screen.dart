// 系统设置页面
//
// 提供应用级别的偏好设置，包括：
// - 外观设置（主题切换：跟随系统/亮色/暗色）
// - 清单展示模式（正常/简洁）
// - 默认排序方式
// - 货币符号
// - 筛选时间范围

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _defaultSort = 'date-desc';
  String _currency = '¥';
  String _listDisplayMode = 'normal';
  String _filterTimeRange = '3m';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsDao = ref.read(settingsDaoProvider);
    final sort = await settingsDao.getValue('defaultSort');
    final curr = await settingsDao.getValue('currency');
    final display = await settingsDao.getValue('listDisplayMode');
    final timeRange = await settingsDao.getValue('filterTimeRange');

    setState(() {
      _defaultSort = sort ?? 'date-desc';
      _currency = curr ?? '¥';
      _listDisplayMode = display ?? 'normal';
      _filterTimeRange = timeRange ?? '3m';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('系统设置')),
      body: ListView(
        children: [
          // Theme section
          _buildSectionHeader(context, '外观'),
          _buildThemeTile(context, themeMode),
          _buildListTile(
            context,
            icon: Icons.view_list_outlined,
            title: '清单展示模式',
            subtitle: _listDisplayMode == 'simple' ? '简洁模式' : '正常模式',
            onTap: () => _showDisplayModePicker(context),
          ),

          const Divider(height: 24),

          // Defaults section
          _buildSectionHeader(context, '默认值'),
          _buildListTile(
            context,
            icon: Icons.sort,
            title: '默认排序',
            subtitle: _getSortLabel(_defaultSort),
            onTap: () => _showSortPicker(context),
          ),
          _buildListTile(
            context,
            icon: Icons.attach_money,
            title: '货币符号',
            subtitle: _currency,
            onTap: () => _showCurrencyPicker(context),
          ),
          _buildListTile(
            context,
            icon: Icons.date_range,
            title: '筛选时间范围',
            subtitle: _getTimeRangeLabel(_filterTimeRange),
            onTap: () => _showTimeRangePicker(context),
          ),

          const Divider(height: 24),

          // About
          _buildSectionHeader(context, '关于'),
          _buildListTile(
            context,
            icon: Icons.info_outline,
            title: '关于折多多',
            subtitle: '版本说明 / 检查更新',
            onTap: () => context.push('/profile/about'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeMode mode) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('主题'),
      subtitle: Text(
        mode == ThemeMode.system
            ? '跟随系统'
            : mode == ThemeMode.light
                ? '亮色模式'
                : '暗色模式',
      ),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.settings_brightness, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode, size: 18),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (modes) {
          ref.read(themeModeProvider.notifier).setThemeMode(modes.first);
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'date-asc':
        return '创建时间 (旧→新)';
      case 'date-desc':
        return '创建时间 (新→旧)';
      case 'price-asc':
        return '价格 (低→高)';
      case 'price-desc':
        return '价格 (高→低)';
      case 'title-asc':
        return '标题 A-Z';
      default:
        return sort;
    }
  }

  String _getTimeRangeLabel(String range) {
    switch (range) {
      case '1m':
        return '最近一个月';
      case '3m':
        return '最近三个月';
      case '6m':
        return '最近半年';
      case '1y':
        return '最近一年';
      case 'all':
        return '全部';
      default:
        return range;
    }
  }

  void _showDisplayModePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('展示模式',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ListTile(
              title: const Text('正常模式'),
              subtitle: const Text('平台、标签、折扣、日期、操作按钮'),
              trailing: _listDisplayMode == 'normal'
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                _saveSetting('listDisplayMode', 'normal');
                setState(() => _listDisplayMode = 'normal');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('简洁模式'),
              subtitle: const Text('标题 + 原价 + 优惠金额 + 实付'),
              trailing: _listDisplayMode == 'simple'
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                _saveSetting('listDisplayMode', 'simple');
                setState(() => _listDisplayMode = 'simple');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('默认排序',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...['date-desc', 'date-asc', 'price-asc', 'price-desc', 'title-asc']
                .map((sort) => ListTile(
                      title: Text(_getSortLabel(sort)),
                      trailing: _defaultSort == sort
                          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                          : null,
                      onTap: () {
                        _saveSetting('defaultSort', sort);
                        setState(() => _defaultSort = sort);
                        Navigator.pop(ctx);
                      },
                    )),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('货币符号',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...['¥', '\$', '€', '£'].map((curr) => ListTile(
                  title: Text(curr),
                  trailing: _currency == curr
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    _saveSetting('currency', curr);
                    setState(() => _currency = curr);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showTimeRangePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('筛选时间范围',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...['1m', '3m', '6m', '1y', 'all'].map((range) => ListTile(
                  title: Text(_getTimeRangeLabel(range)),
                  trailing: _filterTimeRange == range
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    _saveSetting('filterTimeRange', range);
                    setState(() => _filterTimeRange = range);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSetting(String key, String value) async {
    final settingsDao = ref.read(settingsDaoProvider);
    await settingsDao.setValue(key, value);
  }
}
