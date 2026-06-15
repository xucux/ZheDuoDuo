import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/deals/providers/deals_provider.dart';
import '../theme/antd_colors.dart';

class TagInput extends ConsumerStatefulWidget {
  final List<String> initialTags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagInput({
    super.key,
    this.initialTags = const [],
    required this.onTagsChanged,
  });

  @override
  ConsumerState<TagInput> createState() => _TagInputState();
}

class _TagInputState extends ConsumerState<TagInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late List<String> _tags;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
    _controller.addListener(_onInputChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        final pending = _controller.text.trim();
        if (pending.isNotEmpty) {
          _addTag(pending);
        } else {
          setState(() => _showSuggestions = false);
        }
      } else {
        if (_controller.text.isNotEmpty) {
          _updateSuggestions(_controller.text);
        }
      }
    });
  }

  @override
  void didUpdateWidget(TagInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tags = List.from(widget.initialTags);
  }

  @override
  void dispose() {
    _controller.removeListener(_onInputChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final text = _controller.text;
    if (text.contains(',') || text.contains('，')) {
      _addTagFromComma(text);
      return;
    }
    _updateSuggestions(text);
  }

  void _updateSuggestions(String query) {
    final allTags = ref.read(tagsProvider).valueOrNull ?? [];
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    setState(() {
      _suggestions = allTags
          .where((t) => t.toLowerCase().contains(query.toLowerCase()) && !_tags.contains(t))
          .take(10)
          .toList();
      _showSuggestions = _focusNode.hasFocus && _suggestions.isNotEmpty;
    });
  }

  void _addTagFromComma(String text) {
    final parts = text.split(RegExp(r'[,，]'));
    bool added = false;
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
        _tags.add(trimmed);
        added = true;
      }
    }
    _controller.clear();
    _updateSuggestions('');
    if (added) {
      widget.onTagsChanged(List.from(_tags));
    }
  }

  void _addTag(String tag) {
    if (!_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _controller.clear();
        _showSuggestions = false;
        _suggestions = [];
      });
      widget.onTagsChanged(List.from(_tags));
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(List.from(_tags));
  }

  void _showTagLibrary() {
    final allTags = ref.read(tagsProvider).valueOrNull ?? [];
    final searchController = SearchController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.6,
          ),
          child: _TagLibrarySheet(
            allTags: allTags,
            selectedTags: _tags,
            searchController: searchController,
            onTagTap: (tag) {
              if (_tags.contains(tag)) {
                _removeTag(tag);
              } else {
                _addTag(tag);
              }
              Navigator.pop(ctx);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => _removeTag(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: '输入标签，逗号分隔',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AntdColors.primary, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                  suffixIcon: _showSuggestions
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            _controller.clear();
                            _updateSuggestions('');
                          },
                        )
                      : null,
                ),
                onSubmitted: (_) {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    _addTag(text);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _showTagLibrary,
              icon: const Icon(Icons.bookmark_outline),
              tooltip: '从标签库选择',
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(suggestion, style: const TextStyle(fontSize: 13)),
                  onTap: () => _addTag(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _TagLibrarySheet extends StatefulWidget {
  final List<String> allTags;
  final List<String> selectedTags;
  final SearchController searchController;
  final ValueChanged<String> onTagTap;

  const _TagLibrarySheet({
    required this.allTags,
    required this.selectedTags,
    required this.searchController,
    required this.onTagTap,
  });

  @override
  State<_TagLibrarySheet> createState() => _TagLibrarySheetState();
}

class _TagLibrarySheetState extends State<_TagLibrarySheet> {
  String _query = '';

  List<String> get _filteredTags {
    if (_query.isEmpty) return widget.allTags;
    final q = _query.toLowerCase();
    return widget.allTags.where((t) => t.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('从标签库选择',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close,
                    size: 20, color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              hintText: '搜索标签...',
              prefixIcon: const Icon(Icons.search, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AntdColors.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const SizedBox(height: 8),
        if (_filteredTags.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text('无匹配标签', style: TextStyle(color: Colors.grey)),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTags.length,
              itemBuilder: (context, index) {
                final tag = _filteredTags[index];
                final isSelected = widget.selectedTags.contains(tag);
                return ListTile(
                  title: Text(tag),
                  trailing: isSelected
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () => widget.onTagTap(tag),
                );
              },
            ),
          ),
      ],
    );
  }
}
