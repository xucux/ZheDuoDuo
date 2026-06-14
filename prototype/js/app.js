import { YAML_EXAMPLE, SAMPLE_DEALS } from './data.js';
import { normalizeYamlData } from './yaml-parser.js';
import { compressDataUrl, fetchAndCompressImage, formatBytes } from './image-utils.js';
import { NavBar } from './components.js';
import {
  AI_PROVIDERS, getProvider, resolveAiUrl, resolveAiName, loadAiSession, saveAiSession, clearAiSession,
  exportAiSessionsJson, importAiSessionsJson,
} from './ai-session.js';
import {
  AI_PROTOCOLS, AI_PROVIDERS_PRESETS, AI_AGENTS, defaultChatSettings, loadChatSettings, saveChatSettings,
  applyProviderPreset,
  loadChatSessions, createSession, getSession, updateSession, addMessage, deleteSession,
  clearAllChatSessions, exportChatSessions, importChatSessions, mockSendMessage,
} from './ai-chat.js';
import { WEBDAV_PRESETS, getWebdavPreset, applyWebdavPreset } from './webdav-providers.js';
import {
  buildListPreview, buildSearchPreview, buildDetailPreview, buildFormPreview,
  buildAiPreview, buildMinePreview, buildBackupPreview, buildCloudPreview,
  buildConfigPreview, buildSettingsPreview,
} from './previews.js';

// 默认 AI 提示词：图片商品信息解析
const DEFAULT_AI_PROMPT = `你是一个专业的电商图片解析引擎。

## 任务

分析输入图片中的所有商品信息，并严格按照指定 YAML 格式输出。

输出内容必须来源于图片中的可见信息，不允许编造数据。

---

## 字段映射规则

| 图片信息    | YAML路径                       |
| ------- | ---------------------------- |
| 商品名称    | product.title                |
| 到手价     | prices.discounted_price      |
| 原价      | prices.original_price        |
| 展示价/活动价 | prices.current_display_price |
| 货币      | prices.currency              |
| 平台      | source.platform              |
| 物流      | source.logistics             |
| 商品分类    | product.category             |
| 商品链接    | source.link                  |
| 标签      | tags[]                       |
| 促销权益    | promotions[]                 |
| 优惠券     | coupons[]                    |
| 30天销量   | sales.sold_30_days           |
| 备注      | note                         |
| 图片类型（默认使用ascii） | visual.type  |
| ASCII图  | visual.ascii_art             |

---

## 价格解析规则

### discounted_price（到手价）

优先识别以下关键词：

* 到手价
* 券后价
* 预计到手
* 实付价
* 最终价

示例：

* PLUS券后预计到手价1068元
  → discounted_price: 1068

---

### original_price（原价）

识别：

* 原价
* 划线价
* 日常价
* 市场价

示例：

* 原价1629元
  → original_price: 1629

---

### current_display_price（展示价）

识别：

* 当前售价
* 活动价
* 页面展示价

若页面主价格与到手价不同：

页面显示1492.25元
券后预计1068元

则：

current_display_price: 1492.25
discounted_price: 1068

---

## 优惠券解析规则

从促销文案中提取优惠券信息。

输出结构：

coupons:

* count: number
  source: string
  strength: string
  note: string

示例：

文案：

* PLUS券后预计到手价1068元
* 领券再减15%

输出：

coupons:

* count: 1
  source: "PLUS券"
  strength: "预计到手"
  note: "1068元"

* count: 1
  source: "领券"
  strength: "15%OFF"

---

## 标签提取规则

tags[] 仅保留简短标签：

示例：

文案：

* 免费安装
* 9年质保
* 保价618

输出：

tags:

* 免费安装
* 9年质保
* 保价618

---

## promotions提取规则

保留完整营销文案。

示例：

promotions:

* PLUS券后预计到手价1068元
* 领券再减15%
* 官方直降5%
* 免费安装
* 9年质保
* 保价618

---

## 分类推断规则

根据商品名称自动推断：

示例：

* 智能浴室柜 → 家居建材/卫浴
* 显卡 → 数码电脑
* 洗衣液 → 日化用品

若无法判断：

category: "未知"

---

## 图片类型识别

visual.type 可选值：

* image
* ascii
* screenshot
* poster

---

## 输出要求

1. 仅输出 YAML。
2. 不输出 Markdown。
3. 不输出解释说明。
4. 所有金额统一转换为数字。
5. 去除货币符号。
6. 未识别字段使用 null。
7. 保持 YAML 可直接被程序解析。
8. promotions、tags、coupons 必须输出数组格式，即使为空。

---

## 输出模板

create_time: "{{当前时间}}"

product:
  title: null
  category: null

promotions: []

tags: []

coupons: []

prices:
  original_price: null
  discounted_price: null
  current_display_price: null
  currency: "CNY"

sales:
  sold_30_days: null

source:
  platform: null
  logistics: null
  link: null

note: null

visual:
  type: image
  image_url: null
  ascii_art: null

---

请开始解析图片，并直接输出 YAML 结果。`;

const { createApp, ref, computed, reactive, watch, nextTick, onMounted } = window.Vue;

createApp({
  components: { NavBar },
  setup() {
    const viewMode = ref('interactive');
    const activeTab = ref(0);
    const currentScreen = ref('list');
    const screenHistory = ref([]);
    const showFilterSheet = ref(false);
    const showTabBar = computed(() => currentScreen.value === 'list');
    const searchQuery = ref('');
    const searchInput = ref(null);
    const selectedDeal = ref(null);
    const editingDeal = ref(null);
    const deleteConfirm = ref(null);
    const aiWebViewRefreshing = ref(false);
    const aiSessionInput = ref(null);
    let aiRefreshTimer = null;
    const toast = reactive({ show: false, message: '' });

    const tabs = [
      { label: '清单', icon: 'fa-solid fa-list-check' },
      { label: 'AI', icon: 'fa-solid fa-robot' },
      { label: '我的', icon: 'fa-solid fa-user' },
    ];

    const platforms = ['京东', '天猫', '淘宝', '拼多多', '抖音', '其他'];
    const categories = ['数码', '家电', '家居', '美妆', '食品', '服饰', '其他'];
    const quickFilters = [
      { key: 'all', label: '全部' },
      { key: 'hasCoupon', label: '有优惠券' },
      { key: 'hasImage', label: '有图片' },
      { key: 'digital', label: '数码' },
    ];
    const sortOptions = [
      { value: 'date-desc', label: '最新添加' },
      { value: 'price-asc', label: '价格从低到高' },
      { value: 'price-desc', label: '价格从高到低' },
      { value: 'discount-desc', label: '折扣力度最大' },
      { value: 'coupon-desc', label: '优惠券最多' },
    ];
    const timeRangeOptions = [
      { value: '1m', label: '最近一个月' },
      { value: '3m', label: '最近三个月' },
      { value: '6m', label: '最近半年' },
      { value: '1y', label: '最近一年' },
      { value: 'all', label: '全部时间' },
    ];

    const activeQuickFilter = ref('all');
    const filterPlatform = ref('全部');
    const sortBy = ref('date-desc');
    const searchHistory = ref(['iPhone', '百亿补贴', '耳机']);

    const defaultSettings = () => ({
      theme: 'light',
      aiProvider: 'deepseek', // deepseek | chatgpt | custom
      aiCustomUrl: '',
      aiPersistSession: true,
      aiPromptPrefix: DEFAULT_AI_PROMPT,
      // AI 对话设置（独立存储，但合并到 settings 响应式对象中）
      aiChat: defaultChatSettings(),
      defaultSort: 'date-desc',
      filterTimeRange: '3m', // 1m | 3m | 6m | 1y | all
      listDisplayMode: 'normal', // normal | grid
      currency: '¥',
      autoBackup: false,
      cloud: {
        webdav: {
          provider: 'jianguoyun',
          enabled: false,
          autoSync: false,
          url: 'https://dav.jianguoyun.com/dav/',
          username: '',
          password: '',
          path: '/zheduoduo/',
          lastSyncAt: null,
        },
        cos: { enabled: false, secretId: '', secretKey: '', bucket: '', region: 'ap-guangzhou', autoSync: false, lastSyncAt: null },
        oss: { enabled: false, accessKeyId: '', accessKeySecret: '', bucket: '', endpoint: '', autoSync: false, lastSyncAt: null },
      },
    });

    const settings = reactive(loadSettings());
    const deals = ref(loadDeals());

    // AI 对话状态
    const chatSessions = ref(loadChatSessions());
    const currentChatSessionId = ref('');
    const chatInput = ref('');
    const chatSending = ref(false);
    const chatShowSettings = ref(false);
    const chatScrollRef = ref(null);

    const currentChatSession = computed(() => getSession(currentChatSessionId.value));

    function ensureChatSession() {
      if (!currentChatSessionId.value) {
        const s = createSession('新对话');
        currentChatSessionId.value = s.id;
        chatSessions.value = loadChatSessions();
        return s;
      }
      return currentChatSession.value;
    }

    function selectChatSession(id) {
      currentChatSessionId.value = id;
    }

    function startNewChat() {
      const s = createSession('新对话');
      currentChatSessionId.value = s.id;
      chatSessions.value = loadChatSessions();
    }

    function removeChatSession(id) {
      deleteSession(id);
      chatSessions.value = loadChatSessions();
      if (currentChatSessionId.value === id) {
        const remaining = chatSessions.value[0];
        currentChatSessionId.value = remaining ? remaining.id : '';
      }
    }

    async function sendChatMessage() {
      const text = chatInput.value.trim();
      if (!text || chatSending.value) return;
      const s = ensureChatSession();
      addMessage(s.id, 'user', text);
      chatInput.value = '';
      chatSending.value = true;
      chatSessions.value = loadChatSessions();
      nextTick(() => chatScrollRef.value && (chatScrollRef.value.scrollTop = chatScrollRef.value.scrollHeight));
      try {
        const reply = await mockSendMessage(text);
        addMessage(s.id, 'assistant', reply);
      } catch {
        addMessage(s.id, 'assistant', '（发送失败，请检查网络或 API 配置）');
      } finally {
        chatSending.value = false;
        chatSessions.value = loadChatSessions();
        nextTick(() => chatScrollRef.value && (chatScrollRef.value.scrollTop = chatScrollRef.value.scrollHeight));
      }
    }

    function saveAiChatSettings() {
      saveChatSettings(settings.aiChat);
      showToast('AI 对话设置已保存');
    }

    function exportChatBackup() {
      const blob = new Blob([exportChatSessions()], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `zheduoduo_ai_chat_${new Date().toISOString().slice(0, 10)}.json`;
      a.click();
      URL.revokeObjectURL(url);
      showToast('会话已导出');
    }

    function importChatBackup() {
      aiSessionInput.value?.click();
    }

    function handleChatImport(e) {
      const file = e.target.files?.[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = () => {
        try {
          importChatSessions(reader.result);
          chatSessions.value = loadChatSessions();
          showToast('会话已导入');
        } catch {
          showToast('导入失败：文件格式无效');
        }
        e.target.value = '';
      };
      reader.readAsText(file);
    }

    const cloudProviders = [
      { id: 'webdav', name: 'WebDAV', desc: '坚果云、Nextcloud 等', icon: 'fa-solid fa-server text-green-600', bg: 'bg-green-500/10', screen: 'cloud-webdav' },
      { id: 'cos', name: '腾讯云 COS', desc: '对象存储服务', icon: 'fa-solid fa-cloud text-blue-500', bg: 'bg-blue-500/10', screen: 'cloud-cos' },
      { id: 'oss', name: '阿里云 OSS', desc: '对象存储服务', icon: 'fa-solid fa-database text-orange-500', bg: 'bg-orange-500/10', screen: 'cloud-oss' },
    ];

    const webdavSavedSnapshot = ref('');
    const cloudConfigScreens = [
      { id: 'cos', screen: 'cloud-cos', title: '腾讯云 COS', fields: [
        { key: 'secretId', label: 'SecretId' },
        { key: 'secretKey', label: 'SecretKey', type: 'password' },
        { key: 'bucket', label: 'Bucket 名称', placeholder: 'zheduoduo-1250000000' },
        { key: 'region', label: '地域', placeholder: 'ap-guangzhou' },
      ]},
      { id: 'oss', screen: 'cloud-oss', title: '阿里云 OSS', fields: [
        { key: 'accessKeyId', label: 'AccessKey ID' },
        { key: 'accessKeySecret', label: 'AccessKey Secret', type: 'password' },
        { key: 'bucket', label: 'Bucket 名称' },
        { key: 'endpoint', label: 'Endpoint', placeholder: 'oss-cn-hangzhou.aliyuncs.com' },
      ]},
    ];

    // MCP 内置工具配置
    const mcpTools = ref([
      { toolId: 'ocr_recognize', name: 'OCR 文字识别', functionName: 'ocr_recognize', description: '识别图片中的文字内容（Google ML Kit）', enabled: true },
      { toolId: 'screenshot_parser_add_deal', name: '商品截图解析', functionName: 'screenshot_parser_add_deal', description: '解析商品截图信息并新增折扣记录', enabled: true },
      { toolId: 'deals_query', name: '折扣信息查询', functionName: 'deals_query', description: '查询折扣信息列表，支持平台、分类、关键词模糊搜索、价格范围、时间范围筛选和排序', enabled: true },
      { toolId: 'deals_aggregate', name: '折扣信息聚合统计', functionName: 'deals_aggregate', description: '聚合统计折扣信息，支持计数、求和、平均值、最小值、最大值等汇总方式', enabled: true },
      { toolId: 'deals_group', name: '折扣信息分组查询', functionName: 'deals_group', description: '分组查询折扣信息列表，支持按平台、分类、月份、年份分组统计', enabled: true },
    ]);

    function toggleMcpTool(toolId, enabled) {
      const t = mcpTools.value.find(x => x.toolId === toolId);
      if (t) t.enabled = enabled;
    }

    // 提示词数据
    const defaultPrompts = [
      { id: 1, name: '商品图片解析', content: '你是一个专业的电商图片解析引擎。分析输入图片中的所有商品信息，并严格按照指定 YAML 格式输出。', category: 'system' },
      { id: 2, name: '购物比价助手', content: '你是购物比价专家，擅长分析商品优惠、优惠券叠加、历史价格走势。', category: 'system' },
      { id: 3, name: '文案优化', content: '你是电商文案优化专家，擅长将促销文案改写得更吸引人。', category: 'system' },
    ];
    const prompts = ref([...defaultPrompts]);
    const promptEdit = ref(null);
    const promptForm = reactive({ name: '', content: '' });

    function addPrompt() {
      promptEdit.value = null;
      promptForm.name = '';
      promptForm.content = '';
    }

    function editPrompt(p) {
      promptEdit.value = p;
      promptForm.name = p.name;
      promptForm.content = p.content;
    }

    function savePrompt() {
      const name = promptForm.name.trim();
      const content = promptForm.content.trim();
      if (!name || !content) return;
      if (promptEdit.value) {
        promptEdit.value.name = name;
        promptEdit.value.content = content;
      } else {
        prompts.value.push({ id: Date.now(), name, content, category: 'custom' });
      }
      promptEdit.value = null;
      showToast('提示词已保存');
    }

    function deletePrompt(p) {
      prompts.value = prompts.value.filter(x => x.id !== p.id);
      showToast('已删除');
    }

    function copyPromptContent(p) {
      navigator.clipboard?.writeText(p.content).then(() => showToast('已复制')).catch(() => showToast('复制失败'));
    }

    // AI 服务商管理
    const aiProviders = ref([
      { id: 'p1', name: 'DeepSeek', protocol: 'openai', baseUrl: 'https://api.deepseek.com/v1', apiKey: '', model: 'deepseek-chat', agentId: 'default', temperature: 0.7, maxTokens: 2048, isActive: true },
    ]);
    const aiProviderEdit = ref(null);
    const aiProviderForm = reactive({ name: '', protocol: 'openai', baseUrl: '', apiKey: '', model: '', agentId: 'default', temperature: 0.7, maxTokens: 2048 });
    const aiModelList = ref([]);
    const aiModelListLoading = ref(false);

    function addAiProvider() {
      aiProviderEdit.value = null;
      Object.assign(aiProviderForm, { name: '', protocol: 'openai', baseUrl: '', apiKey: '', model: '', agentId: 'default', temperature: 0.7, maxTokens: 2048 });
    }

    function editAiProvider(p) {
      aiProviderEdit.value = p;
      Object.assign(aiProviderForm, { ...p });
    }

    function saveAiProvider() {
      const name = aiProviderForm.name.trim();
      if (!name) return;
      if (aiProviderEdit.value) {
        Object.assign(aiProviderEdit.value, { ...aiProviderForm });
      } else {
        aiProviders.value.push({ id: 'p_' + Date.now(), ...aiProviderForm, isActive: false });
      }
      aiProviderEdit.value = null;
      showToast('服务商已保存');
    }

    function deleteAiProvider(p) {
      aiProviders.value = aiProviders.value.filter(x => x.id !== p.id);
      showToast('已删除');
    }

    function setActiveProvider(p) {
      aiProviders.value.forEach(x => x.isActive = false);
      p.isActive = true;
      // 同步到 aiChat 设置
      Object.assign(settings.aiChat, {
        providerPreset: 'custom',
        protocol: p.protocol,
        apiKey: p.apiKey,
        baseUrl: p.baseUrl,
        model: p.model,
        agentId: p.agentId,
        temperature: p.temperature,
        maxTokens: p.maxTokens,
      });
      saveSettings();
      showToast(`已切换至 ${p.name}`);
    }

    async function fetchAiModels() {
      const baseUrl = aiProviderForm.baseUrl;
      const apiKey = aiProviderForm.apiKey;
      if (!baseUrl || !apiKey) {
        showToast('请先填写 Base URL 和 API Key');
        return;
      }
      aiModelListLoading.value = true;
      aiModelList.value = [];
      // 模拟延迟
      await new Promise(r => setTimeout(r, 800));
      // 模拟模型列表
      aiModelList.value = [
        'gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo',
        'claude-3-5-sonnet-20241022', 'claude-3-opus-20240229',
        'deepseek-chat', 'deepseek-coder',
        'Qwen/Qwen2.5-72B-Instruct', 'Qwen/Qwen2.5-7B-Instruct',
      ];
      aiModelListLoading.value = false;
    }

    function selectAiModel(model) {
      aiProviderForm.model = model;
      aiModelList.value = [];
    }

    const backupHistory = [
      { name: 'zheduoduo_backup_20260607.zip', date: '2026-06-07 09:30', size: '128 KB' },
      { name: 'zheduoduo_backup_20260601.zip', date: '2026-06-01 18:00', size: '96 KB' },
    ];

    const form = reactive(emptyForm());
    const formMode = ref('yaml');
    const yamlInput = ref('');
    const yamlError = ref('');
    const yamlParsed = ref(false);
    const imageDownloading = ref(false);
    const imageInput = ref(null);
    const visualOptions = [
      { value: 'none', label: '无' },
      { value: 'image', label: '图片' },
      { value: 'ascii', label: 'ASCII' },
    ];

    function emptyForm() {
      return {
        title: '', currentPrice: null, originalPrice: null, currentDisplayPrice: null,
        platform: '京东', category: '其他', logistics: '', currency: '¥',
        link: '', tagsStr: '', promotionsStr: '', note: '',
        visualType: 'none', image: '', imageUrl: '', asciiArt: '', imageMeta: null,
        coupons: [], sales: null,
      };
    }

    function emptyCoupon() {
      return { count: 1, source: '', strength: '', note: '' };
    }

    function formatSize(bytes) {
      if (bytes < 1024) return bytes + ' B';
      if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(0) + ' KB';
      return (bytes / 1024 / 1024).toFixed(1) + ' MB';
    }

    function visualBadgeText(deal) {
      if (!deal) return '无图';
      if (deal.visualType === 'image' && deal.image) return '有图';
      if (deal.visualType === 'ascii' && deal.asciiArt) return 'ASCII';
      return '无图';
    }

    function visualBadgeIcon(deal) {
      if (deal?.visualType === 'image' && deal?.image) return 'fa-solid fa-image';
      if (deal?.visualType === 'ascii' && deal?.asciiArt) return 'fa-solid fa-terminal';
      return 'fa-regular fa-image';
    }

    function visualBadgeClass(deal) {
      if (deal?.visualType === 'image' && deal?.image) return 'bg-blue-500/10 text-blue-600';
      if (deal?.visualType === 'ascii' && deal?.asciiArt) return 'bg-purple-500/10 text-purple-600';
      return 'bg-surface-2 text-ink-muted';
    }

    function migrateDeal(d) {
      const hasDiscount = d.originalPrice && d.originalPrice > d.currentPrice;
      const calcDiscount = hasDiscount ? (d.currentPrice / d.originalPrice * 10).toFixed(1) + '折' : '';
      return {
        ...emptyForm(),
        ...d,
        visualType: d.visualType || (d.image ? 'image' : 'none'),
        coupons: d.coupons || [],
        promotions: d.promotions || [],
        tags: d.tags || [],
        sales: d.sales || null,
        logistics: d.logistics || '',
        currentDisplayPrice: d.currentDisplayPrice ?? null,
        asciiArt: d.asciiArt || '',
        image: d.visualType === 'none' ? '' : (d.image || ''),
        isLowestPrice: d.isLowestPrice ?? 0,
        discount: d.discount || calcDiscount,
      };
    }

    function loadDeals() {
      try {
        const saved = localStorage.getItem('zdd_deals');
        const list = saved ? JSON.parse(saved) : [...SAMPLE_DEALS];
        return list.map(migrateDeal);
      } catch { return SAMPLE_DEALS.map(migrateDeal); }
    }

    function loadSettings() {
      try {
        const saved = localStorage.getItem('zdd_settings');
        const merged = saved ? { ...defaultSettings(), ...JSON.parse(saved) } : defaultSettings();
        const w = merged.cloud?.webdav || {};
        if (!w.provider) {
          w.provider = w.url?.includes('jianguoyun') ? 'jianguoyun' : (w.url ? 'custom' : 'jianguoyun');
        }
        if (!w.url && w.provider !== 'custom') applyWebdavPreset(w, w.provider);
        if (w.autoSync == null) w.autoSync = false;
        // 兼容旧版 simple 模式 → 改为 grid
        if (merged.listDisplayMode === 'simple') merged.listDisplayMode = 'grid';
        // 恢复 AI 对话独立设置
        const chat = loadChatSettings();
        merged.aiChat = { ...defaultChatSettings(), ...merged.aiChat, ...chat };
        return merged;
      } catch { return defaultSettings(); }
    }

    function snapshotWebdav() {
      const w = settings.cloud.webdav;
      return JSON.stringify({ provider: w.provider, url: w.url, username: w.username, password: w.password, path: w.path, enabled: w.enabled, autoSync: w.autoSync });
    }

    const webdavDirty = computed(() => snapshotWebdav() !== webdavSavedSnapshot.value);
    const webdavPreset = computed(() => getWebdavPreset(settings.cloud.webdav.provider));
    const webdavLastSyncText = computed(() => {
      const t = settings.cloud.webdav.lastSyncAt;
      if (!t) return '尚未同步';
      try {
        return new Date(t).toLocaleString('zh-CN', { hour12: false });
      } catch { return t; }
    });

    function refreshWebdavSnapshot() {
      webdavSavedSnapshot.value = snapshotWebdav();
    }

    function setWebdavProvider(id) {
      applyWebdavPreset(settings.cloud.webdav, id);
      showToast(id === 'custom' ? '已切换至自定义' : `已应用 ${getWebdavPreset(id).name} 预设`);
    }

    function saveWebdavConfig() {
      saveSettings();
      refreshWebdavSnapshot();
      showToast('WebDAV 配置已保存');
    }

    function testWebdavConnection() {
      const w = settings.cloud.webdav;
      if (!w.url || !w.username) { showToast('请填写服务器地址和账户'); return; }
      showToast('连接测试成功');
    }

    function toggleWebdavAutoSync() {
      settings.cloud.webdav.autoSync = !settings.cloud.webdav.autoSync;
      saveSettings();
      refreshWebdavSnapshot();
    }

    // 通用同步：获取当前启用的云提供商
    function getActiveCloudProvider() {
      for (const p of cloudProviders) {
        if (settings.cloud[p.id]?.enabled) return p;
      }
      return null;
    }

    // 增量同步（自动/手动触发）
    function cloudSyncIncremental(providerId) {
      const id = providerId || getActiveCloudProvider()?.id;
      if (!id || !settings.cloud[id]?.enabled) { showToast('请先启用同步'); return; }
      showToast('增量同步完成');
      settings.cloud[id].lastSyncAt = new Date().toISOString();
      saveSettings();
      if (id === 'webdav') refreshWebdavSnapshot();
    }

    // 全量上传确认 & 执行
    const fullUploadConfirm = ref(false);
    const fullUploadProvider = ref(null);
    function cloudFullUpload(providerId) {
      if (!settings.cloud[providerId]?.enabled) { showToast('请先启用同步'); return; }
      fullUploadProvider.value = providerId;
      fullUploadConfirm.value = true;
    }
    function doFullUpload() {
      const id = fullUploadProvider.value;
      fullUploadConfirm.value = false;
      showToast('全量上传完成');
      if (id) {
        settings.cloud[id].lastSyncAt = new Date().toISOString();
        saveSettings();
        if (id === 'webdav') refreshWebdavSnapshot();
      }
    }

    // 全量下载确认 & 执行
    const fullDownloadConfirm = ref(false);
    const fullDownloadProvider = ref(null);
    const cloudPendingChanges = ref(0);
    function cloudFullDownload(providerId) {
      if (!settings.cloud[providerId]?.enabled) { showToast('请先启用同步'); return; }
      fullDownloadProvider.value = providerId;
      cloudPendingChanges.value = 0; // 正式版查询 sync_changelog WHERE synced_at IS NULL
      fullDownloadConfirm.value = true;
    }
    function doFullDownload() {
      const id = fullDownloadProvider.value;
      fullDownloadConfirm.value = false;
      showToast('全量下载完成');
      if (id) {
        settings.cloud[id].lastSyncAt = new Date().toISOString();
        saveSettings();
        if (id === 'webdav') refreshWebdavSnapshot();
      }
    }

    function saveDeals() { localStorage.setItem('zdd_deals', JSON.stringify(deals.value)); }
    function saveSettings() { localStorage.setItem('zdd_settings', JSON.stringify(settings)); }

    function getTimeRangeCutoff(range) {
      if (range === 'all') return null;
      const months = { '1m': 1, '3m': 3, '6m': 6, '1y': 12 }[range] ?? 3;
      const cutoff = new Date();
      cutoff.setMonth(cutoff.getMonth() - months);
      cutoff.setHours(0, 0, 0, 0);
      return cutoff;
    }

    function isDealInTimeRange(deal, range) {
      const cutoff = getTimeRangeCutoff(range);
      if (!cutoff) return true;
      if (!deal?.createdAt) return true;
      const created = new Date(deal.createdAt);
      if (isNaN(created.getTime())) return true;
      created.setHours(0, 0, 0, 0);
      return created >= cutoff;
    }

    function setFilterTimeRange(range) {
      settings.filterTimeRange = range;
      saveSettings();
    }

    const activeTimeRangeLabel = computed(() =>
      timeRangeOptions.find(t => t.value === settings.filterTimeRange)?.label || '最近三个月'
    );

    const aiEmbedUrl = computed(() => resolveAiUrl(settings));
    const aiProviderName = computed(() => resolveAiName(settings));
    const aiSessionInfo = computed(() => loadAiSession(settings.aiProvider));

    function persistAiSession(increment = false) {
      if (!settings.aiPersistSession) return;
      saveAiSession(settings.aiProvider, {
        embedUrl: aiEmbedUrl.value,
        lastVisited: new Date().toISOString(),
        persistEnabled: true,
        mode: 'webview',
        ...(increment ? { _incrementVisit: true } : {}),
      });
    }

    function refreshAiWebView() {
      clearTimeout(aiRefreshTimer);
      aiWebViewRefreshing.value = true;
      aiRefreshTimer = setTimeout(() => {
        aiWebViewRefreshing.value = false;
        persistAiSession(true);
        showToast('页面已刷新');
      }, 800);
    }

    function openAiInBrowser() {
      window.open(aiEmbedUrl.value, '_blank', 'noopener,noreferrer');
      persistAiSession(true);
      showToast(`已在浏览器打开 ${aiProviderName.value}`);
    }

    function onAiTabEnter() {
      persistAiSession(false);
    }

    function setAiProvider(id) {
      settings.aiProvider = id;
      saveSettings();
      showToast(id === 'custom' ? '已切换至自定义地址' : `已切换至 ${getProvider(id).name}`);
    }

    function saveAiCustomUrl() {
      saveSettings();
      if (settings.aiProvider === 'custom' && settings.aiCustomUrl) {
        showToast('自定义地址已保存');
      }
    }

    function toggleAiPersistSession() {
      settings.aiPersistSession = !settings.aiPersistSession;
      saveSettings();
      if (settings.aiPersistSession) persistAiSession();
      showToast(settings.aiPersistSession ? '已开启会话持久化' : '已关闭会话持久化');
    }

    function resetAiSession() {
      clearAiSession(settings.aiProvider);
      showToast('已清除本地会话记录');
    }

    function copyAiPrompt() {
      const text = settings.aiPromptPrefix || '';
      if (!text) { showToast('请先在设置中配置提示词前缀'); return; }
      navigator.clipboard?.writeText(text).then(() => showToast('提示词已复制')).catch(() => showToast('复制失败'));
    }

    function resetAiPrompt() {
      settings.aiPromptPrefix = DEFAULT_AI_PROMPT;
      saveSettings();
      showToast('已恢复默认提示词');
    }

    function exportAiSessionBackup() {
      const blob = new Blob([exportAiSessionsJson()], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `zheduoduo_ai_session_${new Date().toISOString().slice(0, 10)}.json`;
      a.click();
      URL.revokeObjectURL(url);
      showToast('AI 会话备份已导出');
    }

    function importAiSessionBackup() {
      aiSessionInput.value?.click();
    }

    function handleAiSessionImport(e) {
      const file = e.target.files?.[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = () => {
        try {
          importAiSessionsJson(reader.result);
          showToast('AI 会话备份已导入');
        } catch {
          showToast('导入失败：文件格式无效');
        }
        e.target.value = '';
      };
      reader.readAsText(file);
    }

    watch(deals, saveDeals, { deep: true });
    watch(activeTab, (tab) => { if (tab === 1 && currentScreen.value === 'list') onAiTabEnter(); });
    onMounted(() => {
      sortBy.value = settings.defaultSort;
      if (!settings.filterTimeRange) settings.filterTimeRange = '3m';
      if (!settings.aiProvider) settings.aiProvider = 'deepseek';
      if (settings.aiPersistSession == null) settings.aiPersistSession = true;
      refreshWebdavSnapshot();
      // 初始化至少一个对话
      if (!chatSessions.value.length) startNewChat();
      else if (!currentChatSessionId.value) currentChatSessionId.value = chatSessions.value[0].id;
    });

    const couponDealsCount = computed(() => deals.value.filter(d => d.coupons?.length > 0).length);

    const filteredDeals = computed(() => {
      let list = [...deals.value];
      if (activeQuickFilter.value === 'hasCoupon') list = list.filter(d => d.coupons?.length > 0);
      if (activeQuickFilter.value === 'hasImage') list = list.filter(d => d.visualType === 'image' && d.image);
      if (activeQuickFilter.value === 'digital') list = list.filter(d => d.category === '数码');
      if (filterPlatform.value !== '全部') list = list.filter(d => d.platform === filterPlatform.value);
      list = list.filter(d => isDealInTimeRange(d, settings.filterTimeRange));
      list.sort((a, b) => {
        switch (sortBy.value) {
          case 'price-asc': return a.currentPrice - b.currentPrice;
          case 'price-desc': return b.currentPrice - a.currentPrice;
          case 'discount-desc': return (a.currentPrice / (a.originalPrice || 1)) - (b.currentPrice / (b.originalPrice || 1));
          case 'coupon-desc': return (b.coupons?.length || 0) - (a.coupons?.length || 0);
          default: return new Date(b.createdAt) - new Date(a.createdAt);
        }
      });
      return list;
    });

    const searchResults = computed(() => {
      const q = searchQuery.value.trim().toLowerCase();
      if (!q) return [];
      return deals.value.filter(d =>
        d.title.toLowerCase().includes(q) ||
        d.platform.toLowerCase().includes(q) ||
        (d.tags || []).some(t => t.toLowerCase().includes(q)) ||
        d.category.toLowerCase().includes(q) ||
        (d.coupons || []).some(c => [c.source, c.strength, c.note].join(' ').toLowerCase().includes(q)) ||
        (d.promotions || []).some(p => String(p).toLowerCase().includes(q)) ||
        (d.logistics || '').toLowerCase().includes(q)
      );
    });

    const screenLabels = {
      list: '清单首页', search: '搜索', detail: '优惠详情', form: '新建/编辑',
      backup: '本地备份', 'cloud-sync': '云同步', 'cloud-webdav': 'WebDAV', 'cloud-cos': '腾讯云COS', 'cloud-oss': '阿里云OSS', settings: '系统设置',
      'ai-settings': 'AI 设置', 'mcp-management': 'MCP 工具管理', 'prompts': '提示词管理',
    };
    const screenLabel = computed(() => {
      if (currentScreen.value !== 'list') return screenLabels[currentScreen.value] || currentScreen.value;
      const tabNames = ['清单首页', 'AI 助手', '我的'];
      return tabNames[activeTab.value] || '清单';
    });

    function goTo(screen) {
      screenHistory.value.push({ screen: currentScreen.value, tab: activeTab.value });
      currentScreen.value = screen;
      if (screen === 'search') nextTick(() => searchInput.value?.focus());
    }

    function goBack() {
      const prev = screenHistory.value.pop();
      if (prev) {
        currentScreen.value = prev.screen;
        activeTab.value = prev.tab;
      } else {
        currentScreen.value = 'list';
      }
    }

    function switchTab(i) {
      activeTab.value = i;
      currentScreen.value = 'list';
      screenHistory.value = [];
      if (i === 1) onAiTabEnter();
    }

    function toggleQuickFilter(key) { activeQuickFilter.value = key; }

    function openDealDetail(deal) {
      selectedDeal.value = deal;
      goTo('detail');
    }

    function openDealForm(deal = null) {
      editingDeal.value = deal;
      yamlError.value = '';
      yamlParsed.value = false;
      yamlInput.value = '';
      if (deal) {
        formMode.value = 'manual';
        Object.assign(form, {
          ...emptyForm(), ...deal,
          tagsStr: (deal.tags || []).join(', '),
          promotionsStr: (deal.promotions || []).join('\n'),
          imageUrl: deal.imageMeta?.sourceUrl || '',
          coupons: (deal.coupons || []).map(c => ({ ...c })),
          sales: deal.sales ? { ...deal.sales } : null,
        });
      } else {
        formMode.value = 'yaml';
        Object.assign(form, emptyForm());
      }
      goTo('form');
    }

    function fillYamlExample() {
      yamlInput.value = YAML_EXAMPLE;
    }

    function applyParsedData(normalized) {
      Object.assign(form, {
        title: normalized.title || '',
        currentPrice: normalized.currentPrice,
        originalPrice: normalized.originalPrice,
        currentDisplayPrice: normalized.currentDisplayPrice,
        currency: normalized.currency || '¥',
        platform: normalized.platform || '京东',
        logistics: normalized.logistics || '',
        category: normalized.category || '其他',
        link: normalized.link || '',
        note: normalized.note || '',
        tagsStr: (normalized.tags || []).join(', '),
        promotionsStr: (normalized.promotions || []).join('\n'),
        coupons: (normalized.coupons || []).map(c => ({ ...c })),
        sales: normalized.sales ? { ...normalized.sales } : null,
        visualType: normalized.visualType || 'none',
        asciiArt: normalized.asciiArt || '',
        imageUrl: normalized.imageUrl || '',
        image: normalized.image || (normalized.visualType === 'image' ? form.image : ''),
        imageMeta: normalized.imageMeta || (normalized.visualType === 'image' ? form.imageMeta : null),
      });
      yamlParsed.value = true;
      formMode.value = 'manual';
    }

    async function applyImageFromUrl(url) {
      if (!url?.trim()) return false;
      imageDownloading.value = true;
      try {
        const { dataUrl, meta } = await fetchAndCompressImage(url.trim());
        form.image = dataUrl;
        form.visualType = 'image';
        form.imageMeta = {
          originalSize: formatBytes(meta.originalSize || 0),
          compressedSize: formatBytes(meta.compressedSize || 0),
          quality: meta.quality,
          sourceUrl: meta.sourceUrl,
        };
        showToast('图片已下载并压缩');
        return true;
      } catch (e) {
        showToast('图片下载失败：' + (e.message || '请检查 URL 或 CORS'));
        return false;
      } finally {
        imageDownloading.value = false;
      }
    }

    async function parseYaml() {
      yamlError.value = '';
      if (!yamlInput.value.trim()) { yamlError.value = '请输入 YAML 内容'; return false; }
      try {
        const raw = window.jsyaml.load(yamlInput.value);
        if (!raw || typeof raw !== 'object') { yamlError.value = 'YAML 格式无效'; return false; }
        const normalized = normalizeYamlData(raw);
        if (!normalized?.title) { yamlError.value = '缺少商品名称（product.title 或 title）'; return false; }
        if (normalized.currentPrice == null) { yamlError.value = '缺少到手价（prices.discounted_price 或 currentPrice）'; return false; }
        applyParsedData(normalized);
        if (normalized.imageUrl) await applyImageFromUrl(normalized.imageUrl);
        const promoCount = (normalized.promotions || []).length;
        const couponCount = (normalized.coupons || []).length;
        showToast(`解析成功：${promoCount} 项促销 → ${couponCount} 张券`);
        return true;
      } catch (e) {
        yamlError.value = '解析失败：' + (e.message || '格式错误');
        return false;
      }
    }

    function addCoupon() { form.coupons.push(emptyCoupon()); }
    function removeCoupon(i) { form.coupons.splice(i, 1); }

    async function handleImageUpload(e) {
      const file = e.target.files?.[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = async (ev) => {
        try {
          const { dataUrl, meta } = await compressDataUrl(ev.target.result);
          form.image = dataUrl;
          form.visualType = 'image';
          form.imageUrl = '';
          form.imageMeta = {
            originalSize: formatSize(file.size),
            compressedSize: formatBytes(meta.compressedSize || 0),
            quality: meta.quality,
          };
          showToast('图片已压缩保存');
        } catch {
          showToast('图片处理失败');
        }
      };
      reader.readAsDataURL(file);
      e.target.value = '';
    }

    function buildDealPayload() {
      const tags = form.tagsStr.split(/[,，]/).map(t => t.trim()).filter(Boolean);
      const discount = form.originalPrice ? (form.currentPrice / form.originalPrice * 10).toFixed(1) + '折' : '—';
      const payload = {
        title: form.title,
        currentPrice: form.currentPrice,
        originalPrice: form.originalPrice || null,
        currentDisplayPrice: form.currentDisplayPrice || null,
        currency: form.currency || '¥',
        platform: form.platform,
        logistics: form.logistics || '',
        category: form.category,
        link: form.link,
        note: form.note,
        tags,
        discount,
        promotions: form.promotionsStr.split('\n').map(s => s.trim()).filter(Boolean),
        sales: form.sales || null,
        coupons: form.coupons.filter(c => c.source || c.strength),
        visualType: form.visualType,
        image: form.visualType === 'image' ? form.image : '',
        asciiArt: form.visualType === 'ascii' ? form.asciiArt : '',
        imageMeta: form.visualType === 'image' ? form.imageMeta : null,
      };
      return payload;
    }

    async function saveDeal() {
      if (formMode.value === 'yaml' && !editingDeal.value && !yamlParsed.value) {
        const ok = await parseYaml();
        if (!ok) return;
      }
      if (!form.title || !form.currentPrice) { showToast('请填写商品名称和现价'); return; }
      const payload = buildDealPayload();
      if (editingDeal.value) {
        const idx = deals.value.findIndex(d => d.id === editingDeal.value.id);
        if (idx >= 0) deals.value[idx] = { ...editingDeal.value, ...payload };
      } else {
        deals.value.unshift({
          ...payload, id: Date.now(),
          createdAt: new Date().toISOString().slice(0, 10),
        });
      }
      showToast('保存成功');
      screenHistory.value.pop();
      currentScreen.value = 'list';
    }

    function confirmDelete(deal) { deleteConfirm.value = deal; }
    function doDelete() {
      deals.value = deals.value.filter(d => d.id !== deleteConfirm.value.id);
      deleteConfirm.value = null;
      if (currentScreen.value === 'detail') goBack();
      showToast('已删除');
    }

    function getSavingsAmount(deal) {
      if (!deal?.originalPrice || deal.currentPrice == null) return null;
      return Math.max(0, Number(deal.originalPrice) - Number(deal.currentPrice));
    }

    function savingsText(deal) {
      const amount = getSavingsAmount(deal);
      if (amount == null) return '—';
      const sym = settings.currency || '¥';
      return sym + (Number.isInteger(amount) ? amount : amount.toFixed(2));
    }

    function originalPriceText(deal) {
      if (deal?.originalPrice == null) return '—';
      const sym = settings.currency || '¥';
      const price = Number(deal.originalPrice);
      return sym + (Number.isInteger(price) ? price : price.toFixed(2));
    }

    function setListDisplayMode(mode) {
      settings.listDisplayMode = mode;
      saveSettings();
    }

    function toggleListDisplayMode() {
      const modes = ['normal', 'grid'];
      const idx = modes.indexOf(settings.listDisplayMode);
      const next = modes[(idx + 1) % modes.length];
      setListDisplayMode(next);
      showToast(next === 'grid' ? '卡片展示' : '列表展示');
    }

    function setTheme(t) { settings.theme = t; saveSettings(); }
    function toggleTheme() { setTheme(settings.theme === 'light' ? 'dark' : 'light'); }

    function showToast(msg) {
      toast.message = msg;
      toast.show = true;
      setTimeout(() => { toast.show = false; }, 2000);
    }

    function jumpToScreen(screen) {
      viewMode.value = 'interactive';
      if (screen.tab !== undefined) { activeTab.value = screen.tab; currentScreen.value = 'list'; }
      else { currentScreen.value = screen.id; screenHistory.value = [{ screen: 'list', tab: 2 }]; }
    }

    const overviewScreens = [
      { id: 'list', label: '① 清单首页', tab: 0, preview: buildListPreview() },
      { id: 'search', label: '② 搜索页', preview: buildSearchPreview() },
      { id: 'detail', label: '③ 优惠详情', preview: buildDetailPreview() },
      { id: 'form', label: '④ 新建/编辑', preview: buildFormPreview() },
      { id: 'ai', label: '⑤ AI 对话', tab: 1, preview: buildAiPreview() },
      { id: 'mine', label: '⑥ 我的', tab: 2, preview: buildMinePreview() },
      { id: 'backup', label: '⑦ 本地备份', preview: buildBackupPreview() },
      { id: 'cloud-sync', label: '⑧ 云同步', preview: buildCloudPreview() },
      { id: 'cloud-webdav', label: '⑨ WebDAV 配置', preview: buildConfigPreview('WebDAV') },
      { id: 'settings', label: '⑩ 系统设置', preview: buildSettingsPreview() },
    ];

    return {
      viewMode, activeTab, currentScreen, showTabBar, tabs, deals, settings, platforms, categories,
      quickFilters, activeQuickFilter, filterPlatform, sortBy, sortOptions, timeRangeOptions,
      activeTimeRangeLabel, setFilterTimeRange, showFilterSheet,
      filteredDeals, searchQuery, searchInput, searchHistory, searchResults,
      selectedDeal, editingDeal, form, deleteConfirm, toast,
      aiWebViewRefreshing, aiEmbedUrl, aiProviderName, aiSessionInfo,
      AI_PROVIDERS, aiSessionInput,
      cloudProviders, cloudConfigScreens, backupHistory, couponDealsCount,
      WEBDAV_PRESETS, webdavDirty, webdavPreset, webdavLastSyncText,
      setWebdavProvider, saveWebdavConfig, testWebdavConnection, toggleWebdavAutoSync,
      cloudSyncIncremental, cloudFullUpload, cloudFullDownload,
      fullUploadConfirm, doFullUpload, fullUploadProvider,
      fullDownloadConfirm, doFullDownload, fullDownloadProvider, cloudPendingChanges,
      overviewScreens, screenLabel,
      formMode, yamlInput, yamlError, yamlParsed, imageInput, imageDownloading, visualOptions,
      goTo, goBack, switchTab, toggleQuickFilter, openDealDetail, openDealForm, saveDeal,
      confirmDelete, doDelete, setTheme, toggleTheme, showToast, jumpToScreen, saveSettings,
      getSavingsAmount, savingsText, originalPriceText, setListDisplayMode, toggleListDisplayMode,
      visualBadgeText, visualBadgeIcon, visualBadgeClass,
      fillYamlExample, parseYaml, addCoupon, removeCoupon, handleImageUpload, applyImageFromUrl,
      refreshAiWebView, openAiInBrowser, onAiTabEnter, setAiProvider, saveAiCustomUrl, toggleAiPersistSession,
      resetAiSession, copyAiPrompt, resetAiPrompt, exportAiSessionBackup, importAiSessionBackup, handleAiSessionImport,
      // AI 对话
      chatSessions, currentChatSessionId, currentChatSession, chatInput, chatSending, chatShowSettings, chatScrollRef,
      AI_PROTOCOLS, AI_PROVIDERS_PRESETS, AI_AGENTS,
      ensureChatSession, selectChatSession, startNewChat, removeChatSession, sendChatMessage,
      saveAiChatSettings, exportChatBackup, importChatBackup, handleChatImport,
      applyProviderPreset,
      // MCP 工具
      mcpTools, toggleMcpTool,
      // 提示词
      prompts, promptEdit, promptForm, addPrompt, editPrompt, savePrompt, deletePrompt, copyPromptContent,
      // AI 服务商
      aiProviders, aiProviderEdit, aiProviderForm, aiModelList, aiModelListLoading,
      addAiProvider, editAiProvider, saveAiProvider, deleteAiProvider, setActiveProvider,
      fetchAiModels, selectAiModel,
    };
  },
}).mount('#app');

