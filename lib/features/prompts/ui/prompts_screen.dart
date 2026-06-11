import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/prompt_dao.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../../shared/theme/antd_colors.dart';

final promptDaoProvider = Provider<PromptDao>((ref) {
  final db = ref.watch(databaseProvider);
  return PromptDao(db);
});

final promptsProvider = StreamProvider<List<Prompt>>((ref) {
  final dao = ref.watch(promptDaoProvider);
  return dao.watchAllPrompts();
});

class PromptsScreen extends ConsumerStatefulWidget {
  const PromptsScreen({super.key});

  @override
  ConsumerState<PromptsScreen> createState() => _PromptsScreenState();
}

class _PromptsScreenState extends ConsumerState<PromptsScreen> {
  @override
  void initState() {
    super.initState();
    _seedDefaults();
  }

  Future<void> _seedDefaults() async {
    final dao = ref.read(promptDaoProvider);
    await dao.seedDefaultPrompts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final promptsAsync = ref.watch(promptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('提示词'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () => _showAddPromptDialog(context),
          ),
        ],
      ),
      body: promptsAsync.when(
        data: (prompts) {
          if (prompts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.text_snippet_outlined, size: 56, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 12),
                  Text('暂无提示词', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () => _showAddPromptDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('添加提示词'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: prompts.length,
            itemBuilder: (ctx, idx) {
              final prompt = prompts[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Slidable(
                  key: ValueKey(prompt.id),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _copyPrompt(prompt),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.copy,
                        label: '复制',
                      ),
                      SlidableAction(
                        onPressed: (_) => _showEditDialog(context, prompt),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: '编辑',
                      ),
                      SlidableAction(
                        onPressed: (_) => _confirmDelete(context, prompt),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: '删除',
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5), width: 0.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _showEditDialog(context, prompt),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    prompt.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                                  ),
                                ),
                                if (prompt.category == 'system')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AntdColors.primaryBg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('系统', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AntdColors.primary)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prompt.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, height: 1.4, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }

  void _showAddPromptDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Container(width: 36, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
                  const Spacer(),
                  Text('添加提示词', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('商品图片解析'),
              subtitle: const Text('解析商品截图中的信息'),
              onTap: () { Navigator.pop(ctx); _createPrompt('商品图片解析', defaultImageParsePrompt); },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('购物比价助手'),
              subtitle: const Text('分析最优购买方案'),
              onTap: () { Navigator.pop(ctx); _createPrompt('购物比价助手', defaultShoppingAssistantPrompt); },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note_outlined),
              title: const Text('文案优化'),
              subtitle: const Text('优化促销文案'),
              onTap: () { Navigator.pop(ctx); _createPrompt('文案优化', defaultCopywritingPrompt); },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('自定义'),
              subtitle: const Text('从空白开始创建'),
              onTap: () { Navigator.pop(ctx); _showEditDialog(context, null); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _createPrompt(String name, String content) async {
    try {
      await ref.read(promptDaoProvider).createPrompt(name, content);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已添加「$name」')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('添加失败: $e')));
    }
  }

  void _showEditDialog(BuildContext context, Prompt? prompt) {
    final nameController = TextEditingController(text: prompt?.name ?? '');
    final contentController = TextEditingController(text: prompt?.content ?? '');
    final isNew = prompt == null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNew ? '新建提示词' : '编辑提示词'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  hintText: '提示词名称',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: '内容',
                  hintText: '输入提示词内容',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final content = contentController.text.trim();
              if (name.isEmpty || content.isEmpty) return;

              try {
                final dao = ref.read(promptDaoProvider);
                if (isNew) {
                  await dao.createPrompt(name, content);
                } else {
                  await dao.savePrompt(PromptsCompanion(
                    id: Value(prompt.id),
                    name: Value(name),
                    content: Value(content),
                    updatedAt: Value(DateTime.now()),
                  ));
                }
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('保存失败: $e')));
                }
              }
            },
            child: Text(isNew ? '创建' : '保存'),
          ),
        ],
      ),
    );
  }

  void _copyPrompt(Prompt prompt) {
    Clipboard.setData(ClipboardData(text: prompt.content));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已复制「${prompt.name}」')),
      );
    }
  }

  void _confirmDelete(BuildContext context, Prompt prompt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${prompt.name}」吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(promptDaoProvider).deletePrompt(prompt.id);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已删除')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('删除失败: $e')));
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
