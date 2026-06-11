import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ocr_service.dart';

class OcrTestScreen extends StatefulWidget {
  const OcrTestScreen({super.key});

  @override
  State<OcrTestScreen> createState() => _OcrTestScreenState();
}

class _OcrTestScreenState extends State<OcrTestScreen>
    with SingleTickerProviderStateMixin {
  final _ocrService = OcrService();
  final _picker = ImagePicker();
  File? _image;
  bool _loading = false;
  String? _error;

  String _rawText = '';

  late final TextEditingController _rawController;
  late final TextEditingController _jsonController;
  late final TextEditingController _mdController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _rawController = TextEditingController();
    _jsonController = TextEditingController();
    _mdController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rawController.dispose();
    _jsonController.dispose();
    _mdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (xfile != null) {
      setState(() {
        _image = File(xfile.path);
        _rawText = '';
        _rawController.clear();
        _jsonController.clear();
        _mdController.clear();
        _error = null;
      });
    }
  }

  Future<void> _recognize() async {
    if (_image == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final path = _image!.path;
      final results = await Future.wait([
        _ocrService.recognizeStructured(path),
        _ocrService.recognizeAsMarkdown(path),
        _ocrService.recognizeImage(path),
      ]);
      final structured = results[0] as Map<String, dynamic>;
      final markdown = results[1] as String;
      final raw = results[2] as String;
      final jsonStr = const JsonEncoder.withIndent('  ').convert(structured);
      setState(() {
        _rawText = raw;
        _rawController.text = raw;
        _jsonController.text = jsonStr;
        _mdController.text = markdown;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '识别失败: $e';
        _loading = false;
      });
    }
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR 识别测试'),
        bottom: _rawText.isNotEmpty
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '完整文本'),
                  Tab(text: 'JSON 数据'),
                  Tab(text: 'MD 格式'),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          _buildImageSection(theme),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          if (_rawText.isNotEmpty) _buildResultSection(),
        ],
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _image!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            )
          else
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '请选择一张包含文字的图片',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _loading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('从相册选择'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('拍照'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: (_image == null || _loading) ? null : _recognize,
              icon: const Icon(Icons.text_snippet_outlined),
              label: const Text('开始识别'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildEditorTab(_rawController, '完整文本'),
          _buildEditorTab(_jsonController, 'JSON 数据'),
          _buildEditorTab(_mdController, 'MD 格式'),
        ],
      ),
    );
  }

  Widget _buildEditorTab(TextEditingController controller, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: '复制',
                onPressed: () => _copyText(controller.text),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
