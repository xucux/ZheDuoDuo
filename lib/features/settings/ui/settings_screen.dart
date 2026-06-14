// 系统设置页面
//
// 提供应用级别的偏好设置，包括：
// - 外观设置（主题切换：跟随系统/亮色/暗色）
// - 清单展示模式（正常/简洁）
// - 默认排序方式
// - 货币符号
// - 筛选时间范围
// - 图片压缩配置（按文件大小分档设置压缩质量）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/image_compress.dart';
import '../../../features/local_server/services/local_server_service.dart';
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
  List<ImageCompressSetting> _compressSettings = [];

  // 本地服务设置
  bool _localServerEnabled = false;
  int _localServerPort = 28256;
  String _localServerToken = 'zheduoduo';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsDao = ref.read(settingsDaoProvider);
    final compressDao = ref.read(imageCompressSettingsDaoProvider);
    final sort = await settingsDao.getValue('defaultSort');
    final curr = await settingsDao.getValue('currency');
    final display = await settingsDao.getValue('listDisplayMode');
    final timeRange = await settingsDao.getValue('filterTimeRange');
    final compressList = await compressDao.getAllSettings();
    final localEnabled = await settingsDao.getValue('local_server_enabled');
    final localPort = await settingsDao.getValue('local_server_port');
    final localToken = await settingsDao.getValue('local_server_token');

    setState(() {
      _defaultSort = sort ?? 'date-desc';
      _currency = curr ?? '¥';
      _listDisplayMode = display ?? 'normal';
      _filterTimeRange = timeRange ?? '3m';
      _compressSettings = compressList;
      _localServerEnabled = localEnabled == 'true';
      _localServerPort = int.tryParse(localPort ?? '') ?? 28256;
      _localServerToken = localToken ?? 'zheduoduo';
    });

    // 应用 token 到本地服务
    LocalServerService.instance.token = _localServerToken;

    // 如果设置中启用了本地服务且当前未运行，则自动启动
    if (_localServerEnabled && !LocalServerService.instance.isRunning) {
      try {
        await LocalServerService.instance.start(port: _localServerPort);
      } catch (_) {
        // 启动失败不阻塞设置加载
      }
    }
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

          // Image compression section
          _buildSectionHeader(context, '图片压缩'),
          _buildListTile(
            context,
            icon: Icons.compress_outlined,
            title: '压缩配置',
            subtitle: _getCompressSummary(),
            onTap: () => _showCompressSettings(context),
          ),

          const Divider(height: 24),

          // 本地服务
          _buildSectionHeader(context, '本地服务'),
          _buildLocalServerTile(context),

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

  /// 生成压缩配置摘要文本
  String _getCompressSummary() {
    if (_compressSettings.isEmpty) return '未配置';
    return _compressSettings.map((s) => '${s.label}: ${s.quality}%').join(' / ');
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
      visualDensity: VisualDensity.compact,
      minLeadingWidth: 40,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
      visualDensity: VisualDensity.compact,
      minLeadingWidth: 40,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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

  /// 显示图片压缩配置面板
  void _showCompressSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CompressSettingsSheet(
        settings: _compressSettings,
        onSave: () async {
          await _loadSettings();
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
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

  /// 本地服务开关 + 端口设置
  Widget _buildLocalServerTile(BuildContext context) {
    final theme = Theme.of(context);
    final localServer = LocalServerService.instance;
    final isRunning = localServer.isRunning && _localServerEnabled;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(
              Icons.dns_outlined,
              color: isRunning ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            title: const Text('启用本地服务'),
            subtitle: Text(
              isRunning
                  ? '运行中：${localServer.address}'
                  : '已关闭',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            value: _localServerEnabled,
            onChanged: (value) => _toggleLocalServer(value),
          ),
          if (_localServerEnabled) ...[
            ListTile(
              leading: const Icon(Icons.settings_ethernet),
              title: const Text('服务端口'),
              subtitle: Text('$_localServerPort'),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: () => _showPortEditor(context),
              visualDensity: VisualDensity.compact,
              minLeadingWidth: 40,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('访问凭证'),
              subtitle: Text(_localServerToken.isEmpty ? '未设置' : '••••••'),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: () => _showTokenEditor(context),
              visualDensity: VisualDensity.compact,
              minLeadingWidth: 40,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ],
        ],
      ),
    );
  }

  /// 切换本地服务启动/停止
  Future<void> _toggleLocalServer(bool enabled) async {
    final settingsDao = ref.read(settingsDaoProvider);
    await settingsDao.setValue('local_server_enabled', enabled.toString());

    // 应用当前 token
    LocalServerService.instance.token = _localServerToken;

    if (enabled) {
      try {
        await LocalServerService.instance.start(port: _localServerPort);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('本地服务启动失败：$e')),
          );
        }
        await settingsDao.setValue('local_server_enabled', 'false');
        enabled = false;
      }
    } else {
      await LocalServerService.instance.stop();
    }

    setState(() => _localServerEnabled = enabled);
  }

  /// 显示端口编辑对话框
  void _showPortEditor(BuildContext context) {
    final controller = TextEditingController(text: '$_localServerPort');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设置端口'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '端口号',
            hintText: '28256',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final port = int.tryParse(controller.text);
              if (port == null || port < 1024 || port > 65535) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入 1024~65535 之间的端口号')),
                );
                return;
              }
              Navigator.pop(ctx);
              await _saveSetting('local_server_port', '$port');

              // 如果服务正在运行，需要重启以应用新端口
              if (_localServerEnabled && LocalServerService.instance.isRunning) {
                await LocalServerService.instance.stop();
                try {
                  await LocalServerService.instance.start(port: port);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('端口切换失败：$e')),
                    );
                  }
                }
              }

              setState(() => _localServerPort = port);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 显示凭证编辑对话框
  void _showTokenEditor(BuildContext context) {
    final controller = TextEditingController(text: _localServerToken);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设置访问凭证'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Token',
            hintText: 'zheduoduo',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final token = controller.text.trim();
              if (token.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Token 不能为空')),
                );
                return;
              }
              Navigator.pop(ctx);
              await _saveSetting('local_server_token', token);
              LocalServerService.instance.token = token;
              setState(() => _localServerToken = token);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

/// 图片压缩配置面板
///
/// 展示各文件大小档位的压缩质量和最大宽度配置，
/// 支持通过 Slider 调整质量，以及重置为默认值。
class _CompressSettingsSheet extends ConsumerStatefulWidget {
  final List<ImageCompressSetting> settings;
  final VoidCallback onSave;

  const _CompressSettingsSheet({
    required this.settings,
    required this.onSave,
  });

  @override
  ConsumerState<_CompressSettingsSheet> createState() =>
      _CompressSettingsSheetState();
}

class _CompressSettingsSheetState extends ConsumerState<_CompressSettingsSheet> {
  late List<ImageCompressSetting> _settings;

  @override
  void initState() {
    super.initState();
    _settings = List.from(widget.settings);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Text('图片压缩配置',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(
                onPressed: _resetToDefaults,
                child: const Text('恢复默认'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '按原始文件大小分档设置压缩质量，数值越低压缩率越高、文件越小',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),

          // 各档位配置
          ..._settings.map((setting) => _buildSettingItem(context, setting)),

          const SizedBox(height: 16),

          // 说明
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('说明', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '质量 100 = 无损压缩，质量 1 = 最高压缩率\n'
                  '最大宽度控制图片分辨率，超出会等比缩放\n'
                  '压缩格式统一为 JPEG',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, ImageCompressSetting setting) {
    final theme = Theme.of(context);
    final sizeLabel = ImageUtils.formatFileSize(setting.minSize);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 档位标题
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  setting.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '≥ $sizeLabel',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 压缩质量 Slider
          Row(
            children: [
              Text('质量', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
              Expanded(
                child: Slider(
                  value: setting.quality.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 9,
                  label: '${setting.quality}%',
                  onChanged: (value) {
                    setState(() {
                      final idx = _settings.indexWhere((s) => s.minSize == setting.minSize);
                      if (idx >= 0) {
                        _settings[idx] = ImageCompressSetting(
                          minSize: setting.minSize,
                          quality: value.toInt(),
                          label: setting.label,
                          maxWidth: setting.maxWidth,
                        );
                      }
                    });
                  },
                  onChangeEnd: (value) async {
                    final compressDao = ref.read(imageCompressSettingsDaoProvider);
                    await compressDao.updateQuality(setting.minSize, value.toInt());
                  },
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '${setting.quality}%',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),

          // 最大宽度 Slider
          Row(
            children: [
              Text('宽度', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
              Expanded(
                child: Slider(
                  value: setting.maxWidth.toDouble(),
                  min: 400,
                  max: 2400,
                  divisions: 10,
                  label: '${setting.maxWidth}px',
                  onChanged: (value) {
                    setState(() {
                      final idx = _settings.indexWhere((s) => s.minSize == setting.minSize);
                      if (idx >= 0) {
                        _settings[idx] = ImageCompressSetting(
                          minSize: setting.minSize,
                          quality: setting.quality,
                          label: setting.label,
                          maxWidth: value.toInt(),
                        );
                      }
                    });
                  },
                  onChangeEnd: (value) async {
                    final compressDao = ref.read(imageCompressSettingsDaoProvider);
                    await compressDao.updateMaxWidth(setting.minSize, value.toInt());
                  },
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '${setting.maxWidth}px',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 重置为默认压缩配置
  Future<void> _resetToDefaults() async {
    final compressDao = ref.read(imageCompressSettingsDaoProvider);
    await compressDao.resetToDefaults();
    final newSettings = await compressDao.getAllSettings();
    setState(() => _settings = newSettings);
    widget.onSave();
  }
}
