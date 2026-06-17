import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restart_app/restart_app.dart';
import '../../../core/utils/logger_util.dart';
import '../../../core/sync/transports/sync_transport.dart';
import '../../../core/sync/transports/webdav_transport.dart';
import '../../../core/sync/transports/cos_transport.dart';
import '../../../core/sync/transports/oss_transport.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/theme/theme_provider.dart';
import '../providers/cloud_sync_provider.dart';

class CloudSyncScreen extends ConsumerStatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  ConsumerState<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends ConsumerState<CloudSyncScreen> {
  String _syncProvider = 'webdav';
  bool _autoSync = false;
  bool _enabled = false;
  bool _syncing = false;
  String _lastSyncAt = '从未同步';
  bool _webdavPasswordVisible = false;
  bool _cosSecretKeyVisible = false;
  bool _ossAccessKeySecretVisible = false;

  // WebDAV
  final _webdavUrlController = TextEditingController();
  final _webdavUsernameController = TextEditingController();
  final _webdavPasswordController = TextEditingController();
  final _dirPrefixController = TextEditingController(text: 'zheduoduo');
  String _webdavPreset = 'custom';

  // COS
  final _cosSecretIdController = TextEditingController();
  final _cosSecretKeyController = TextEditingController();
  final _cosBucketController = TextEditingController();
  final _cosRegionController = TextEditingController(text: 'ap-guangzhou');
  final _cosAppIdController = TextEditingController();

  // OSS
  final _ossAccessKeyIdController = TextEditingController();
  final _ossAccessKeySecretController = TextEditingController();
  final _ossBucketController = TextEditingController();
  final _ossRegionController = TextEditingController(text: 'cn-hangzhou');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _webdavUrlController.dispose();
    _webdavUsernameController.dispose();
    _webdavPasswordController.dispose();
    _dirPrefixController.dispose();
    _cosSecretIdController.dispose();
    _cosSecretKeyController.dispose();
    _cosBucketController.dispose();
    _cosRegionController.dispose();
    _cosAppIdController.dispose();
    _ossAccessKeyIdController.dispose();
    _ossAccessKeySecretController.dispose();
    _ossBucketController.dispose();
    _ossRegionController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settingsDao = ref.read(settingsDaoProvider);
    final secretsDao = ref.read(secretsDaoProvider);

    final lastSync = await settingsDao.getValue('cloud.lastSyncAt');
    if (lastSync != null) setState(() => _lastSyncAt = lastSync);

    final provider = await settingsDao.getValue('cloud.provider');
    if (provider != null) setState(() => _syncProvider = provider);

    final autoSync = await settingsDao.getValue('cloud.autoSync');
    if (autoSync != null) setState(() => _autoSync = autoSync == 'true');

    final enabled = await settingsDao.getValue('cloud.enabled');
    if (enabled != null) setState(() => _enabled = enabled == 'true');

    // WebDAV
    _webdavUrlController.text = await secretsDao.getValue('webdav', 'url') ?? '';
    _webdavUsernameController.text = await secretsDao.getValue('webdav', 'username') ?? '';
    _webdavPasswordController.text = await secretsDao.getValue('webdav', 'password') ?? '';
    _dirPrefixController.text = await settingsDao.getValue('cloud.dirPrefix') ?? 'zheduoduo';

    // COS
    _cosSecretIdController.text = await secretsDao.getValue('cos', 'secretId') ?? '';
    _cosSecretKeyController.text = await secretsDao.getValue('cos', 'secretKey') ?? '';
    _cosBucketController.text = await secretsDao.getValue('cos', 'bucket') ?? '';
    _cosRegionController.text = await secretsDao.getValue('cos', 'region') ?? 'ap-guangzhou';
    _cosAppIdController.text = await secretsDao.getValue('cos', 'appId') ?? '';

    // OSS
    _ossAccessKeyIdController.text = await secretsDao.getValue('oss', 'accessKeyId') ?? '';
    _ossAccessKeySecretController.text = await secretsDao.getValue('oss', 'accessKeySecret') ?? '';
    _ossBucketController.text = await secretsDao.getValue('oss', 'bucket') ?? '';
    _ossRegionController.text = await secretsDao.getValue('oss', 'region') ?? 'cn-hangzhou';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('云同步')),
      body: Stack(
        children: [
          ListView(
            children: [
              _buildStatusCard(theme),
              _buildProviderSection(theme),
              _buildDirPrefixField(),
              if (_syncProvider == 'webdav') _buildWebDavSection(theme),
              if (_syncProvider == 'cos') _buildCosSection(theme),
              if (_syncProvider == 'oss') _buildOssSection(theme),
              const Divider(height: 32),
              _buildAutoSyncSection(),
              const SizedBox(height: 32),
            ],
          ),
          if (_syncing) _buildLoadingOverlay(theme),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _enabled ? Icons.cloud_done : Icons.cloud_off,
              size: 48,
              color: _enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              _enabled ? '云同步已启用' : '云同步未启用',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _enabled ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text('上次同步: $_lastSyncAt',
                style: TextStyle(fontSize: 13, color: theme.colorScheme.outline)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: _enabled && !_syncing ? _manualSync : null,
                  child: const Text('立即同步'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _enabled && !_syncing ? _showFullSyncDialog : null,
                  child: const Text('全量操作'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(ThemeData theme) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('同步中...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
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

  Widget _buildProviderSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '同步方式'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildProviderTile('webdav', Icons.folder_outlined, 'WebDAV', '坚果云 / Nextcloud / 群晖 / 自定义'),
              _buildProviderTile('cos', Icons.cloud_outlined, '腾讯云 COS', '对象存储服务'),
              _buildProviderTile('oss', Icons.cloud_outlined, '阿里云 OSS', '对象存储服务'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderTile(String value, IconData icon, String title, String subtitle) {
    return RadioListTile<String>(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      groupValue: _syncProvider,
      onChanged: (v) {
        setState(() => _syncProvider = v!);
        _saveSetting('cloud.provider', v!);
      },
    );
  }

  Widget _buildDirPrefixField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '远端目录前缀'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '所有云存储的文件将存放在此前缀目录下',
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(_dirPrefixController, '目录前缀', 'zheduoduo'),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildWebDavSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'WebDAV 配置'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            value: _webdavPreset,
            decoration: const InputDecoration(labelText: '预设服务', border: OutlineInputBorder()),
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
                _applyWebdavPreset(v);
              });
              _saveCredentials();
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(_webdavUrlController, 'WebDAV 地址', 'https://dav.example.com/'),
        const SizedBox(height: 12),
        _buildTextField(_webdavUsernameController, '用户名'),
        const SizedBox(height: 12),
        _buildTextField(_webdavPasswordController, '密码', null, true, _webdavPasswordVisible, () => setState(() => _webdavPasswordVisible = !_webdavPasswordVisible)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: !_syncing ? _testConnection : null,
            icon: const Icon(Icons.wifi_find),
            label: const Text('测试连接'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCosSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '腾讯云 COS 配置'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('需要腾讯云 COS 的 API 密钥（SecretId / SecretKey）和存储桶信息。',
              style: TextStyle(fontSize: 13, color: theme.colorScheme.outline)),
        ),
        const SizedBox(height: 12),
        _buildTextField(_cosSecretIdController, 'SecretId'),
        const SizedBox(height: 12),
        _buildTextField(_cosSecretKeyController, 'SecretKey', null, true, _cosSecretKeyVisible, () => setState(() => _cosSecretKeyVisible = !_cosSecretKeyVisible)),
        const SizedBox(height: 12),
        _buildTextField(_cosBucketController, '存储桶名称'),
        const SizedBox(height: 12),
        _buildTextField(_cosRegionController, '区域', 'ap-guangzhou'),
        const SizedBox(height: 12),
        _buildTextField(_cosAppIdController, 'APPID（可选）'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: !_syncing ? _testConnection : null,
            icon: const Icon(Icons.wifi_find),
            label: const Text('测试连接'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOssSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '阿里云 OSS 配置'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('需要阿里云 OSS 的 AccessKey 和存储桶信息。Region 填写地域 ID（如 cn-hangzhou），也支持 oss-cn-hangzhou 格式。',
              style: TextStyle(fontSize: 13, color: theme.colorScheme.outline)),
        ),
        const SizedBox(height: 12),
        _buildTextField(_ossAccessKeyIdController, 'AccessKey ID'),
        const SizedBox(height: 12),
        _buildTextField(_ossAccessKeySecretController, 'AccessKey Secret', null, true, _ossAccessKeySecretVisible, () => setState(() => _ossAccessKeySecretVisible = !_ossAccessKeySecretVisible)),
        const SizedBox(height: 12),
        _buildTextField(_ossBucketController, 'Bucket 名称'),
        const SizedBox(height: 12),
        _buildTextField(_ossRegionController, 'Region', 'cn-hangzhou'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: !_syncing ? _testConnection : null,
            icon: const Icon(Icons.wifi_find),
            label: const Text('测试连接'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [String? hint, bool obscureText = false, bool showPassword = false, VoidCallback? onTogglePassword]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText && !showPassword,
        enableInteractiveSelection: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIcon: obscureText
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.content_paste, size: 20),
                    tooltip: '粘贴',
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        final text = controller.text;
                        final sel = controller.selection;
                        final newText = text.replaceRange(
                          sel.isValid ? sel.start : text.length,
                          sel.isValid ? sel.end : text.length,
                          data!.text!,
                        );
                        controller.text = newText;
                        controller.selection = TextSelection.collapsed(
                          offset: sel.isValid ? sel.start + data.text!.length : newText.length,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off, size: 20),
                    tooltip: showPassword ? '隐藏' : '显示',
                    onPressed: onTogglePassword,
                  ),
                ])
              : null,
        ),
      ),
    );
  }

  Widget _buildAutoSyncSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '自动同步'),
        SwitchListTile(
          secondary: const Icon(Icons.sync),
          title: const Text('自动同步'),
          subtitle: const Text('保存后自动推送，打开时自动拉取'),
          value: _autoSync,
          onChanged: (v) {
            setState(() => _autoSync = v);
            _saveSetting('cloud.autoSync', v.toString());
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.cloud_outlined),
          title: const Text('启用云同步'),
          subtitle: const Text('开启后连接到云服务'),
          value: _enabled,
          onChanged: (v) {
            setState(() => _enabled = v);
            _saveSetting('cloud.enabled', v.toString());
          },
        ),
      ],
    );
  }

  void _applyWebdavPreset(String preset) {
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

  SyncTransport? _createTransport() {
    switch (_syncProvider) {
      case 'webdav':
        final url = _webdavUrlController.text.trim();
        final username = _webdavUsernameController.text.trim();
        final password = _webdavPasswordController.text.trim();
        if (url.isEmpty || username.isEmpty || password.isEmpty) {
          _showSnackBar('请填写完整的 WebDAV 配置');
          return null;
        }
        return WebDavTransport(baseUrl: url, username: username, password: password);

      case 'cos':
        final secretId = _cosSecretIdController.text.trim();
        final secretKey = _cosSecretKeyController.text.trim();
        final bucket = _cosBucketController.text.trim();
        final region = _cosRegionController.text.trim();
        if (secretId.isEmpty || secretKey.isEmpty || bucket.isEmpty || region.isEmpty) {
          _showSnackBar('请填写完整的 COS 配置');
          return null;
        }
        return CosTransport(
          bucket: bucket,
          region: region,
          secretId: secretId,
          secretKey: secretKey,
          appId: _cosAppIdController.text.trim(),
        );

      case 'oss':
        final accessKeyId = _ossAccessKeyIdController.text.trim();
        final accessKeySecret = _ossAccessKeySecretController.text.trim();
        final bucket = _ossBucketController.text.trim();
        final region = _ossRegionController.text.trim();
        if (accessKeyId.isEmpty || accessKeySecret.isEmpty || bucket.isEmpty || region.isEmpty) {
          _showSnackBar('请填写完整的 OSS 配置');
          return null;
        }
        return OssTransport(
          bucket: bucket,
          region: region,
          accessKeyId: accessKeyId,
          accessKeySecret: accessKeySecret,
        );

      default:
        _showSnackBar('不支持的同步方式');
        return null;
    }
  }

  Future<void> _manualSync() async {
    final transport = _createTransport();
    if (transport == null) return;

    _saveCredentials();
    setState(() => _syncing = true);

    try {
      final syncService = ref.read(syncServiceProvider);
      final result = await syncService.smartSync(transport, dirPrefix: _dirPrefixController.text.trim());
      setState(() {
        _syncing = false;
        _lastSyncAt = DateTime.now().toIso8601String();
      });
      _saveSetting('cloud.lastSyncAt', _lastSyncAt);
      _showResultDialog(result);
    } catch (e) {
      setState(() => _syncing = false);
      _showSnackBar('同步出错: $e');
    }
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
              _showRemoteBackupsDialog();
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _showRemoteBackupsDialog() async {
    final transport = _createTransport();
    if (transport == null) return;

    _saveCredentials();

    List<RemoteFileInfo> files = [];
    String? error;
    try {
      final syncService = ref.read(syncServiceProvider);
      files = await syncService.listFullBackups(transport, dirPrefix: _dirPrefixController.text.trim());
    } catch (e) {
      error = e.toString();
    }

    if (!context.mounted) return;

    if (files.isEmpty) {
      _showSnackBar(error ?? '远端无全量备份');
      return;
    }

    String selected = files.first.name;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setStateLocal) {
          return AlertDialog(
            title: const Text('选择要下载的备份'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  final isSelected = selected == file.name;
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    ),
                    title: Text(file.name),
                    subtitle: Text('${_formatFileSize(file.size)} · ${file.modifiedAt.toLocal()}'),
                    onTap: () => setStateLocal(() => selected = file.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: '删除',
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx3) => AlertDialog(
                            title: const Text('确认删除'),
                            content: Text('确定要删除远程备份 ${file.name} 吗？此操作不可恢复。'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx3, false), child: const Text('取消')),
                              TextButton(onPressed: () => Navigator.pop(ctx3, true), child: const Text('删除')),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                        if (!context.mounted) return;

                        try {
                          final syncService = ref.read(syncServiceProvider);
                          final result = await syncService.deleteFullBackup(
                            transport,
                            file.name,
                            dirPrefix: _dirPrefixController.text.trim(),
                          );
                          if (result.success) {
                            setStateLocal(() {
                              files.removeAt(index);
                              if (selected == file.name && files.isNotEmpty) {
                                selected = files.first.name;
                              }
                            });
                          }
                          if (context.mounted) {
                            _showSnackBar(result.message ?? (result.success ? '删除成功' : '删除失败'), isError: !result.success);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            _showSnackBar('删除失败: $e');
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('取消')),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx2);
                  _fullDownload(filename: selected);
                },
                child: const Text('下载选中'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _fullPush() async {
    final transport = _createTransport();
    if (transport == null) return;

    _saveCredentials();
    setState(() => _syncing = true);

    try {
      final syncService = ref.read(syncServiceProvider);
      final result = await syncService.fullUpload(transport, dirPrefix: _dirPrefixController.text.trim());
      setState(() {
        _syncing = false;
        _lastSyncAt = DateTime.now().toIso8601String();
      });
      _saveSetting('cloud.lastSyncAt', _lastSyncAt);
      _showResultDialog(result);
    } catch (e) {
      setState(() => _syncing = false);
      _showSnackBar('上传失败: $e');
    }
  }

  Future<void> _fullDownload({String? filename}) async {
    final transport = _createTransport();
    if (transport == null) return;

    _saveCredentials();
    setState(() => _syncing = true);

    try {
      final syncService = ref.read(syncServiceProvider);
      var result = await syncService.fullDownload(
        transport,
        dirPrefix: _dirPrefixController.text.trim(),
        filename: filename,
      );

      // 本地存在未同步变更，询问用户
      if (!result.success && result.message != null && result.message!.contains('本地存在未同步的变更') && mounted) {
        setState(() => _syncing = false);
        final choice = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('本地存在未同步变更'),
            content: const Text('全量下载会覆盖本地数据。您希望先推送本地变更，还是强制覆盖？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'cancel'),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'push'),
                child: const Text('先推送'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, 'force'),
                child: const Text('强制覆盖'),
              ),
            ],
          ),
        );

        if (choice == 'push') {
          setState(() => _syncing = true);
          final pushResult = await syncService.incrementalPush(transport, dirPrefix: _dirPrefixController.text.trim());
          if (!pushResult.success) {
            setState(() => _syncing = false);
            _showResultDialog(pushResult);
            return;
          }
          // 推送成功后重新下载
          result = await syncService.fullDownload(
            transport,
            dirPrefix: _dirPrefixController.text.trim(),
            filename: filename,
          );
        } else if (choice == 'force') {
          setState(() => _syncing = true);
          result = await syncService.fullDownload(
            transport,
            dirPrefix: _dirPrefixController.text.trim(),
            filename: filename,
            force: true,
          );
        } else {
          return;
        }
      }

      setState(() {
        _syncing = false;
        _lastSyncAt = DateTime.now().toIso8601String();
      });
      _saveSetting('cloud.lastSyncAt', _lastSyncAt);

      if (result.success && mounted) {
        _showRestartDialog('全量下载成功，共 ${result.dealCount ?? '?'} 条记录');
      } else {
        _showResultDialog(result);
      }
    } catch (e) {
      setState(() => _syncing = false);
      _showSnackBar('下载失败: $e');
    }
  }

  Future<void> _testConnection() async {
    final transport = _createTransport();
    if (transport == null) return;

    _saveCredentials();
    setState(() => _syncing = true);

    final providerLabel = switch (_syncProvider) {
      'webdav' => 'WebDAV',
      'cos' => 'COS',
      'oss' => 'OSS',
      _ => _syncProvider,
    };

    try {
      AppLogger.instance.i('[$providerLabel] 开始测试连接...');
      final ok = await transport.testConnection();
      setState(() => _syncing = false);
      if (ok) {
        AppLogger.instance.i('[$providerLabel] 连接成功');
        _showSnackBar('连接成功', isError: false);
      } else {
        AppLogger.instance.e('[$providerLabel] 连接失败');
        _showSnackBar('连接失败，请检查配置和网络');
      }
    } catch (e) {
      setState(() => _syncing = false);
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppLogger.instance.e('[$providerLabel] 测试连接异常: $msg');
      _showSnackBar(msg);
    }
  }

  void _showResultDialog(SyncResult result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(result.success ? '完成' : '失败'),
        content: Text(result.message ?? ''),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定')),
        ],
      ),
    );
  }

  void _showRestartDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('需要重启'),
        content: Text('$message\n\n数据库已替换，请重启应用以恢复数据连接。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('稍后再说'),
          ),
          FilledButton(
            onPressed: () => Restart.restartApp(),
            child: const Text('立即重启'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  void _saveCredentials() {
    final secretsDao = ref.read(secretsDaoProvider);
    final settingsDao = ref.read(settingsDaoProvider);
    settingsDao.setValue('cloud.dirPrefix', _dirPrefixController.text);
    secretsDao.setValue('webdav', 'url', _webdavUrlController.text);
    secretsDao.setValue('webdav', 'username', _webdavUsernameController.text);
    secretsDao.setValue('webdav', 'password', _webdavPasswordController.text);
    secretsDao.setValue('cos', 'secretId', _cosSecretIdController.text);
    secretsDao.setValue('cos', 'secretKey', _cosSecretKeyController.text);
    secretsDao.setValue('cos', 'bucket', _cosBucketController.text);
    secretsDao.setValue('cos', 'region', _cosRegionController.text);
    secretsDao.setValue('cos', 'appId', _cosAppIdController.text);
    secretsDao.setValue('oss', 'accessKeyId', _ossAccessKeyIdController.text);
    secretsDao.setValue('oss', 'accessKeySecret', _ossAccessKeySecretController.text);
    secretsDao.setValue('oss', 'bucket', _ossBucketController.text);
    secretsDao.setValue('oss', 'region', _ossRegionController.text);
  }

  Future<void> _saveSetting(String key, String value) async {
    final settingsDao = ref.read(settingsDaoProvider);
    await settingsDao.setValue(key, value);
  }
}
