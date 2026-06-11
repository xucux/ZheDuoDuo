import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';
  bool _checking = false;
  bool _historyLoading = false;
  List<Map<String, dynamic>>? _releaseList;
  String? _error;

  static const String _updateUrl =
      'https://raw.githubusercontent.com/xucux/ZheDuoDuo/main/changelog.json';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = info.version;
          _buildNumber = info.buildNumber;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _version = '1.0.0';
          _buildNumber = '1';
        });
      }
    }
  }

  Future<void> _fetchReleaseList({bool isHistory = false}) async {
    final setLoading = isHistory ? (bool v) => _historyLoading = v : (bool v) => _checking = v;
    setState(() {
      setLoading(true);
      _error = null;
    });

    try {
      final dio = Dio();
      final response = await dio.get(
        _updateUrl,
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode == 200) {
        final rawString = response.data is String
            ? response.data as String
            : jsonEncode(response.data);
        final decoded = jsonDecode(rawString);
        final List<Map<String, dynamic>> list;
        if (decoded is List) {
          list = decoded.cast<Map<String, dynamic>>();
        } else {
          list = [];
        }
        list.sort((a, b) =>
            ((b['buildNumber'] as int?) ?? 0).compareTo((a['buildNumber'] as int?) ?? 0));

        if (mounted) {
          setState(() {
            _releaseList = list;
            setLoading(false);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = '检查更新失败 (${response.statusCode})';
            setLoading(false);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '获取失败: ${e.toString()}';
          setLoading(false);
        });
      }
    }
  }

  Future<void> _checkUpdate() async {
    await _fetchReleaseList();
    if (_releaseList != null && _releaseList!.isNotEmpty) {
      _checkForUpdate(_releaseList!);
    }
  }

  void _checkForUpdate(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return;
    final latest = list.first;
    final latestVersion = latest['version'] as String? ?? '';
    final latestBuild = latest['buildNumber'] as int? ?? 0;
    final currentBuild = int.tryParse(_buildNumber) ?? 0;

    final hasUpdate = latestBuild > currentBuild ||
        _compareVersion(latestVersion, _version) > 0;

    if (!hasUpdate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已是最新版本')),
      );
      return;
    }

    _showUpdateDialog(latest);
  }

  void _showUpdateDialog(Map<String, dynamic> data) {
    final latestVersion = data['version'] as String? ?? '';
    final downloadUrl = data['downloadUrl'] as String? ?? '';
    final releaseNotes = data['releaseNotes'] as List<dynamic>? ?? [];
    final updateRequired = data['updateRequired'] as bool? ?? false;

    showDialog(
      context: context,
      barrierDismissible: !updateRequired,
      builder: (ctx) => AlertDialog(
        title: Text('发现新版本 v$latestVersion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (updateRequired)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '此版本为强制更新',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ),
            const Text('更新内容：'),
            const SizedBox(height: 8),
            ...releaseNotes.map((note) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(note.toString())),
                ],
              ),
            )),
          ],
        ),
        actions: [
          if (!updateRequired)
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('稍后再说'),
            ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _launchUrl(downloadUrl);
            },
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }

  void _showReleaseHistory() async {
    if (_releaseList == null) {
      await _fetchReleaseList(isHistory: true);
    }
    if (!mounted) return;
    if (_releaseList == null || _releaseList!.isEmpty) {
      if (_error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('暂时无法获取更新历史')),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('更新历史'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _releaseList!.map((release) => _buildReleaseEntry(ctx, release)).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildReleaseEntry(BuildContext context, Map<String, dynamic> release) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final version = release['version'] as String? ?? '';
    final date = release['releaseDate'] as String? ?? '';
    final notes = release['releaseNotes'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('v$version',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary)),
              ),
              const SizedBox(width: 8),
              Text(date,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
            ],
          ),
          if (notes.isNotEmpty) const SizedBox(height: 8),
          ...notes.map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                    Expanded(child: Text(note.toString())),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  int _compareVersion(String a, String b) {
    final aParts = a.split('.').map(int.tryParse).where((e) => e != null).cast<int>().toList();
    final bParts = b.split('.').map(int.tryParse).where((e) => e != null).cast<int>().toList();
    for (int i = 0; i < aParts.length || i < bParts.length; i++) {
      final aVal = i < aParts.length ? aParts[i] : 0;
      final bVal = i < bParts.length ? bParts[i] : 0;
      if (aVal != bVal) return aVal - bVal;
    }
    return 0;
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('关于折多多')),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '折多多',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _version.isNotEmpty ? 'v$_version ($_buildNumber)' : '',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    if (_version.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      if (_historyLoading)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _showReleaseHistory,
                              child: Text(
                                '更新历史',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('|', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _launchUrl('https://github.com/xucux/ZheDuoDuo/discussions'),
                              child: Text(
                                '反馈',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('应用说明',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      '折多多是一款商品折扣优惠记录工具，帮助您轻松管理各类商品的价格信息、'
                      '优惠券叠加、历史价格走势和数据备份同步。'
                      '集成 AI 对话能力，支持多种 AI 协议服务商，可智能解析商品信息。',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Update check
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              child: ListTile(
                leading: Icon(_checking ? Icons.sync : Icons.system_update_outlined),
                title: Text(_checking ? '正在检查...' : '检查更新'),
                subtitle: Text(
                  _releaseList != null && _releaseList!.isNotEmpty
                      ? '最新版本 v${_releaseList!.first['version']}'
                      : _error ?? '检查是否有新版本',
                ),
                trailing: _checking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _checking ? null : _checkUpdate,
              ),
            ),
          ),
          // Release history
          if (_releaseList != null && _releaseList!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('版本更新记录',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            ..._releaseList!.map((release) => _buildReleaseCard(context, release)),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildReleaseCard(BuildContext context, Map<String, dynamic> release) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final version = release['version'] as String? ?? '';
    final date = release['releaseDate'] as String? ?? '';
    final notes = release['releaseNotes'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('v$version',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary)),
                  ),
                  const SizedBox(width: 8),
                  Text(date,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant)),
                ],
              ),
              if (notes.isNotEmpty) const SizedBox(height: 8),
              ...notes.map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ',
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                        Expanded(child: Text(note.toString())),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
