# 折多多 · YAML 与表单字段规范

新建优惠支持 **YAML 解析** 与 **手动表单** 两种录入方式，解析后进入同一套表单字段，最终保存为统一的 Deal 结构。

---

## 一、字段对照总表

| 业务含义 | 表单字段 | YAML（结构化） | YAML（简写） | 保存后 Deal 字段 |
|----------|----------|----------------|--------------|------------------|
| 商品名称 | `title` | `product.title` | `title` / `name` | `title` |
| 到手价 ✅ | `currentPrice` | `prices.discounted_price` | `currentPrice` / `price` / `现价` | `currentPrice` |
| 原价 | `originalPrice` | `prices.original_price` | `originalPrice` / `原价` | `originalPrice` |
| 展示价 | `currentDisplayPrice` | `prices.current_display_price` | `currentDisplayPrice` | `displayPrice` |
| 货币 | `currency` | `prices.currency`（CNY→¥） | `currency` | `currency` |
| 平台 | `platform` | `source.platform` | `platform` / `平台` | `platform` |
| 物流 | `logistics` | `source.logistics` | `logistics` | `logistics` |
| 分类 | `category` | `product.category` | `category` / `分类` | `category` |
| 购买链接 | `link` | `source.link` | `link` / `url` / `链接` | `link` |
| 折扣描述 | — | `discount` / `折扣` | `discount` | `discount` |
| 标签 | `tagsStr`（逗号分隔） | 由 `promotions` 拆分 | `tags: []` | `tags[]` |
| **促销权益** | **`promotionsStr`（每行一项）** | **`promotions: []`** | **`promotions: []`** | **`promotions[]`** |
| 优惠券 | `coupons[]` | 由 `promotions` 拆分 | `coupons: []` | `coupons[]` |
| 30天销量 | — | `sales.sold_30_days` | `sales` | `salesJson`（JSON 字符串） |
| 历史最低价 | — | — | — | `isLowestPrice`（0/1） |
| 来源信息 | — | `source.type` / `source.remark` | `sourceType` / `sourceRemark` | `sourceJson`（JSON 字符串） |
| 备注 | `note` | `note` / `备注` | `note` | `note` |
| 视觉类型 | `visualType` | `visual.type` | `visualType` | `visualType` |
| 图片 URL | `imageUrl` | `visual.image_url` | `image_url` / `imageUrl` | 下载后 → `deal_images.image_path` |
| ASCII 图 | `asciiArt` | `visual.ascii_art` | `ascii_art` / `asciiArt` | `asciiArt` |

✅ = 必填

### 系统字段（自动填充，YAML 无需填写）

| 字段 | 说明 |
|------|------|
| `id` | UUID，自动生成 |
| `revision` | 版本号，每次更新 +1，用于云同步冲突检测 |
| `deleted` | 软删除标记：0=正常，2=待确认删除 |
| `deletedAt` | 进入待删除状态的时间 |
| `deviceId` | 最后修改设备的 UUID |
| `createdAt` | 创建时间 |
| `updatedAt` | 更新时间 |

---

## 二、YAML 字段平铺详解

| YAML 属性路径 | 中文含义 | 字段类型 | 示例 | 规则描述 |
|--------------|---------|---------|------|---------|
| `created_at` | 创建时间 | `string` | ISO8601 格式 | 优惠记录时间，可以从图片名称或者图片元数据中获取，最后获取不到则用当前时间 |
| `product.title` | 商品名称 | `string` | `"Apple iPhone 15 Pro 12+512 白色"` | **必填**。商品的标题信息和规格信息 |
| `product.category` | 商品分类 | `string` | `"手机"` | 默认 `"其他"`。尽量避免使用大类型，而是小类型例如：数码大类下的手机、微单相机、米家智能家居、路由器、游戏机、五金、充电宝、充电头、单反相机，无人机，户外相机，3D打印机，墨水屏阅读器，英伟达显卡，AMD显卡，CPU，电脑主板，机械硬盘，固态硬盘，内存条等等 |
| `prices.discounted_price` | 实际购买到手价 | `number` | `5492.25` | **必填**。减去全部优惠后得到的价格，包括减去国家补贴 |
| `prices.original_price` | 原价 | `number` | `8999` | 原价就是商品在市场上的标价，例如手机发布价格5999 |
| `prices.current_display_price` | 展示价 | `number` | `7999` | 展示价格，可能等于原价，上架主动在原价的基础上，直接降价之后的价格，例如手机发布价格5999，促销时价格标为4999 |
| `prices.currency` | 货币 | `string` | `"¥"` | 默认 `"¥"`。`CNY`/`RMB`→`¥`，`USD`→`$`，`EUR`→`€`，`GBP`→`£`，`JPY`→`¥`，其余原样输出。回退根级 `currency` |
| `source.platform` | 来源平台 | `string` | `"京东"` | 默认 `"其他"`。一般可以参考的有京东，抖音，拼多多，淘宝，天猫，唯品会，快手，闲鱼，转转等 |
| `source.logistics` | 物流信息 | `string` | `"京东物流"` | 默认"包邮"，一般参考圆通，中通，顺丰，京东，韵达，极兔，中国邮政，免邮费等 |
| `source.link` | 购买链接 | `string` | `"https://jd.com/..."` | 回退根级 `link` / `url` / `链接` |
| `source.type` | 来源类型 | `string` | `"YAML导入"` | 回退根级 `sourceType` / `来源类型` |
| `source.remark` | 来源备注 | `string` | `"原始文件"` | 回退根级 `sourceRemark` / `来源备注` |
| `discount` | 折扣描述 | `string` | `"6.6折"` | 使用实际购买到手价和【原价or展示价格】自动计算 |
| `sales.sold_30_days` | 30天销量 | `string` | `">1000"` | 结构化格式键名可为 `sold_30_days` 或 `sold30Days`；回退根级 `sales`（字符串） |
| `visual.type` | 视觉类型 | `string` | `"ascii"` | 可选值 `none` / `image` / `ascii`。 |
| `visual.image_url` | ~~图片 URL~~ | `string` | `"https://.../product.jpg"                    | 无需填写                                                     |
| `visual.ascii_art` | ASCII 艺术图 | `string` | `"[ iPhone ]"` | 将商品主图转换成ascii图，转换成功则 `visualType = ascii`，若无法解析，则将`visual.type`置为none |
| `promotions` | 促销权益列表，不能超过15个 | `string[]` | `["免费安装", "领券再减15%","180天只换不修","1年质保","包邮","大促直降861元"]` | 字符串数组，主要是商品的促销信息、折扣优惠、服务特点 |
|`tags` | 自定义标签，3个或者4个，请勿重复语义化相近的词语 | `string[]` | `["退换免运费", "电脑主板"]` | 见【标签排除保留规则】【标签归一规则】 |
| `coupons[].count` | 券数量 | `number` | `2` | 默认 `1`。仅当显式提供 `coupons` 数组时有效 |
| `coupons[].source` | 券来源 | `string` | `"平台满减"` | 默认 `"促销"` |
| `coupons[].strength` | 优惠力度 | `string` | `"满3000减300"` | **必填子字段**。描述优惠具体内容 |
| `coupons[].note` | 券备注 | `string` | `"自动领取"` | 可选，补充说明 |
| `note` / `备注` | 备注 | `string` | `"需预约安装"` | 根级字段 |

> coupons 优惠券提取规则： 1、直接从正文中获取优惠券信息 2、从 `promotions` 中提取（含关键词：券、减、折、直降、到手价、满、赠送、PLUS），每项生成 `ParsedCoupon(source="促销", strength=原文, count=1)`。数字字段支持字符串清洗（自动去除非数字字符后解析）


#### 标签排除保留规则

1.1 促销类排除

促销、大促、限时、秒杀、历史低价、清仓、预售、现货、新品、新品首发、11.11、双11、618、春上新、七夕、情人节、元宵节、清凉节、国庆、新年、周年庆、闪电加补、超级爆款、即将卖完、库存紧张、限购、热卖榜、直降、立减、降价、折扣、优惠、7折、5折、78折、升级6折、满减、满1享、抢券、领券、需用券、红包抵扣、淘金币抵扣、省钱、换新优惠、换新补贴、白条免息、免息、免息分期、贴息、立减金、无门槛券、优惠券、平台券、券、月卡专享、PLUS、88VIP、买贵保障、买贵必赔、买贵赔双倍、降价补差、价保险、晒图有礼、晒图分享、分享有礼、赠品、赠镜框、送礼、好评、回头客、保障、补贴、消费券、平台补贴、官方补贴、最后一天

1.2 物流类排除

包邮、顺丰、顺丰包邮、免运费、运费险、退货运费险、24小时发货、现货急速发

1.3 通用排除

售后无忧、售后质保、售后保证、售后保障、售后、官方标配、套餐、5G、4G、百亿补贴、官方正品、店铺好评榜、榜单、7天无理由退货、7天无理由退换、正品、正品保障、正品保证、正品险、正品发票、品牌保障、品牌质保、品牌官方质保、品牌旗舰店、品牌授权、三包、三包承诺、全国联保、免费安装、免费退换、免费上门退换、分期付款、极速退款、未发货秒退、假一赔三、退货保障、退货宝、七天退换、7天无理由、15天无理由、无理由退货、先用后付、自营、京东自营、国行、全新未拆封、全新原装、全新盒装、全新散片、官方标配、中国芯、晚发必赔、发票、学生、自动、无线、高性价比、以旧换新、换新、送礼、好评、回头客、拼单、新客优惠、6核处理器、6核心12线程、盒装CPU

1.4 质保/保修类（仅排除 <3 年的）

质保、保修、一年质保、一年保修、一年联保、二年质保、两年质保、三年保修、保三年、店保、店铺保修、店保一年、官方质保

1.5 服务标签（保留，0-1 个）

| 标签 | 说明 |
|------|------|
| 国家补贴 | 政府/国家以旧换新补贴 |
| 政府补贴 | 地方政府补贴 |
| 退货包运费 | 退货免运费服务 |
| 价保 | 价格保护（含保价、大促价保、价保服务、7天价保、30天价保） |
| 退换免运费 | 退换货免运费 |
| 180天只换不修 | 180天质量问题换新 |
| 三年质保 | 3年质保服务 |
| 五年质保 | 5年质保服务（含5年保修） |
| 永久质保 | 永久质保服务 |

#### 标签归一规则

以下变体统一映射为标准标签：

| 原始变体 | 归一化为 |
|----------|----------|
| WiFi6 / Wi-Fi6 / WI-FI6 / wifi6 | WiFi6 |
| WiFi7 / Wi-Fi7 / WI-FI7 / wifi7 | WiFi7 |
| NVMe M.2 / M.2 NVMe / NVMe 存储 / NVMe SSD / NVMe PCIe3.0 | NVMe |
| Oculink接口 | OCuLink接口 |
| FDM技术 | FDM |
| CMR垂直式技术 | CMR技术 |
| 7200转高转速 | 7200转 |
| 4TB大容量 / 4TB容量 | 4TB |
| 16TB大容量 | 16TB |
| 14T大容量 / 14TB硬盘 | 14TB |
| 2TB容量 | 2TB |
| 工控主机 | 工控设备 |
| 技嘉主板 | 电脑主板 |
| 金属外壳 | 金属机身 |
| 无风扇散热 / 无风扇静音 | 被动散热 |
| i226 2.5G网卡 / i226四网口 / i226网卡 / i226 网卡 / i226 四网口 / i226网口 | i226 |
| 2.5G网口 | 2.5G |
| NAS/私有云 / NAS存储 | NAS |
| 3年质保 | 三年质保 |
| 2年质保 | 两年质保 |
| 多色打印套装 | 多色套装 |
| 国补 | 国家补贴 |
| 保价 | 价保 |
| 大促价保 | 价保 |
| 价保服务 | 价保 |
| N天价保（如7天价保、30天价保） | 价保 |
| 5年保修 | 五年质保 |
| 米家智能 / 米家 | 米家智能家居 |
| ThinkBook | 联想 |
| 16GB大显存 / 16GB显存 | 16GB显存 |
| 12GB大显存 / 12GB显存 | 12GB显存 |
| 独立显卡 / 国产游戏显卡 / 游戏显卡 / 显卡 | 显卡 |
| 投资金条 | 黄金 |
| 电暖毯 / 智能电热毯 | 电热毯 |
| ITX板型 / itx / Itx | ITX |
| ATX板型 / atx / Atx | ATX |
| 机壳 / 机盒 | 机箱 |
| 超薄款准系统 / xxx准系统 | 准系统 |
| AI加速 / AI算力 / AI设计 / AIxxx | AI |
| 电竞显卡 / 电竞路由器 / 电竞xxx | 电竞 |



---

## 三、促销权益（promotions）

### 是否支持？

**支持。** 促销权益贯穿 YAML 解析、表单编辑、详情展示全流程：

1. YAML 中 `promotions` 列表原样写入 `deal_promotions[]`
2. 同时按规则拆分为 `tags[]` 与 `coupons[]`（便于列表筛选与券管理）
3. 表单「促销权益」文本框（每行一项）与 YAML 字段一一对应
4. 详情页单独展示「促销权益」区块，保留电商原文

### 自动拆分规则

| 类型 | 识别关键词 | 示例 |
|------|-----------|------|
| 标签 | 安装、质保、保价、包邮、免邮、保修、保障 | `免费安装`、`9年质保`、`保价618` |
| 优惠券 | 券、减、折、直降、到手价、满、赠送、PLUS | `领券再减15%`、`官方直降5%` |

优惠券自动填充：`source`（促销）、`strength`（原文）、`count`（默认 1）。

### 表单填写示例

```
PLUS券后预计到手价1068元
领券再减15%
官方直降5%
免费安装
9年质保
```

---

## 四、视觉内容（图片 / ASCII）

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
| YAML `image_url` | 解析后自动 **下载 → 压缩** → 保存为本地文件，写入 `deal_images` 表 |
| 表单「图片 URL」+ 下载压缩 | 同上，手动触发 |
| 表单本地选择 | 选择图片 → 压缩（Android/iOS）/ 直接复制（Windows/Linux） → 保存到应用图片目录 |
| YAML / 表单 `ascii_art` | 设置 `visualType: ascii`，写入 `asciiArt` |

### 图片存储

- 图片压缩后保存到应用目录 `zheduoduo_data/images/{dealId}.jpg`
- `deal_images` 表存储图片元数据：`image_path`（本地路径）、`thumb_path`（缩略图）、`width`、`height`、`quality`、`original_size`、`compressed_size`、`source_url`（原始 URL）
- 切换 `visualType` 为 `none`/`ascii` 时，`deal_images` 标记为 `deleted=2`（待确认删除）；清理功能删除 `deleted != 0` 的记录及其本地图片文件
- 删除折扣详情（逻辑删除）时，同步逻辑删除关联的 `deal_images`

### 平台差异

| 平台 | 图片压缩 | 说明 |
|------|---------|------|
| Android / iOS | 支持 | 使用 `flutter_image_compress` 按配置档位压缩 |
| Windows / Linux | 不支持压缩 | 直接复制原图，`flutter_image_compress` 暂不支持桌面端 |

---

## 五、推荐 YAML 完整示例

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

discount: "6.6折"

sales:
  sold_30_days: ">1000"

source:
  platform: "京东"
  logistics: "京东物流"
  link: "https://..."
  type: "YAML导入"
  remark: "某活动页"

visual:
  type: image
  image_url: "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800&fit=crop"
  # ascii_art: |
  #    ___
  #   |   |
  #   |___|
```

---

## 六、简写兼容格式

```yaml
title: Apple iPhone 15 Pro 256GB
platform: 京东
category: 数码
originalPrice: 8999
currentPrice: 7499
discount: "8.3折"
sourceType: "YAML导入"
sourceRemark: "某活动页"
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

## 七、解析后 Deal 结构

```typescript
interface Deal {
  id: string;                    // UUID，自动生成
  title: string;                 // 商品名称
  currentPrice: number;          // 到手价
  originalPrice?: number;        // 原价
  displayPrice?: number;         // 页面展示价
  currency: string;              // 货币符号（默认 ¥）
  platform: string;              // 来源平台
  logistics?: string;            // 物流信息
  category: string;              // 分类
  tags: string[];                // 标签列表
  promotions: string[];          // 促销权益原文列表
  coupons: Coupon[];             // 优惠券列表
  discount?: string;             // 折扣描述（如 "6.6折"）
  salesJson?: string;            // 销量 JSON（如 '{"sold30Days":">1000"}'）
  isLowestPrice: number;         // 0=否，1=是
  note?: string;                 // 备注
  link?: string;                 // 购买链接
  visualType: 'none' | 'image' | 'ascii';
  asciiArt?: string;             // ASCII 艺术图
  sourceJson?: string;            // 来源信息 JSON，如 {"sourceType":"手动新增","sourceRemark":null}
  // 图片信息存储在 deal_images 表中，非 Deal 字段
  createdAt: string;             // ISO8601
  updatedAt: string;
  revision: number;              // 版本号，每次更新 +1
  deleted: number;               // 0=正常，2=待确认删除
  deletedAt?: string;
  deviceId?: string;             // 最后修改设备标识
}

interface SourceInfo {
  sourceType?: string;           // 来源类型，如 手动新增、YAML导入、API导入
  sourceRemark?: string;         // 来源备注，如活动页名称、渠道标识等
}

interface Coupon {
  id?: number;                   // 自增主键
  count: number;                 // 券数量（默认 1）
  source: string;                // 券来源
  strength: string;              // 优惠力度
  note?: string;                 // 备注
}

interface DealImage {
  dealId: string;                // 与 deals.id 一对一
  imagePath: string;             // 本地图片路径 images/{dealId}.jpg
  thumbPath?: string;            // 缩略图路径
  width?: number;                // 图片宽度
  height?: number;               // 图片高度
  quality?: number;              // JPEG 质量 0-100
  originalSize?: number;         // 原始文件大小（字节）
  compressedSize?: number;       // 压缩后大小（字节）
  sourceUrl?: string;            // 原始下载 URL
  updatedAt: string;
  deleted: number;               // 0=正常，1=确认删除，2=待确认删除
}
```

---

## 八、数据库表映射

### `deals` — 优惠主表

```sql
CREATE TABLE deals (
  id                  TEXT PRIMARY KEY,
  title               TEXT NOT NULL,
  platform            TEXT NOT NULL DEFAULT '其他',
  category            TEXT NOT NULL DEFAULT '其他',
  current_price       REAL NOT NULL,
  original_price      REAL,
  display_price       REAL,
  currency            TEXT NOT NULL DEFAULT '¥',
  discount            TEXT,
  logistics           TEXT,
  link                TEXT,
  note                TEXT,
  visual_type         TEXT NOT NULL DEFAULT 'none',
  ascii_art           TEXT,
  sales_json          TEXT,                       -- {"sold30Days":">1000"}
  source_json         TEXT,                       -- {"sourceType":"手动新增","sourceRemark":null}
  is_lowest_price     INTEGER NOT NULL DEFAULT 0,
  created_at          TEXT NOT NULL,
  updated_at          TEXT NOT NULL,
  revision            INTEGER NOT NULL DEFAULT 1, -- 云同步版本控制
  deleted             INTEGER NOT NULL DEFAULT 0,   -- 0=正常, 2=待确认删除
  deleted_at          TEXT,
  device_id           TEXT
);
```

### `deal_images` — 图片元数据（一对一）

```sql
CREATE TABLE deal_images (
  deal_id          TEXT PRIMARY KEY REFERENCES deals(id) ON DELETE CASCADE,
  image_path       TEXT NOT NULL,              -- images/{deal_id}.jpg
  thumb_path       TEXT,
  width            INTEGER,
  height           INTEGER,
  quality          INTEGER,                    -- JPEG 质量 0-100
  original_size    INTEGER,                    -- 字节
  compressed_size  INTEGER,
  source_url       TEXT,                       -- YAML image_url 来源
  updated_at       TEXT NOT NULL,
  deleted          INTEGER NOT NULL DEFAULT 0  -- 0=正常, 1=确认删除, 2=待确认删除
);
```

### `deal_tags` / `deal_promotions` / `coupons`

- `deal_tags(deal_id, tag)` — 标签多对多展开
- `deal_promotions(deal_id, sort_order, text)` — 促销权益原文
- `coupons(id, deal_id, sort_order, count, source, strength, note)` — 优惠券

---

## 九、软删除与数据清理

### 逻辑删除流程

1. 用户删除折扣详情 → `deals.deleted = 2`（待确认删除）
2. 同步关联的 `deal_images`：`deleted = 2`
3. 恢复时同步恢复：`deleted = 0`
4. 清理功能：物理删除 `deleted != 0` 的记录及其本地图片文件

### 数据清理

- `deal_images` 中 `deleted != 0` 的记录，其 `image_path` 对应的本地文件会被清理
- 应用提供「清理已删除数据」功能释放存储空间

---

## 十、使用流程

1. 新建优惠 → 默认「YAML 解析」
2. 粘贴 YAML 或点击「填入示例」
3. 点击「解析并填充」→ 自动填充价格、促销权益、标签、优惠券、图片 URL
4. 切换到手动表单核对，可编辑促销权益、优惠券、ASCII、本地图片
5. 保存 → 写入 `deals` + `deal_tags` + `deal_promotions` + `coupons` + `deal_images`

---

## 十一、相关文档

- [数据持久化方案](./数据持久化方案.md) — SQLite 离线存储与云同步
- [数据库表设计](./数据库表设计.md) — 完整表结构与字段映射
- [产品规划与开发建议](./产品规划与开发建议.md) — 功能路线图
