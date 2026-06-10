/** 将结构化 / 简写 YAML 统一为内部字段 */
export function normalizeYamlData(raw) {
  if (!raw || typeof raw !== 'object') return null;

  const isStructured = !!(raw.product || raw.prices || raw.promotions || raw.source || raw.sales);

  if (isStructured) {
    const product = raw.product || {};
    const prices = raw.prices || {};
    const source = raw.source || {};
    const sales = raw.sales || {};
    const promotions = Array.isArray(raw.promotions) ? raw.promotions : [];

    const title = product.title || product.name || '';
    const currentPrice = prices.discounted_price ?? prices.discountedPrice ?? prices.current_price ?? prices.currentPrice;
    const originalPrice = prices.original_price ?? prices.originalPrice;
    const currentDisplayPrice = prices.current_display_price ?? prices.currentDisplayPrice;
    const currency = prices.currency || 'CNY';
    const platform = source.platform || source.平台 || '京东';
    const logistics = source.logistics || source.物流 || '';
    const sold30Days = sales.sold_30_days ?? sales.sold30Days ?? sales.sold_30days ?? '';

    // 解析 promotions 自动拆分为标签和优惠券
    const { tags: autoTags, coupons: autoCoupons } = parsePromotions(promotions);

    // 合并根级 tags（AI prompt 输出的 tags[]）
    const rootTags = Array.isArray(raw.tags) ? raw.tags.filter(t => typeof t === 'string' && t.trim()) : [];
    const tags = [...new Set([...autoTags, ...rootTags])];

    // 合并根级 coupons（AI prompt 输出的 coupons[]）
    const rootCoupons = Array.isArray(raw.coupons) ? raw.coupons.map(c => ({
      count: Number(c.count) || 1,
      source: c.source || '',
      strength: c.strength || '',
      note: c.note || '',
    })).filter(c => c.source || c.strength) : [];
    const coupons = [...autoCoupons, ...rootCoupons];

    // 备注：优先使用根级 note，否则自动拼接
    const noteParts = [];
    if (raw.note && typeof raw.note === 'string' && raw.note !== 'null') noteParts.push(raw.note);
    if (currentDisplayPrice != null && Number(currentDisplayPrice) !== Number(currentPrice)) {
      noteParts.push(`展示价 ¥${currentDisplayPrice}`);
    }
    if (sold30Days) noteParts.push(`30天销量 ${sold30Days}`);

    const visual = parseVisual(raw.visual || product.visual || raw);
    return {
      title,
      currentPrice: numOrNull(currentPrice),
      originalPrice: numOrNull(originalPrice),
      currentDisplayPrice: numOrNull(currentDisplayPrice),
      currency: currency === 'CNY' ? '¥' : currency,
      platform,
      logistics,
      sales: sold30Days ? { sold30Days: String(sold30Days) } : null,
      category: product.category || product.分类 || inferCategory(title),
      link: source.link || source.url || product.link || '',
      note: noteParts.join(' · ') || '',
      tags,
      coupons,
      promotions: promotions.map(p => typeof p === 'string' ? p : (p.text || p.name || p.strength || '')).filter(Boolean),
      createdAt: raw.create_time || raw.createTime || null,
      ...visual,
    };
  }

  // 简写兼容格式
  const tags = Array.isArray(raw.tags) ? raw.tags : (raw.tags ? String(raw.tags).split(/[,，]/).map(t => t.trim()).filter(Boolean) : []);
  const coupons = Array.isArray(raw.coupons) ? raw.coupons.map(c => ({
    count: Number(c.count) || 1,
    source: c.source || '',
    strength: c.strength || c.discount || '',
    note: c.note || '',
  })) : [];
  if (Array.isArray(raw.promotions) && !raw.coupons) {
    const parsed = parsePromotions(raw.promotions);
    tags.push(...parsed.tags.filter(t => !tags.includes(t)));
    coupons.push(...parsed.coupons);
  }

  const promoList = Array.isArray(raw.promotions)
    ? raw.promotions.map(p => typeof p === 'string' ? p : (p.text || p.name || p.strength || '')).filter(Boolean)
    : [];
  const visual = parseVisual(raw.visual || raw);

  return {
    title: raw.title || raw.name || raw.product?.title || '',
    currentPrice: numOrNull(raw.currentPrice ?? raw.price ?? raw.现价 ?? raw.prices?.discounted_price),
    originalPrice: numOrNull(raw.originalPrice ?? raw.原价 ?? raw.prices?.original_price),
    currentDisplayPrice: numOrNull(raw.currentDisplayPrice ?? raw.prices?.current_display_price),
    currency: raw.currency || '¥',
    platform: raw.platform || raw.平台 || raw.source?.platform || '京东',
    logistics: raw.logistics || raw.source?.logistics || '',
    sales: raw.sales || null,
    category: raw.category || raw.分类 || inferCategory(raw.title || ''),
    link: raw.link || raw.url || raw.链接 || '',
    note: raw.note || raw.备注 || '',
    tags,
    coupons,
    promotions: promoList,
    createdAt: raw.create_time || raw.createTime || null,
    ...visual,
  };
}

/** 解析 visual / image_url / ascii_art */
export function parseVisual(raw) {
  const visual = raw.visual || {};
  const imageUrl = visual.image_url || visual.imageUrl || raw.image_url || raw.imageUrl || '';
  const asciiArt = visual.ascii_art || visual.asciiArt || raw.ascii_art || raw.asciiArt || '';
  let visualType = visual.type || raw.visualType || raw.visual_type || 'none';
  if (imageUrl) visualType = 'image';
  else if (asciiArt) visualType = 'ascii';
  return {
    visualType,
    imageUrl: imageUrl || '',
    asciiArt: asciiArt || '',
    image: '', // 图片 URL 需异步下载后填充
  };
}

export function numOrNull(v) {
  if (v == null || v === '') return null;
  const n = Number(v);
  return isNaN(n) ? null : n;
}

export function inferCategory(title) {
  if (/浴室|马桶|淋浴|家居|柜|床|沙发|收纳/.test(title)) return '家居';
  if (/手机|电脑|耳机|数码|iPhone|索尼|Apple/.test(title)) return '数码';
  if (/吸尘|洗衣|空调|冰箱|家电|戴森/.test(title)) return '家电';
  if (/面霜|精华|美妆|护肤|口红/.test(title)) return '美妆';
  if (/坚果|零食|食品|牛奶/.test(title)) return '食品';
  if (/衣|裤|鞋|服饰/.test(title)) return '服饰';
  return '其他';
}

/** 将 promotions 字符串拆分为标签与优惠券 */
export function parsePromotions(promotions) {
  const tags = [];
  const coupons = [];
  const serviceKw = /免费安装|质保|保价|包邮|赠运|售后/;
  const discountKw = /券|减|折|直降|到手价|满|赠送|PLUS|立减|秒杀/i;

  for (const item of promotions) {
    const text = typeof item === 'string' ? item.trim() : (item.strength || item.text || item.name || '').trim();
    if (!text) continue;

    if (serviceKw.test(text) && !/减|折|券/.test(text)) {
      tags.push(text);
    } else if (discountKw.test(text)) {
      let source = '促销';
      if (/券|PLUS/i.test(text)) source = '优惠券';
      else if (/直降|官方/i.test(text)) source = '官方直降';
      else if (/满|赠送/i.test(text)) source = '满赠活动';
      coupons.push({ count: 1, source, strength: text, note: '' });
    } else {
      tags.push(text);
    }
  }
  return { tags, coupons };
}
