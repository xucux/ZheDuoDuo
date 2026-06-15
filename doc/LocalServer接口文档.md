# Local Server 接口文档

## 基础信息

| 项目 | 说明 |
|------|------|
| 服务地址 | `http://127.0.0.1:28256` |
| 默认端口 | `28256`（被占用时自动递增） |
| 认证方式 | `Bearer Token`（默认 Token: `zheduoduo`） |
| 公开路径 | `/`、`/index`、`/index.html`、`/assets/*`、`/mcp/*`、`/sse/*` |

---

## 认证说明

除公开路径外，所有 API 请求需在 Header 中携带 Token：

```http
Authorization: Bearer zheduoduo
```

未携带或 Token 错误时返回：

```json
{
  "error": "Unauthorized",
  "message": "缺少或无效的访问凭证"
}
```

---

## 静态文件服务

- **来源**：`assets/web/` 下的文件（运行时解压到临时目录）
- **入口**：`/index.html`
- **说明**：`/`、`/index` 会自动重定向到 `/index.html`

---

## Deal 模块

**基础路径**: `/api/deals`

### 1. 查询列表

- **URL**: `GET /api/deals/list`
- **Query 参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| page | int | 否 | 页码，默认 `1` |
| pageSize | int | 否 | 每页条数，默认 `20`，最大 `200` |
| platform | string | 否 | 平台筛选 |
| category | string | 否 | 分类筛选 |
| search | string | 否 | 关键词搜索（匹配 `title`、`platform`、`category`） |
| startTime | string | 否 | 创建时间起始（ISO8601） |
| endTime | string | 否 | 创建时间截止（ISO8601，自动包含当天 23:59:59） |

- **响应**:

```json
{
  "data": [ /* Deal 列表 */ ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 100,
    "pages": 5
  }
}
```

---

### 2. 查询详情

- **URL**: `GET /api/deals/detail/<id>`
- **响应**:

```json
{
  "data": {
    "id": "deal_xxx",
    "title": "商品标题",
    "platform": "京东",
    "category": "数码",
    "currentPrice": 99.9,
    "originalPrice": 199.9,
    "displayPrice": 89.9,
    "currency": "¥",
    "discount": "5折",
    "logistics": "包邮",
    "link": "https://...",
    "note": "备注",
    "visualType": "image",
    "asciiArt": null,
    "salesJson": null,
    "sourceJson": null,
    "isLowestPrice": 0,
    "createdAt": "2026-06-13T10:00:00.000",
    "updatedAt": "2026-06-13T10:00:00.000",
    "tags": ["tag1", "tag2"],
    "promotions": ["满100减20"],
    "coupons": [
      {
        "id": 1,
        "count": 1,
        "source": "促销",
        "strength": "满100减20",
        "note": null
      }
    ],
    "image": {
      "dealId": "deal_xxx",
      "imagePath": "/path/to/img.jpg",
      "thumbPath": "/path/to/thumb.jpg"
    }
  }
}
```

---

### 3. 单个新增

- **URL**: `POST /api/deals/create`
- **请求体**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | string | 否 | 不传则自动生成 |
| title | string | 是 | 标题 |
| platform | string | 否 | 默认 `其他` |
| category | string | 否 | 默认 `其他` |
| currentPrice | number | 否 | 默认 `0` |
| originalPrice | number | 否 | — |
| displayPrice | number | 否 | — |
| currency | string | 否 | 默认 `¥` |
| discount | string | 否 | — |
| logistics | string | 否 | — |
| link | string | 否 | — |
| note | string | 否 | — |
| visualType | string | 否 | 默认 `none` |
| asciiArt | string | 否 | — |
| salesJson | string | 否 | — |
| sourceJson | string | 否 | 来源信息 JSON，如 `{"sourceType":"手动新增","sourceRemark":null}`，传 `null` 则跳过赋值 |
| tags | string[] | 否 | 标签列表 |
| promotions | string[] | 否 | 促销列表 |
| coupons | object[] | 否 | 优惠券列表 |

- **响应**:

```json
{
  "data": { /* 创建的 Deal */ }
}
```

---

### 4. 批量新增

- **URL**: `POST /api/deals/batchCreate`
- **请求体**: `Deal[]`（数组，字段同单个新增）
- **响应**:

```json
{
  "data": [ /* 创建的 Deal 列表 */ ],
  "count": 2
}
```

---

### 5. 更新

- **URL**: `POST /api/deals/update/<id>`
- **请求体**: 字段同新增，仅传需要修改的字段
  - `tags`、`promotions`、`coupons` 字段若传入则**完全替换**原有数据
  - 不传入则保留原有数据
- **响应**:

```json
{
  "data": { /* 更新后的 Deal */ }
}
```

---

### 6. 单个删除（软删除）

- **URL**: `POST /api/deals/delete/<id>`
- **响应**:

```json
{
  "message": "Deleted"
}
```

---

### 7. 批量删除（软删除）

- **URL**: `POST /api/deals/batchDelete`
- **请求体**:

```json
{
  "ids": ["deal_xxx", "deal_yyy"]
}
```

- **响应**:

```json
{
  "message": "Batch deleted",
  "count": 2
}
```

---

## 数据模型

### Deal（优惠主体）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 唯一标识 |
| title | string | 标题 |
| platform | string | 平台 |
| category | string | 分类 |
| currentPrice | number | 当前价格 |
| originalPrice | number \| null | 原价 |
| displayPrice | number \| null | 展示价格 |
| currency | string | 货币符号 |
| discount | string \| null | 折扣信息 |
| logistics | string \| null | 物流信息 |
| link | string \| null | 商品链接 |
| note | string \| null | 备注 |
| visualType | string | 视觉类型（`none` / `image` / `ascii`） |
| asciiArt | string \| null | ASCII 艺术图 |
| salesJson | string \| null | 销量 JSON |
| sourceJson | string \| null | 来源信息 JSON，结构见下 `SourceInfo` |
| isLowestPrice | int | 是否最低价（`0` / `1`） |
| createdAt | string | 创建时间（ISO8601） |
| updatedAt | string | 更新时间（ISO8601） |

### SourceInfo（来源信息）

`sourceJson` 序列化后的对象结构：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| sourceType | string | 否 | 来源类型，如 `手动新增`、`YAML导入`、`接口新增` |
| sourceRemark | string | 否 | 来源备注，如活动页名称、渠道标识等补充说明 |

示例：

```json
{
  "sourceType": "手动新增",
  "sourceRemark": null
}
```

### Coupon（优惠券）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键（`0` 表示新增） |
| count | int | 数量，默认 `1` |
| source | string | 来源，默认 `促销` |
| strength | string | 优惠力度 |
| note | string \| null | 备注 |

### Image（图片）

| 字段 | 类型 | 说明 |
|------|------|------|
| dealId | string | 关联 Deal ID |
| imagePath | string | 原图路径 |
| thumbPath | string | 缩略图路径 |

---

## 通用响应格式

| HTTP 状态码 | 含义 | 示例 |
|-------------|------|------|
| 200 | 成功 | `{ "data": ... }` |
| 201 | 创建成功 | `{ "data": ... }` |
| 404 | 资源不存在 | `{ "error": "Deal not found" }` |
| 401 | 未授权 | `{ "error": "Unauthorized" }` |

---

## 相关源码

- [local_server_service.dart](file:///d:/ProjectApp/ZheDuoDuo/lib/features/local_server/services/local_server_service.dart) — 服务启动、静态文件、Token 鉴权
- [deal_controller.dart](file:///d:/ProjectApp/ZheDuoDuo/lib/features/local_server/controllers/deal_controller.dart) — RESTful API 路由与业务逻辑
- [deal_dao.dart](file:///d:/ProjectApp/ZheDuoDuo/lib/core/database/daos/deal_dao.dart) — 数据库 CRUD、软删除、关联数据保存
