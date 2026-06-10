# 折多多 · YAML 与表单字段规范

新建优惠支持 **YAML 解析** 与 **手动表单** 两种录入方式，解析后进入同一套表单字段，最终保存为统一的 Deal 结构。

---

## 一、字段对照总表

| 业务含义 | 表单字段 | YAML（结构化） | YAML（简写） | 保存后 Deal 字段 |
|----------|----------|----------------|--------------|------------------|
| 商品名称 | `title` | `product.title` | `title` / `name` | `title` |
| 到手价 ✅ | `currentPrice` | `prices.discounted_price` | `currentPrice` / `price` / `现价` | `currentPrice` |
| 原价 | `originalPrice` | `prices.original_price` | `originalPrice` / `原价` | `originalPrice` |
| 展示价 | `currentDisplayPrice` | `prices.current_display_price` | `currentDisplayPrice` | `currentDisplayPrice` |
| 货币 | `currency` | `prices.currency`（CNY→¥） | `currency` | `currency` |
| 平台 | `platform` | `source.platform` | `platform` / `平台` | `platform` |
| 物流 | `logistics` | `source.logistics` | `logistics` | `logistics` |
| 分类 | `category` | `product.category` | `category` / `分类` | `category` |
| 购买链接 | `link` | `source.link` | `link` / `url` / `链接` | `link` |
| 标签 | `tagsStr`（逗号分隔） | 由 `promotions` 拆分 | `tags: []` | `tags[]` |
| **促销权益** | **`promotionsStr`（每行一项）** | **`promotions: []`** | **`promotions: []`** | **`promotions[]`** |
| 优惠券 | `coupons[]` | 由 `promotions` 拆分 | `coupons: []` | `coupons[]` |
| 30天销量 | — | `sales.sold_30_days` | `sales` | `sales.sold30Days` |
| 备注 | `note` | 自动拼接销量等 | `note` / `备注` | `note` |
| 视觉类型 | `visualType` | `visual.type` | `visualType` | `visualType` |
| 图片 URL | `imageUrl` | `visual.image_url` | `image_url` / `imageUrl` | 下载后 → `image` |
| 本地图片 | `image`（base64） | — | — | `image`（原型）/ `imagePath`（正式版） |
| ASCII 图 | `asciiArt` | `visual.ascii_art` | `ascii_art` / `asciiArt` | `asciiArt` |

✅ = 必填

---

## 二、促销权益（promotions）

### 是否支持？

**支持。** 促销权益贯穿 YAML 解析、表单编辑、详情展示全流程：

1. YAML 中 `promotions` 列表原样写入 `promotions[]`
2. 同时按规则拆分为 `tags[]` 与 `coupons[]`（便于列表筛选与券管理）
3. 表单「促销权益」文本框（每行一项）与 YAML 字段一一对应
4. 详情页单独展示「促销权益」区块，保留电商原文

### 自动拆分规则

| 类型 | 识别关键词 | 示例 |
|------|-----------|------|
| 标签 | 安装、质保、保价、包邮 | `免费安装`、`9年质保`、`保价618` |
| 优惠券 | 券、减、折、直降、到手价、满、赠送、PLUS | `领券再减15%`、`官方直降5%` |

优惠券自动填充：`source`（优惠券/官方直降/满赠活动/促销）、`strength`（原文）、`count`（默认 1）。

### 表单填写示例

```
PLUS券后预计到手价1068元
领券再减15%
官方直降5%
免费安装
9年质保
```

---

## 三、视觉内容（图片 / ASCII）

### YAML 写法

```yaml
visual:
  type: image          # none | image | ascii，可省略（由 image_url / ascii_art 推断）
  image_url: "https://example.com/product.jpg"
  ascii_art: |
     ___
    |   |
    |___|
```

简写（根级）：

```yaml
image_url: "https://..."
ascii_art: |
  /\_/\
 ( o.o )
```

### 处理流程

| 来源 | 行为 |
|------|------|
| YAML `image_url` | 解析后自动 **下载 → Canvas 压缩**（宽≤800，JPEG 70%）→ 填入 `form.image` |
| 表单「图片 URL」+ 下载压缩 | 同上，手动触发 |
| 表单本地选择 | FileReader → 压缩 → `form.image` |
| YAML / 表单 `ascii_art` | 设置 `visualType: ascii`，写入 `asciiArt` |

### 限制说明（原型）

- 远程图片受浏览器 **CORS** 限制，部分电商 CDN 可能下载失败，需改用手动上传或正式版原生下载
- 原型将压缩结果存为 **base64**；正式版见《数据持久化方案》— 存 `images/{id}.jpg` + `imagePath`

---

## 四、推荐 YAML 完整示例

```yaml
product:
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
  link: "https://..."

visual:
  type: image
  image_url: "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800&fit=crop"
  # ascii_art: |
  #    ___
  #   |   |
  #   |___|
```

---

## 五、简写兼容格式

```yaml
title: Apple iPhone 15 Pro 256GB
platform: 京东
category: 数码
originalPrice: 8999
currentPrice: 7499
promotions:
  - 百亿补贴
  - 满3000减300
tags: [百亿补贴, 限时]
image_url: https://example.com/iphone.jpg
ascii_art: |
  [ iPhone ]
link: https://jd.com/example
note: 备注
coupons:
  - count: 2
    source: 平台满减
    strength: 满3000减300
    note: 自动领取
```

---

## 六、解析后 Deal 结构

```typescript
interface Deal {
  id: number | string;
  title: string;
  currentPrice: number;
  originalPrice?: number;
  currentDisplayPrice?: number;
  currency: string;
  platform: string;
  logistics?: string;
  category: string;
  tags: string[];
  promotions: string[];       // 促销权益原文列表
  coupons: Coupon[];
  sales?: { sold30Days: string };
  note?: string;
  link?: string;
  visualType: 'none' | 'image' | 'ascii';
  image?: string;             // 原型 base64；正式版改为 imagePath
  asciiArt?: string;
  imageMeta?: {
    originalSize?: string;
    compressedSize?: string;
    quality?: number;
    sourceUrl?: string;
    width?: number;
    height?: number;
  };
  discount?: string;
  createdAt: string;
}

interface Coupon {
  count: number;
  source: string;
  strength: string;
  note?: string;
}
```

---

## 七、使用流程

1. 新建优惠 → 默认「YAML 解析」
2. 粘贴 YAML 或点击「填入示例」
3. 点击「解析并填充」→ 自动填充价格、促销权益、标签、优惠券、图片 URL（自动下载压缩）
4. 切换到手动表单核对，可编辑促销权益、优惠券、ASCII、本地图片
5. 保存

---

## 八、相关文档

- [数据持久化方案](./数据持久化方案.md) — SQLite 离线存储与云同步
- [数据库表设计](./数据库表设计.md) — 表结构与字段映射
- [产品规划与开发建议](./产品规划与开发建议.md) — 功能路线图
