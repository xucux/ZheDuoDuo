/** WebDAV 预设提供商 */
export const WEBDAV_PRESETS = [
  {
    id: 'jianguoyun',
    name: '坚果云',
    url: 'https://dav.jianguoyun.com/dav/',
    path: '/zheduoduo/',
    passwordPlaceholder: '应用密码（坚果云请使用「第三方应用密码」）',
    tip: '请在坚果云「安全选项」中生成「第三方应用密码」，不要使用登录密码。',
  },
  {
    id: 'nextcloud',
    name: 'Nextcloud',
    url: 'https://your-domain.com/remote.php/dav/files/USERNAME/',
    path: '/zheduoduo/',
    passwordPlaceholder: '应用专用密码或账户密码',
    tip: '地址中的 USERNAME 请替换为你的 Nextcloud 用户名。',
  },
  {
    id: 'synology',
    name: '群晖 NAS',
    url: 'https://your-nas.com:5006/',
    path: '/zheduoduo/',
    passwordPlaceholder: 'WebDAV 账户密码',
    tip: '请在 DSM 控制面板中启用 WebDAV HTTPS 服务，并确认端口（默认 5006）。',
  },
  {
    id: 'infinicloud',
    name: 'infiniCLOUD',
    url: 'https://dav.dropboxusercontent.com/',
    path: '/zheduoduo/',
    passwordPlaceholder: '应用密码',
    tip: '请在 infiniCLOUD 账户设置中创建 WebDAV 应用密码。',
  },
  {
    id: 'custom',
    name: '自定义',
    url: '',
    path: '/zheduoduo/',
    passwordPlaceholder: 'WebDAV 密码或应用专用密码',
    tip: '手动填写服务器地址与远程目录，适用于其他 WebDAV 服务。',
  },
];

export function getWebdavPreset(id) {
  return WEBDAV_PRESETS.find(p => p.id === id) || WEBDAV_PRESETS.find(p => p.id === 'custom');
}

export function applyWebdavPreset(webdav, presetId) {
  const preset = getWebdavPreset(presetId);
  webdav.provider = presetId;
  if (presetId !== 'custom') {
    webdav.url = preset.url;
    webdav.path = preset.path;
  }
  return preset;
}
