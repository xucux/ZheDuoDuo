/** AI 内嵌页会话元数据本地存储（Cookie 由浏览器/WebView 分区维护，此处备份可导出配置与访问记录） */
const SESSION_KEY = 'zdd_ai_session';

export const AI_PROVIDERS = [
  { id: 'deepseek', name: 'DeepSeek', url: 'https://chat.deepseek.com/', desc: '默认推荐' },
  { id: 'chatgpt', name: 'ChatGPT', url: 'https://chatgpt.com', desc: 'OpenAI' },
  { id: 'custom', name: '自定义', url: '', desc: '自定义 WebView 地址' },
];

export function getProvider(id) {
  return AI_PROVIDERS.find(p => p.id === id) || AI_PROVIDERS[0];
}

export function resolveAiUrl(settings) {
  if (settings?.aiProvider === 'custom') {
    const url = (settings.aiCustomUrl || '').trim();
    if (!url) return 'https://chat.deepseek.com/';
    return /^https?:\/\//i.test(url) ? url : `https://${url}`;
  }
  return getProvider(settings?.aiProvider).url;
}

export function resolveAiName(settings) {
  if (settings?.aiProvider === 'custom') {
    const url = resolveAiUrl(settings);
    try { return new URL(url).hostname; } catch { return '自定义 AI'; }
  }
  return getProvider(settings?.aiProvider).name;
}

export function loadAllAiSessions() {
  try {
    return JSON.parse(localStorage.getItem(SESSION_KEY) || '{}');
  } catch {
    return {};
  }
}

export function loadAiSession(providerId) {
  return loadAllAiSessions()[providerId] || null;
}

export function saveAiSession(providerId, patch) {
  const all = loadAllAiSessions();
  const prev = all[providerId] || { providerId, visitCount: 0 };
  all[providerId] = {
    ...prev,
    ...patch,
    providerId,
    visitCount: (prev.visitCount || 0) + (patch._incrementVisit ? 1 : 0),
    updatedAt: new Date().toISOString(),
  };
  delete all[providerId]._incrementVisit;
  localStorage.setItem(SESSION_KEY, JSON.stringify(all));
  return all[providerId];
}

export function clearAiSession(providerId) {
  const all = loadAllAiSessions();
  delete all[providerId];
  localStorage.setItem(SESSION_KEY, JSON.stringify(all));
}

export function clearAllAiSessions() {
  localStorage.removeItem(SESSION_KEY);
}

export function exportAiSessionsJson() {
  return JSON.stringify({
    version: 1,
    exportedAt: new Date().toISOString(),
    sessions: loadAllAiSessions(),
  }, null, 2);
}

export function importAiSessionsJson(jsonText) {
  const data = JSON.parse(jsonText);
  const sessions = data.sessions || data;
  if (typeof sessions !== 'object') throw new Error('无效的会话备份格式');
  localStorage.setItem(SESSION_KEY, JSON.stringify(sessions));
  return sessions;
}
