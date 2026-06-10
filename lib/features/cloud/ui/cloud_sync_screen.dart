// 云同步页面
//
// 提供优惠数据的云同步配置和管理功能，包括：
// - 同步方式选择（WebDAV / 腾讯云 COS / 阿里云 OSS）
// - WebDAV 配置（预设服务/地址/用户名/密码/路径）
// - 自动同步开关
// - 手动同步/全量上传/全量下载
// WebDAV 密码等敏感信息明文保存至数据库 Secrets 表。
// 注意：同步功能尚未实现，当前为 UI 占位。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/theme_provider.dart';

class CloudSyncScreen extends ConsumerStatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  ConsumerState<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends ConsumerState<CloudSyncScreen> {
  String _syncProvider = 'webdav';
  bool _autoSync = false;
  bool _enabled = false;
  String _lastSyncAt = '从未同步';

  // WebDAV settings
  final _webdavUrlController = TextEditingController();
  final _webdavUsernameController = TextEditingController();
  final _webdavPasswordController = TextEditingController();
  final _webdavPathController = TextEditingController(text: '/zheduoduo/');
  String _webdavPreset = 'custom';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsDao = ref.read(settingsDaoProvider);
    final secretsDao = ref.read(secretsDaoProvider);

    // 从 AppSettings 加载非敏感配置
    final lastSync = await settingsDao.getValue('cloud.webdav.lastSyncAt');
    if (lastSync != null) {
      setState(() => _lastSyncAt = lastSync);
    }

    // 从 Secrets 表加载 WebDAV 敏感凭证
    final url = await secretsDao.getValue('webdav', 'url') ?? '';
    final username = await secretsDao.getValue('webdav', 'username') ?? '';
    final password = await secretsDao.getValue('webdav', 'password') ?? '';
    final path = await secretsDao.getValue('webdav', 'path') ?? '/zheduoduo/';

    setState(() {
      _webdavUrlController.text = url;
      _webdavUsernameController.text = username;
      _webdavPasswordController.text = password;
      _webdavPathController.text = path;
    });
  }

  @override
  void dispose() {
    _webdavUrlController.dispose();
    _webdavUsernameController.dispose();
    _webdavPasswordController.dispose();
    _webdavPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('云同步')),
      body: ListView(
        children: [
          // Sync status card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    _enabled ? Icons.cloud_done : Icons.cloud_off,
                    size: 48,
                    color: _enabled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _enabled ? '云同步已启用' : '云同步未启用',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _enabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '上次同步: $_lastSyncAt',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.tonal(
                        onPressed: _enabled ? _manualSync : null,
                        child: const Text('立即同步'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _showFullSyncDialog,
                        child: const Text('全量操作'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Provider selection
          _buildSectionHeader(context, '同步方式'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildProviderTile(
                  context,
                  icon: Icons.folder_outlined,
                  title: 'WebDAV',
                  subtitle: '坚果云 / Nextcloud / 群晖 / 自定义',
                  value: 'webdav',
                ),
                _buildProviderTile(
                  context,
                  icon: Icons.cloud_outlined,
                  title: '腾讯云 COS',
                  subtitle: '对象存储服务',
                  value: 'cos',
                ),
                _buildProviderTile(
                  context,
                  icon: Icons.cloud_outlined,
                  title: '阿里云 OSS',
                  subtitle: '对象存储服务',
                  value: 'oss',
                ),
              ],
            ),
          ),

          if (_syncProvider == 'webdav') _buildWebDavSettings(context),

          const Divider(height: 32),

          // Auto sync toggle
          _buildSectionHeader(context, '自动同步'),
          SwitchListTile(
            secondary: const Icon(Icons.sync),
            title: const Text('自动同步'),
            subtitle: const Text('保存后自动推送，打开时自动拉取'),
            value: _autoSync,
            onChanged: (v) {
              setState(() => _autoSync = v);
              _saveSetting('cloud.webdav.autoSync', v.toString());
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.cloud_outlined),
            title: const Text('启用云同步'),
            subtitle: const Text('开启后连接到云服务'),
            value: _enabled,
            onChanged: (v) {
              setState(() => _enabled = v);
              _saveSetting('cloud.webdav.enabled', v.toString());
            },
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

  Widget _buildProviderTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return RadioListTile<String>(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      groupValue: _syncProvider,
      onChanged: (v) {
        setState(() => _syncProvider = v!);
      },
    );
  }

  Widget _buildWebDavSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'WebDAV 配置'),

        // Preset selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            value: _webdavPreset,
            decoration: const InputDecoration(
              labelText: '预设服务',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'custom', child: Text('自定义')),
              DropdownMenuItem(value: 'jianguoyun', child: Text('坚果云')),
              DropdownMenuItem(value: 'nextcloud', child: Text('Nextcloud')),
              DropdownMenuItem(value: 'synology', child: Text('群晖')),
              DropdownMenuItem(value: 'infinicloud', child: Text('infiniCLOUD')),
            ],
            onChanged: (v) {
              setState(() {
                _webdavPreset = v!;
                _applyPreset(v);
              });
            },
          ),
        ),
        const SizedBox(height: 12),

        // URL
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            controller: _webdavUrlController,
            decoration: const InputDecoration(
              labelText: 'WebDAV 地址',
              hintText: 'https://dav.example.com/',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Username
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            controller: _webdavUsernameController,
            decoration: const InputDecoration(
              labelText: '用户名',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Password
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            controller: _webdavPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '密码',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Path
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            controller: _webdavPathController,
            decoration: const InputDecoration(
              labelText: '远端路径',
              hintText: '/zheduoduo/',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Test connection
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: _testConnection,
            icon: const Icon(Icons.wifi_find),
            label: const Text('测试连接'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _applyPreset(String preset) {
    switch (preset) {
      case 'jianguoyun':
        _webdavUrlController.text = 'https://dav.jianguoyun.com/dav/';
        break;
      case 'nextcloud':
        _webdavUrlController.text = 'https://your-server.com/remote.php/dav/files/username/';
        break;
      case 'synology':
        _webdavUrlController.text = 'https://your-nas.com:5006/webdav/';
        break;
      case 'infinicloud':
        _webdavUrlController.text = 'https://n114.infiniteloop.cloud/dav/';
        break;
      default:
        _webdavUrlController.clear();
    }
  }

  void _manualSync() {
    // TODO: Implement sync
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('同步功能即将上线')),
    );
  }

  void _showFullSyncDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('全量操作'),
        content: const Text('选择全量同步方向：'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _fullPush();
            },
            child: const Text('全量上传'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _fullDownload();
            },
            child: const Text('全量下载'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _fullPush() {
    // TODO: Implement full push
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('全量上传功能即将上线')),
    );
  }

  void _fullDownload() {
    // TODO: Implement full download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('全量下载功能即将上线')),
    );
  }

  void _testConnection() {
    // TODO: Implement connection test
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('连接测试功能即将上线')),
    );
  }

  /// 保存非敏感设置到 AppSettings 表
  Future<void> _saveSetting(String key, String value) async {
    final settingsDao = ref.read(settingsDaoProvider);
    await settingsDao.setValue(key, value);
  }

  /// 保存 WebDAV 凭证到 Secrets 表
  Future<void> _saveWebdavCredentials() async {
    final secretsDao = ref.read(secretsDaoProvider);
    await secretsDao.setValue('webdav', 'url', _webdavUrlController.text);
    await secretsDao.setValue('webdav', 'username', _webdavUsernameController.text);
    await secretsDao.setValue('webdav', 'password', _webdavPasswordController.text);
    await secretsDao.setValue('webdav', 'path', _webdavPathController.text);
  }
}
