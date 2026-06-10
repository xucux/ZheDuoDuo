export const YAML_EXAMPLE = `product:
  title: "九牧（JOMOO）【超大收纳】智能浴室柜陶瓷一体盆洗脸盆柜组合"

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

visual:
  type: image
  image_url: "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800&fit=crop"
  # ascii_art: |
  #    ___
  #   |   |
  #   |___|`;

export const SAMPLE_DEALS = [
  { id: 1, title: 'Apple iPhone 15 Pro 256GB 钛金属', platform: '京东', originalPrice: 8999, currentPrice: 7499, discount: '8.3折', category: '数码', tags: ['百亿补贴', '限时'], visualType: 'image', image: 'https://images.unsplash.com/photo-1695048060311-9479d5f83f12?w=400&h=400&fit=crop', asciiArt: '', imageMeta: { originalSize: '1.2 MB', compressedSize: '86 KB', quality: 70 }, link: 'https://jd.com/example', note: '需凑单满3000减300', coupons: [{ count: 2, source: '平台满减', strength: '满3000减300', note: '自动领取' }, { count: 1, source: '店铺券', strength: '直减200', note: '' }], createdAt: '2026-06-01' },
  { id: 2, title: 'Sony WH-1000XM5 无线降噪耳机', platform: '天猫', originalPrice: 2499, currentPrice: 1899, discount: '7.6折', category: '数码', tags: ['618大促'], visualType: 'none', image: '', asciiArt: '', link: '', note: '', coupons: [{ count: 1, source: '品类券', strength: '满2000减300', note: '' }], createdAt: '2026-06-02' },
  { id: 3, title: '戴森 V15 Detect 无线吸尘器', platform: '拼多多', originalPrice: 4990, currentPrice: 3699, discount: '7.4折', category: '家电', tags: ['百亿补贴', '品牌'], visualType: 'ascii', image: '', asciiArt: '  ___\n /   \\\n| Dyson |\n \\___/', link: '', note: '官方旗舰店', coupons: [], createdAt: '2026-05-01' },
  { id: 4, title: 'La Mer 海蓝之谜精华面霜 30ml', platform: '抖音', originalPrice: 1680, currentPrice: 1280, discount: '7.6折', category: '美妆', tags: ['直播专享'], visualType: 'none', image: '', asciiArt: '', link: '', note: '', coupons: [{ count: 3, source: '直播间', strength: '买二送一', note: '限时' }], createdAt: '2026-06-05' },
  { id: 5, title: '三只松鼠坚果大礼包 1500g', platform: '淘宝', originalPrice: 128, currentPrice: 69, discount: '5.4折', category: '食品', tags: ['凑单'], visualType: 'image', image: 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=400&h=400&fit=crop', asciiArt: '', imageMeta: { originalSize: '890 KB', compressedSize: '62 KB', quality: 70 }, link: '', note: '叠加满减更优惠', coupons: [{ count: 1, source: '跨店满减', strength: '满99减10', note: '' }], createdAt: '2026-06-06' },
  { id: 6, title: '九牧（JOMOO）【超大收纳】智能浴室柜陶瓷一体盆洗脸盆柜组合', platform: '京东', originalPrice: 1629, currentPrice: 1068, currentDisplayPrice: 1492.25, discount: '6.6折', category: '家居', tags: ['免费安装', '9年质保', '保价618'], visualType: 'none', image: '', asciiArt: '', link: '', note: '展示价 ¥1492.25 · 30天销量 >1000', logistics: '京东物流', sales: { sold30Days: '>1000' }, promotions: ['PLUS券后预计到手价1068元', '领券再减15%', '官方直降5%', '免费安装', '9年质保', '保价618', '满额赠送价值199元角阀套装'], coupons: [{ count: 1, source: '优惠券', strength: 'PLUS券后预计到手价1068元', note: '' }, { count: 1, source: '优惠券', strength: '领券再减15%', note: '' }, { count: 1, source: '官方直降', strength: '官方直降5%', note: '' }, { count: 1, source: '满赠活动', strength: '满额赠送价值199元角阀套装', note: '' }], createdAt: '2026-06-07' },
];
