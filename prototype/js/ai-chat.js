/** AI 对话：本地会话存储 + 模拟回复（原型演示） */
const CHAT_SESSION_KEY = 'zdd_ai_chat_sessions';
const CHAT_SETTINGS_KEY = 'zdd_ai_chat_settings';

export const AI_PROTOCOLS = [
  { id: 'openai', name: 'OpenAI 兼容', desc: '支持 /v1/chat/completions 的代理服务' },
  { id: 'claude', name: 'Claude 协议', desc: 'Anthropic Messages API' },
];

export const AI_PROVIDERS_PRESETS = [
  { id: 'deepseek', name: 'DeepSeek', protocol: 'openai', baseUrl: 'https://api.deepseek.com/v1', model: 'deepseek-chat' },
  { id: 'siliconflow', name: '硅基流动', protocol: 'openai', baseUrl: 'https://api.siliconflow.cn/v1', model: 'Qwen/Qwen2.5-72B-Instruct' },
  { id: 'openai', name: 'OpenAI', protocol: 'openai', baseUrl: 'https://api.openai.com/v1', model: 'gpt-4o' },
  { id: 'claude', name: 'Claude', protocol: 'claude', baseUrl: 'https://api.anthropic.com', model: 'claude-3-5-sonnet-20241022' },
  { id: 'custom', name: '自定义', protocol: 'openai', baseUrl: '', model: '' },
];

export const AI_AGENTS = [
  { id: 'default', name: '默认助手', prompt: '你是一个 helpful 的助手。' },
  { id: 'shopping', name: '购物参谋', prompt: '你是购物比价专家，擅长分析商品优惠、优惠券叠加、历史价格走势。' },
  { id: 'yaml', name: 'YAML 解析器', prompt: '你专注于把商品截图或文案解析成结构化 YAML 数据。' },
];

export function defaultChatSettings() {
  return {
    providerPreset: 'deepseek', // deepseek | siliconflow | openai | claude | custom
    protocol: 'openai', // openai | claude
    apiKey: '',
    baseUrl: '', // 如 https://api.deepseek.com/v1
    model: '',
    agentId: 'default',
    temperature: 0.7,
    maxTokens: 2048,
  };
}

export function applyProviderPreset(settings, presetId) {
  const p = AI_PROVIDERS_PRESETS.find(x => x.id === presetId);
  if (!p) return settings;
  return {
    ...settings,
    providerPreset: presetId,
    protocol: p.protocol,
    baseUrl: p.baseUrl,
    model: p.model,
  };
}

export function loadChatSettings() {
  try {
    const raw = localStorage.getItem(CHAT_SETTINGS_KEY);
    return raw ? { ...defaultChatSettings(), ...JSON.parse(raw) } : defaultChatSettings();
  } catch {
    return defaultChatSettings();
  }
}

export function saveChatSettings(settings) {
  localStorage.setItem(CHAT_SETTINGS_KEY, JSON.stringify(settings));
}

export function loadChatSessions() {
  try {
    return JSON.parse(localStorage.getItem(CHAT_SESSION_KEY) || '[]');
  } catch {
    return [];
  }
}

export function saveChatSessions(sessions) {
  localStorage.setItem(CHAT_SESSION_KEY, JSON.stringify(sessions));
}

export function createSession(title = '新对话') {
  const sessions = loadChatSessions();
  const session = {
    id: 's_' + Date.now(),
    title,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    messages: [],
  };
  sessions.unshift(session);
  saveChatSessions(sessions);
  return session;
}

export function getSession(sessionId) {
  return loadChatSessions().find(s => s.id === sessionId) || null;
}

export function updateSession(sessionId, patch) {
  const sessions = loadChatSessions();
  const idx = sessions.findIndex(s => s.id === sessionId);
  if (idx === -1) return null;
  sessions[idx] = { ...sessions[idx], ...patch, updatedAt: new Date().toISOString() };
  saveChatSessions(sessions);
  return sessions[idx];
}

export function addMessage(sessionId, role, content) {
  const sessions = loadChatSessions();
  const s = sessions.find(s => s.id === sessionId);
  if (!s) return null;
  s.messages.push({ id: 'm_' + Date.now(), role, content, createdAt: new Date().toISOString() });
  s.updatedAt = new Date().toISOString();
  if (s.messages.length === 1 && role === 'user') {
    // 自动根据第一条消息生成标题
    s.title = content.slice(0, 20) || '新对话';
  }
  saveChatSessions(sessions);
  return s;
}

export function deleteSession(sessionId) {
  const sessions = loadChatSessions().filter(s => s.id !== sessionId);
  saveChatSessions(sessions);
}

export function clearAllChatSessions() {
  localStorage.removeItem(CHAT_SESSION_KEY);
}

export function exportChatSessions() {
  return JSON.stringify({
    version: 1,
    exportedAt: new Date().toISOString(),
    sessions: loadChatSessions(),
  }, null, 2);
}

export function importChatSessions(jsonText) {
  const data = JSON.parse(jsonText);
  const sessions = data.sessions || data;
  if (!Array.isArray(sessions)) throw new Error('无效的会话格式');
  saveChatSessions(sessions);
  return sessions;
}

/** 模拟发送消息（原型演示用） */
export function mockSendMessage(content) {
  const replies = [
    '收到，这是一个模拟回复。正式版本将调用你配置的 API 进行真实对话。',
    '好的，我理解了。当前为原型演示，未接入真实 AI 服务。',
    '这是一个占位回复。你可以在 AI 设置中配置 OpenAI 兼容或 Claude 协议的 API Key。',
    '（模拟）根据你的描述，建议关注优惠券叠加和满减活动。',
  ];
  const reply = replies[Math.floor(Math.random() * replies.length)];
  return new Promise((resolve) => {
    setTimeout(() => resolve(reply), 600 + Math.random() * 800);
  });
}
