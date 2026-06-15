import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/deal_dao.dart';
import 'package:path/path.dart' as p;
import '../../../core/utils/yaml_parser.dart';
import '../../../core/utils/image_compress.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../shared/theme/antd_colors.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../../shared/widgets/tag_input.dart';
import '../providers/deals_provider.dart';

/// 优惠券表单数据
class CouponFormData {
  final TextEditingController countController;
  final TextEditingController sourceController;
  final TextEditingController strengthController;
  final TextEditingController noteController;

  CouponFormData({
    String count = '1',
    String source = '',
    String strength = '',
    String note = '',
  })  : countController = TextEditingController(text: count),
        sourceController = TextEditingController(text: source),
        strengthController = TextEditingController(text: strength),
        noteController = TextEditingController(text: note);

  void dispose() {
    countController.dispose();
    sourceController.dispose();
    strengthController.dispose();
    noteController.dispose();
  }
}

class DealFormScreen extends ConsumerStatefulWidget {
  final String? dealId;

  const DealFormScreen({super.key, this.dealId});

  @override
  ConsumerState<DealFormScreen> createState() => _DealFormScreenState();
}

class _DealFormScreenState extends ConsumerState<DealFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Form fields
  final _titleController = TextEditingController();
  final _currentPriceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _displayPriceController = TextEditingController();
  final _platformController = TextEditingController(text: '其他');
  final _categoryController = TextEditingController(text: '其他');
  final _logisticsController = TextEditingController();
  final _linkController = TextEditingController();
  final _noteController = TextEditingController();
  List<String> _tags = [];
  final _promotionsController = TextEditingController();
  final _yamlController = TextEditingController();

  String _visualType = 'none';
  String? _imagePath;
  String? _resolvedImagePath;
  String? _asciiArt;
  String _currency = '¥';
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isLowestPrice = false;
  DateTime? _createdAt;
  String? _yamlSourceJson;
  String? _sourceJson;

  // 图片压缩结果信息
  int? _imageOriginalSize;
  int? _imageCompressedSize;
  int? _imageQuality;

  // 优惠券列表
  final List<CouponFormData> _coupons = [];

  // 编辑模式下原有优惠券的ID列表（用于upsert）
  final List<int> _existingCouponIds = [];

  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.dealId != null) {
      _isEditing = true;
      _loadDeal();
    }
  }

  Future<void> _loadDeal() async {
    final dealDao = ref.read(dealDaoProvider);
    final dw = await dealDao.getDealById(widget.dealId!);
    if (dw == null) return;

    setState(() {
      _titleController.text = dw.deal.title;
      _currentPriceController.text = dw.deal.currentPrice.toString();
      _originalPriceController.text = dw.deal.originalPrice?.toString() ?? '';
      _displayPriceController.text = dw.deal.displayPrice?.toString() ?? '';
      _platformController.text = dw.deal.platform;
      _categoryController.text = dw.deal.category;
      _logisticsController.text = dw.deal.logistics ?? '';
      _linkController.text = dw.deal.link ?? '';
      _noteController.text = dw.deal.note ?? '';
      _tags = List.from(dw.tags);
      _promotionsController.text = dw.promotions.join('\n');
      _visualType = dw.deal.visualType;
      _imagePath = dw.image?.imagePath;
      _resolveImagePath();
      _asciiArt = dw.deal.asciiArt;
      _currency = dw.deal.currency;
      _isLowestPrice = dw.deal.isLowestPrice == 1;
      _createdAt = dw.deal.createdAt;
      _sourceJson = dw.deal.sourceJson;

      // 加载图片压缩信息
      _imageOriginalSize = dw.image?.originalSize;
      _imageCompressedSize = dw.image?.compressedSize;
      _imageQuality = dw.image?.quality;

      // 加载优惠券并保存原有ID
      _coupons.clear();
      _existingCouponIds.clear();
      for (final c in dw.coupons) {
        _coupons.add(CouponFormData(
          count: c.count.toString(),
          source: c.source,
          strength: c.strength,
          note: c.note ?? '',
        ));
        _existingCouponIds.add(c.id);
      }
      debugPrint('[DealForm] 加载优惠时读取到 ${_existingCouponIds.length} 个优惠券ID: $_existingCouponIds');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _currentPriceController.dispose();
    _originalPriceController.dispose();
    _displayPriceController.dispose();
    _platformController.dispose();
    _categoryController.dispose();
    _logisticsController.dispose();
    _linkController.dispose();
    _noteController.dispose();
    _promotionsController.dispose();
    _yamlController.dispose();
    for (final c in _coupons) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑优惠' : '新建优惠'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDeal,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            if (!_isEditing)
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'YAML 解析'),
                  Tab(text: '表单填写'),
                ],
              ),
            Expanded(
              child: _isEditing
                  ? _buildManualForm()
                  : TabBarView(
                      controller: _tabController,
                      children: [_buildYamlTab(), _buildManualForm()],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== YAML Tab =====
  Widget _buildYamlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('粘贴 YAML 格式的优惠信息', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text('支持结构化 YAML（product / promotions / prices / source），含促销权益、图片 URL 与 ASCII 图', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline, height: 1.4)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _yamlController,
            maxLines: 14,
            decoration: InputDecoration(
              hintText: 'product:\n  title: "商品名称"\npromotions:\n  - "领券再减15%"\nprices:\n  original_price: 1629.00\n  discounted_price: 1068.00\nsource:\n  platform: "京东"',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            ),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: _fillExample, icon: const Icon(Icons.auto_awesome, size: 16), label: const Text('填入示例'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.icon(onPressed: _parseYaml, icon: const Icon(Icons.play_arrow, size: 16), label: const Text('解析并填充'))),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Manual Form =====
  Widget _buildManualForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 商品名称
          _buildLabel('商品名称 *'),
          TextFormField(
            controller: _titleController,
            decoration: _inputDecoration('如：iPhone 15 Pro 256G'),
            validator: (v) => v == null || v.isEmpty ? '请输入商品名称' : null,
          ),
          const SizedBox(height: 14),

          // 到手价 + 原价
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLabel('到手价 *'),
                  TextFormField(
                    controller: _currentPriceController,
                    decoration: _inputDecoration('1068', prefix: _currency),
                    keyboardType: TextInputType.number,
                    validator: (v) { if (v == null || v.isEmpty) return '必填'; if (double.tryParse(v) == null) return '无效'; return null; },
                  ),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLabel('原价'),
                  TextFormField(controller: _originalPriceController, decoration: _inputDecoration('1629', prefix: _currency), keyboardType: TextInputType.number),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 展示价
          _buildLabel('展示价'),
          TextFormField(controller: _displayPriceController, decoration: _inputDecoration('1492.25', prefix: _currency), keyboardType: TextInputType.number),
          const SizedBox(height: 8),

          // 史低标识
          Row(
            children: [
              Checkbox(
                value: _isLowestPrice,
                onChanged: (v) => setState(() => _isLowestPrice = v ?? false),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              GestureDetector(
                onTap: () => setState(() => _isLowestPrice = !_isLowestPrice),
                child: const Text('当前为历史最低价', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 货币
          _buildLabel('货币'),
          Row(
            children: ['¥', '\$', '€', '£', 'HK\$', '₩'].map((c) {
              final isSelected = _currency == c;
              return Padding(
                padding: EdgeInsets.only(right: c != ['¥', '\$', '€', '£', 'HK\$', '₩'].last ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _currency = c),
                  child: Container(
                    height: 36,
                    width: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? AntdColors.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(c, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // 平台 + 分类
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLabel('平台'),
                  TextFormField(controller: _platformController, decoration: _inputDecoration('京东/淘宝/拼多多...')),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLabel('分类'),
                  TextFormField(controller: _categoryController, decoration: _inputDecoration('数码/美妆/家电...')),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 物流 + 购买链接
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLabel('物流'),
                  TextFormField(controller: _logisticsController, decoration: _inputDecoration('京东物流')),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLabel('购买链接'),
                  TextFormField(controller: _linkController, decoration: _inputDecoration('https://'), keyboardType: TextInputType.url),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 标签
          _buildLabel('标签'),
          TagInput(
            initialTags: _tags,
            onTagsChanged: (tags) {
              setState(() => _tags = List.from(tags));
            },
          ),
          const SizedBox(height: 14),

          // 创建时间
          _buildLabel('创建时间（点击修改）'),
          GestureDetector(
            onTap: _pickDateTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 8),
                  Text(
                    _createdAt == null ? '自动设为当前时间' : DateFormat('yyyy-MM-dd HH:mm').format(_createdAt!),
                    style: TextStyle(
                      fontSize: 14,
                      color: _createdAt == null ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (_createdAt != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _createdAt = null),
                      child: Icon(Icons.close, size: 14, color: Theme.of(context).colorScheme.outline),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 促销权益
          _buildLabel('促销权益（每行一项）'),
          TextFormField(
            controller: _promotionsController,
            maxLines: 4,
            decoration: _inputDecoration('PLUS券后预计到手价1068元\n领券再减15%\n免费安装\n9年质保').copyWith(alignLabelWithHint: true),
          ),
          const SizedBox(height: 6),
          Text('YAML 导入时会自动拆分为标签与优惠券，此处保留原始促销文案供详情展示', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline, height: 1.3)),
          const SizedBox(height: 14),

          // ===== 优惠券信息 =====
          _buildCouponSection(),
          const SizedBox(height: 14),

          // ===== 视觉内容 =====
          _buildVisualSection(),
          const SizedBox(height: 14),

          // 备注
          _buildLabel('备注'),
          TextFormField(
            controller: _noteController,
            maxLines: 3,
            decoration: _inputDecoration('可选备注信息').copyWith(alignLabelWithHint: true),
          ),
          const SizedBox(height: 24),

          // 保存按钮
          FilledButton(
            onPressed: _isLoading ? null : _saveDeal,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEditing ? '保存修改' : '创建优惠'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ===== 优惠券编辑区 =====
  Widget _buildCouponSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_num_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('优惠券信息', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            GestureDetector(
              onTap: _addCoupon,
              child: Text('+ 添加', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AntdColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_coupons.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('暂无优惠券，点击添加', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: theme.colorScheme.outline)),
          ),
        ..._coupons.asMap().entries.map((entry) => _buildCouponCard(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildCouponCard(int index, CouponFormData coupon) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: title + delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('优惠券 ${index + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
              GestureDetector(
                onTap: () => _removeCoupon(index),
                child: Icon(Icons.close, size: 16, color: theme.colorScheme.outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 张数 + 来源
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('张数', style: TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
                  const SizedBox(height: 2),
                  TextFormField(controller: coupon.countController, decoration: _smallInputDecoration('1'), keyboardType: TextInputType.number, style: const TextStyle(fontSize: 13)),
                ]),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('来源', style: TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
                  const SizedBox(height: 2),
                  TextFormField(controller: coupon.sourceController, decoration: _smallInputDecoration('店铺券/平台券/直播间'), style: const TextStyle(fontSize: 13)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 优惠力度
          Text('优惠力度', style: TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
          const SizedBox(height: 2),
          TextFormField(controller: coupon.strengthController, decoration: _smallInputDecoration('满300减50 / 9折 / 直减100'), style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          // 备注
          Text('备注', style: TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
          const SizedBox(height: 2),
          TextFormField(controller: coupon.noteController, decoration: _smallInputDecoration('券码、领取方式等'), style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  void _addCoupon() {
    setState(() => _coupons.add(CouponFormData()));
  }

  void _removeCoupon(int index) {
    setState(() {
      _coupons[index].dispose();
      _coupons.removeAt(index);
    });
  }

  // ===== 视觉内容区 =====
  Widget _buildVisualSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('视觉内容（可选）', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        // Toggle buttons
        Row(
          children: ['none', 'image', 'ascii'].map((type) {
            final isSelected = _visualType == type;
            final labels = {'none': '无', 'image': '图片', 'ascii': 'ASCII'};
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: type != 'ascii' ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _visualType = type),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? AntdColors.primary : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(labels[type]!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_visualType == 'image') ...[
          const SizedBox(height: 10),
          if (_imagePath != null)
            GestureDetector(
              onTap: () {
                final display = _resolvedImagePath ?? _imagePath!;
                _openImageViewer(context, display);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.file(
                      File(_resolvedImagePath ?? _imagePath!),
                      height: 160, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: 160, color: theme.colorScheme.surfaceContainerHighest, child: const Center(child: Text('图片加载失败'))),
                    ),
                    Positioned(
                      right: 8, bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library, size: 16), label: const Text('相册'))),
              // 桌面端隐藏拍照按钮（无摄像头支持）
              if (PlatformUtils.isCameraSupported) ...[
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt, size: 16), label: const Text('拍照'))),
              ],
            ],
          ),
        ],
        if (_visualType == 'ascii') ...[
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _asciiArt,
            maxLines: 6,
            decoration: _inputDecoration('/\\_/\\  (示例 ASCII 猫)\n( o.o )\n > ^ <'),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            onChanged: (v) => _asciiArt = v,
          ),
        ],
      ],
    );
  }

  // ===== Helper Widgets =====
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AntdColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    );
  }

  InputDecoration _smallInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AntdColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      isDense: true,
    );
  }

  // ===== YAML =====
  void _fillExample() {
    _yamlController.text = '''product:
  title: "九牧（JOMOO）智能浴室柜陶瓷一体盆洗脸盆柜组合"
promotions:
  - "PLUS券后预计到手价1068元"
  - "领券再减15%"
  - "官方直降5%"
  - "免费安装"
  - "9年质保"
  - "保价618"
  - "满额赠送价值199元角阀套装"
prices:
  original_price: 1629.00
  discounted_price: 1068.00
  current_display_price: 1492.25
  currency: "CNY"
sales:
  sold_30_days: ">1000"
source:
  platform: "京东"
  logistics: "京东物流"
  link: "https://item.jd.com/100012345.html"''';
  }

  void _parseYaml() {
    final yamlStr = _yamlController.text.trim();
    if (yamlStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入 YAML 内容')));
      return;
    }

    try {
      final parsed = YamlParser.parse(yamlStr);

      setState(() {
        _titleController.text = parsed.title;
        _currentPriceController.text = parsed.currentPrice.toString();
        _originalPriceController.text = parsed.originalPrice?.toString() ?? '';
        _displayPriceController.text = parsed.displayPrice?.toString() ?? '';
        _platformController.text = parsed.platform;
        _categoryController.text = parsed.category;
        _logisticsController.text = parsed.logistics ?? '';
        _linkController.text = parsed.link ?? '';
        _noteController.text = parsed.note ?? '';
        _tags = List.from(parsed.tags);
        _promotionsController.text = parsed.promotions.join('\n');
        _visualType = parsed.visualType;
        _asciiArt = parsed.asciiArt;
        _currency = parsed.currency;
        _createdAt = parsed.createdAt;
        _yamlSourceJson = parsed.sourceJson;

        // 解析优惠券
        _coupons.clear();
        for (final c in parsed.coupons) {
          _coupons.add(CouponFormData(
            count: c.count.toString(),
            source: c.source,
            strength: c.strength,
            note: c.note ?? '',
          ));
        }
      });

      _tabController.animateTo(1);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('YAML 解析成功，请核对信息')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('解析失败: $e')));
    }
  }

  // ===== Date Time =====
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _createdAt ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null || !mounted) return;

    setState(() {
      _createdAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  // ===== Image =====
  Future<void> _pickImage(ImageSource source) async {
    // 使用平台适配工具选择图片（桌面端自动回退到文件选择器）
    final path = await PlatformUtils.pickImage(source);
    if (path == null) return;

    final compressDao = ref.read(imageCompressSettingsDaoProvider);
    final result = await ImageUtils.prepareImage(
      File(path),
      compressDao: compressDao,
    );
    if (result != null) {
      setState(() {
        _imagePath = result.filePath;
        _imageOriginalSize = result.originalSize;
        _imageCompressedSize = result.compressedSize;
        _imageQuality = result.quality;
      });
      _resolveImagePath();
    }
  }

  Future<void> _resolveImagePath() async {
    if (_imagePath == null) return;
    final resolved = await ImageUtils.resolveImagePath(_imagePath!);
    if (mounted) {
      setState(() => _resolvedImagePath = resolved);
    }
  }

  // ===== Save =====
  Future<void> _saveDeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final id = widget.dealId ?? _uuid.v4();
      final now = DateTime.now();

      debugPrint('[DealForm] 开始保存优惠, dealId: $id, isEditing: $_isEditing');

      final tags = List<String>.from(_tags);
      final promotions = _promotionsController.text.split('\n').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

      debugPrint('[DealForm] 标签数: ${tags.length}, 促销数: ${promotions.length}');

      // 构建优惠券 - 编辑模式下需要保留原有ID进行upsert
      final coupons = <Coupon>[];
      debugPrint('[DealForm] 处理优惠券, 表单数量: ${_coupons.length}');
      for (var i = 0; i < _coupons.length; i++) {
        final c = _coupons[i];
        final count = int.tryParse(c.countController.text) ?? 1;
        final source = c.sourceController.text.trim();
        final strength = c.strengthController.text.trim();
        final note = c.noteController.text.trim();
        if (strength.isNotEmpty || source.isNotEmpty) {
          // 编辑模式下尝试获取原有优惠券ID
          int couponId = 0;
          if (_isEditing && i < _existingCouponIds.length) {
            couponId = _existingCouponIds[i];
            debugPrint('[DealForm] 优惠券 $i 使用原有ID: $couponId');
          }
          coupons.add(Coupon(
            id: couponId,
            dealId: id,
            sortOrder: i,
            count: count,
            source: source,
            strength: strength,
            note: note.isEmpty ? null : note,
          ));
        }
      }
      debugPrint('[DealForm] 有效优惠券数: ${coupons.length}');

      final originalPrice = _originalPriceController.text.isNotEmpty ? double.tryParse(_originalPriceController.text) : null;
      final currentPrice = double.parse(_currentPriceController.text);
      String? discount;
      if (originalPrice != null && originalPrice > 0 && currentPrice > 0) {
        discount = '${(currentPrice / originalPrice * 10).toStringAsFixed(1)}折';
      }

      final createdAt = _createdAt ?? now;

      final deal = Deal(
        id: id,
        title: _titleController.text.trim(),
        platform: _platformController.text.trim().isEmpty ? '其他' : _platformController.text.trim(),
        category: _categoryController.text.trim().isEmpty ? '其他' : _categoryController.text.trim(),
        currentPrice: currentPrice,
        originalPrice: originalPrice,
        displayPrice: _displayPriceController.text.isNotEmpty ? double.tryParse(_displayPriceController.text) : null,
        currency: _currency,
        discount: discount,
        logistics: _logisticsController.text.isNotEmpty ? _logisticsController.text : null,
        link: _linkController.text.isNotEmpty ? _linkController.text : null,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        visualType: _visualType,
        asciiArt: _visualType == 'ascii' ? _asciiArt : null,
        sourceJson: _isEditing
            ? _sourceJson
            : (_yamlSourceJson ?? '{"sourceType":"手动新增"}'),
        isLowestPrice: _isLowestPrice ? 1 : 0,
        createdAt: createdAt,
        updatedAt: now,
        revision: 1,
        deleted: 0,
      );

      DealImage? dealImage;
      if (_visualType == 'image' && _imagePath != null) {
        final file = File(_resolvedImagePath ?? _imagePath!);
        if (file.existsSync()) {
          dealImage = DealImage(
            dealId: id,
            imagePath: p.basename(_imagePath!),
            originalSize: _imageOriginalSize,
            compressedSize: _imageCompressedSize ?? await file.length(),
            quality: _imageQuality,
            updatedAt: now,
            deleted: 0,
          );
        }
      }

      final dealWithDetails = DealWithDetails(deal: deal, tags: tags, promotions: promotions, coupons: coupons, image: dealImage);

      await ref.read(dealDaoProvider).saveDeal(dealWithDetails);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditing ? '已保存' : '已创建')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openImageViewer(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white38, size: 64),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
