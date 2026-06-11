// 提示词数据访问对象（DAO）
//
// 提供提示词的增删改查操作，包括：
// - 获取/监听所有提示词（按排序字段排列）
// - 保存/删除/创建提示词
// - 初始化系统默认提示词（商品图片解析、购物比价助手、文案优化）

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/prompts.dart';

part 'prompt_dao.g.dart';

/// 提示词数据访问对象
///
/// 管理 AI 提示词模板的 CRUD 操作，支持系统预设和用户自定义提示词。
@DriftAccessor(tables: [Prompts])
class PromptDao extends DatabaseAccessor<AppDatabase> with _$PromptDaoMixin {
  PromptDao(super.db);

  static const _uuid = Uuid();

  /// 获取所有提示词（按 sortOrder 升序）
  Future<List<Prompt>> getAllPrompts() async {
    return (select(prompts)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
  }

  /// 监听所有提示词变化（按 sortOrder 升序）
  Stream<List<Prompt>> watchAllPrompts() {
    return (select(prompts)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  }

  /// 根据 ID 获取提示词
  Future<Prompt?> getPromptById(String id) async {
    final query = select(prompts)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  /// 保存提示词（upsert）
  Future<void> savePrompt(PromptsCompanion entry) async {
    await into(prompts).insertOnConflictUpdate(entry);
  }

  /// 删除指定提示词
  Future<void> deletePrompt(String id) async {
    await (delete(prompts)..where((t) => t.id.equals(id))).go();
  }

  /// 创建新提示词，返回生成的 ID
  Future<String> createPrompt(String name, String content) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await into(prompts).insert(PromptsCompanion.insert(
      id: id,
      name: name,
      content: content,
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }

  /// 初始化系统默认提示词
  ///
  /// 仅在 category='system' 的记录为空时执行，
  /// 插入商品图片解析、购物比价助手、文案优化三条默认提示词。
  Future<void> seedDefaultPrompts() async {
    final count = await (select(prompts)..where((t) => t.category.equals('system'))).get();
    if (count.isNotEmpty) return;

    final now = DateTime.now();
    final defaults = [
      ('商品图片解析', defaultImageParsePrompt, 0),
      ('购物比价助手', defaultShoppingAssistantPrompt, 1),
      ('文案优化', defaultCopywritingPrompt, 2),
    ];

    for (var i = 0; i < defaults.length; i++) {
      final (name, content, order) = defaults[i];
      await into(prompts).insert(PromptsCompanion.insert(
        id: _uuid.v4(),
        name: name,
        content: content,
        category: const Value('system'),
        sortOrder: Value(order),
        createdAt: now,
        updatedAt: now,
      ));
    }
  }
}

/// 默认提示词：商品图片解析
///
/// 指导 AI 解析商品截图并输出结构化 YAML 格式。
const defaultImageParsePrompt = '''你是一个专业的电商图片解析引擎。

## 任务
分析输入图片中的所有商品信息，并严格按照指定 YAML 格式输出。

输出内容必须来源于图片中的可见信息，不允许编造数据。

## 输出格式
```yaml
product:
  title: "商品全称"
promotions:
  - "促销文案1"
prices:
  original_price: 原价
  discounted_price: 到手价
source:
  platform: "平台名称"
  logistics: "物流信息"
```''';

/// 默认提示词：购物比价助手
///
/// 指导 AI 分析商品优惠、优惠券叠加和历史价格走势。
const defaultShoppingAssistantPrompt = '''你是购物比价专家，擅长分析商品优惠、优惠券叠加、历史价格走势。

## 任务
根据用户提供的商品信息，分析最优购买方案。

## 分析要点
1. 价格优惠力度
2. 优惠券叠加情况
3. 平台活动参与
4. 购买建议
5. 注意事项''';

/// 默认提示词：文案优化
///
/// 指导 AI 将商品信息优化为吸引人的促销文案。
const defaultCopywritingPrompt = '''你是一个专业的电商文案优化师。

## 任务
将用户提供的商品信息优化为吸引人的促销文案。

## 输出要求
- 标题简洁有力
- 突出核心卖点
- 价格信息清晰
- 促销权益明确
- 适合在社交平台传播''';
