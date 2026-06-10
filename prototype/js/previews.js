export function buildListPreview() {
  return `<div style="background:var(--bg,#F2F3F5);height:100%;font-family:sans-serif">
    <div style="padding:12px 16px;background:#fff;border-bottom:1px solid #eee">
      <div style="display:flex;justify-content:space-between;align-items:center">
        <span style="font-size:18px;font-weight:700">优惠清单</span>
        <span style="color:#666"><i class="fa-solid fa-magnifying-glass"></i> <i class="fa-solid fa-sliders"></i></span>
      </div>
      <div style="display:flex;gap:8px;margin-top:10px">
        <span style="background:#46C01B;color:#fff;padding:4px 12px;border-radius:20px;font-size:11px">全部</span>
        <span style="background:#f0f0f0;padding:4px 12px;border-radius:20px;font-size:11px;color:#666">有优惠券</span>
      </div>
    </div>
    <div style="padding:12px">
      <div style="background:#fff;border-radius:16px;padding:12px;margin-bottom:10px">
        <div style="display:flex;justify-content:space-between"><p style="font-size:13px;font-weight:600;margin:0">iPhone 15 Pro 256GB</p><span style="font-size:10px;background:#dbeafe;color:#2563eb;padding:2px 6px;border-radius:4px">有图</span></div>
        <p style="color:#46C01B;font-weight:700;font-size:16px;margin:8px 0 0">¥7499 <span style="color:#999;font-size:11px;text-decoration:line-through">¥8999</span> <span style="font-size:10px;background:#fef3c7;color:#d97706;padding:2px 6px;border-radius:4px">2张券</span></p>
      </div>
    </div>
  </div>`;
}
export function buildSearchPreview() {
  return `<div style="background:var(--bg);height:100%;padding:16px;font-family:sans-serif">
    <div style="display:flex;gap:8px;align-items:center;margin-bottom:16px">
      <i class="fa-solid fa-arrow-left" style="color:#666"></i>
      <div style="flex:1;background:#f0f0f0;border-radius:12px;padding:10px 12px;font-size:13px;color:#999"><i class="fa-solid fa-magnifying-glass"></i> 搜索商品...</div>
    </div>
    <p style="font-size:11px;color:#999">最近搜索</p>
    <div style="display:flex;gap:8px;margin-top:8px"><span style="background:#f0f0f0;padding:6px 12px;border-radius:20px;font-size:11px">iPhone</span></div>
  </div>`;
}
export function buildDetailPreview() {
  return `<div style="height:100%;font-family:sans-serif;padding:16px">
    <p style="font-weight:600;margin-bottom:12px">优惠详情</p>
    <p style="font-size:16px;font-weight:700;margin:0">iPhone 15 Pro 256GB</p>
    <p style="color:#46C01B;font-size:28px;font-weight:700;margin:12px 0 0">¥7499</p>
    <div style="background:#fef3c7;border-radius:10px;padding:10px;margin-top:12px;font-size:12px"><b>平台满减</b> · 满3000减300 · 2张</div>
  </div>`;
}
export function buildFormPreview() {
  return `<div style="background:var(--bg);height:100%;font-family:sans-serif">
    <div style="padding:12px 16px;background:#fff;display:flex;justify-content:space-between;border-bottom:1px solid #eee">
      <span style="color:#666;font-size:13px">取消</span><span style="font-weight:600">新建优惠</span><span style="color:#46C01B;font-size:13px">保存</span>
    </div>
    <div style="padding:12px 16px;display:flex;gap:8px"><span style="flex:1;background:#46C01B;color:#fff;text-align:center;padding:8px;border-radius:10px;font-size:11px">YAML 解析</span><span style="flex:1;background:#f0f0f0;text-align:center;padding:8px;border-radius:10px;font-size:11px;color:#666">表单填写</span></div>
    <div style="padding:0 16px"><p style="font-size:11px;color:#999">YAML 数据 *</p>
    <div style="background:#fff;border:1px solid #eee;border-radius:12px;padding:12px;margin-top:6px;font-size:10px;color:#999;font-family:monospace">product:<br>&nbsp;&nbsp;title: "商品名"<br>prices:<br>&nbsp;&nbsp;discounted_price: 1068</div></div>
  </div>`;
}
export function buildAiPreview() {
  return `<div style="height:100%;font-family:sans-serif;background:#f5f5f5;display:flex;flex-direction:column">
    <div style="padding:8px 12px;background:#fff;border-bottom:1px solid #eee;display:flex;justify-content:space-between;align-items:center">
      <span style="font-size:12px;font-weight:600">AI 对话</span>
      <span style="font-size:10px;color:#999">OpenAI 兼容</span>
    </div>
    <div style="flex:1;padding:12px;display:flex;flex-direction:column;gap:8px;overflow-y:auto">
      <div style="align-self:flex-end;max-width:80%;background:#46C01B;color:#fff;padding:8px 10px;border-radius:12px;border-top-right-radius:4px;font-size:11px">你好，帮我看看这个优惠</div>
      <div style="align-self:flex-start;max-width:80%;background:#fff;padding:8px 10px;border-radius:12px;border-top-left-radius:4px;font-size:11px;color:#333">收到，这是一个模拟回复。</div>
    </div>
    <div style="padding:8px 12px;background:#fff;border-top:1px solid #eee;display:flex;gap:6px">
      <div style="flex:1;height:32px;background:#f5f5f5;border-radius:10px;border:1px solid #e8e8e8"></div>
      <div style="width:32px;height:32px;background:#46C01B;border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:10px">➤</div>
    </div>
  </div>`;
}
export function buildMinePreview() {
  return `<div style="height:100%;font-family:sans-serif;background:#f2f3f5">
    <div style="background:linear-gradient(135deg,#46C01B,#3AA816);padding:20px 16px;color:#fff">
      <p style="font-size:18px;font-weight:700;margin:0">折多多</p><p style="font-size:11px;opacity:.8">v1.0.0</p>
    </div>
    <div style="padding:12px 16px"><div style="background:#fff;border-radius:16px;padding:14px 16px;margin-bottom:8px"><i class="fa-solid fa-file-zipper" style="color:#3b82f6"></i> 本地备份</div>
    <div style="background:#fff;border-radius:16px;padding:14px 16px"><i class="fa-solid fa-cloud-arrow-up" style="color:#a855f7"></i> 云同步</div></div>
  </div>`;
}
export function buildBackupPreview() {
  return `<div style="background:var(--bg);height:100%;padding:16px;font-family:sans-serif">
    <p style="font-weight:600;margin-bottom:16px"><i class="fa-solid fa-arrow-left"></i> 本地备份</p>
    <div style="background:#fff;border-radius:16px;padding:16px;margin-bottom:12px"><span>自动备份</span></div>
    <div style="background:#fff;border-radius:16px;padding:16px"><i class="fa-solid fa-download" style="color:#46C01B"></i> 手动导出</div>
  </div>`;
}
export function buildCloudPreview() {
  return `<div style="background:var(--bg);height:100%;padding:16px;font-family:sans-serif">
    <p style="font-weight:600;margin-bottom:16px"><i class="fa-solid fa-arrow-left"></i> 云同步</p>
    <div style="background:#fff;border-radius:16px;padding:14px;margin-bottom:8px">WebDAV</div>
    <div style="background:#fff;border-radius:16px;padding:14px;margin-bottom:8px">腾讯云 COS</div>
    <div style="background:#fff;border-radius:16px;padding:14px">阿里云 OSS</div>
  </div>`;
}
export function buildConfigPreview(name) {
  const isWebdav = name === 'WebDAV';
  return `<div style="background:var(--bg);height:100%;padding:16px;font-family:sans-serif">
    <p style="font-weight:600;margin-bottom:12px"><i class="fa-solid fa-arrow-left"></i> ${name} 配置</p>
    ${isWebdav ? `<div style="display:flex;gap:6px;flex-wrap:wrap;margin-bottom:12px">
      <span style="font-size:10px;padding:4px 10px;border-radius:99px;background:#46C01B;color:#fff">坚果云</span>
      <span style="font-size:10px;padding:4px 10px;border-radius:99px;background:#f2f3f5;color:#666">Nextcloud</span>
      <span style="font-size:10px;padding:4px 10px;border-radius:99px;background:#f2f3f5;color:#666">自定义</span>
    </div>` : ''}
    <p style="font-size:11px;color:#999">服务器地址</p>
    <div style="background:#fff;border:1px solid #eee;border-radius:12px;padding:12px;margin:6px 0 12px;font-size:12px;color:#999">${isWebdav ? 'https://dav.jianguoyun.com/dav/' : 'https://...'}</div>
    <div style="background:#46C01B;color:#fff;text-align:center;padding:12px;border-radius:12px;margin-top:12px;font-size:13px">保存配置</div>
  </div>`;
}
export function buildSettingsPreview() {
  return `<div style="background:var(--bg);height:100%;padding:16px;font-family:sans-serif">
    <p style="font-weight:600;margin-bottom:16px"><i class="fa-solid fa-arrow-left"></i> 系统设置</p>
    <div style="background:#fff;border-radius:16px;padding:16px">
      <p style="font-size:11px;color:#999;margin-bottom:8px">外观主题</p>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px">
        <div style="border:2px solid #46C01B;border-radius:12px;padding:12px;text-align:center"><i class="fa-solid fa-sun" style="color:#fbbf24"></i><p style="font-size:12px;margin:4px 0 0">亮色</p></div>
        <div style="border:1px solid #eee;border-radius:12px;padding:12px;text-align:center;background:#1a1a1a;color:#fff"><i class="fa-solid fa-moon" style="color:#93c5fd"></i><p style="font-size:12px;margin:4px 0 0">暗色</p></div>
      </div>
    </div>
  </div>`;
}
