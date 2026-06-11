# 本地 OCR 方案调研

> 折多多 App 本地 OCR 实现方案对比

## 一、方案总览

| 方案 | 平台 | 精度 | 包体积影响 | 维护状态 | 推荐度 |
|------|------|------|-----------|----------|--------|
| **Google ML Kit** (`google_mlkit_text_recognition`) | Android / iOS | ⭐⭐⭐⭐⭐ | ~2MB | 官方维护 | ⭐⭐⭐⭐⭐ |
| **Tesseract** (`flutter_tesseract_ocr` / `flusseract`) | Android / iOS / Web / Windows | ⭐⭐⭐ | ~15-30MB (含语言包) | 社区维护 | ⭐⭐⭐⭐ |
| **Apple Vision** (原生 iOS) | iOS only | ⭐⭐⭐⭐⭐ | 0 (系统自带) | 官方内置 | ⭐⭐⭐⭐ (仅iOS) |
| **Windows OCR** (`windows_ocr`) | Windows only | ⭐⭐⭐⭐ | 0 (系统 API) | 社区维护 | ⭐⭐⭐ (仅Windows) |
| **flutter_ocr_kit** (ML Kit + ONNX) | Android / iOS | ⭐⭐⭐⭐⭐ | ~123MB (含模型) | 个人维护 | ⭐⭐ |

---

## 二、方案详解

### 1. Google ML Kit Text Recognition（推荐）

**依赖：**
```yaml
dependencies:
  google_mlkit_text_recognition: ^0.14.0
```

**特点：**
- Google 官方维护，持续更新
- 基于设备端 ML 模型，无需网络
- 支持拉丁文 / 中文 / 日文 / 韩文等文字识别
- 精度高，速度快
- Android 和 iOS 双平台支持
- 包体积增量约 2MB

**缺点：**
- 不支持 Windows / Linux / macOS 桌面平台
- 中文识别需额外下载语言包（首次自动下载）

**使用示例：**
```dart
final textRecognizer = TextRecognizer(script: ChineseTextRecognizerScript());
final inputImage = InputImage.fromFilePath(imagePath);
final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
// recognizedText.text 即为识别结果
```

**结论：** 折多多以 Android/iOS 为主，首选方案。

---

### 2. Tesseract OCR（备选 + 跨平台方案）

**依赖（二选一）：**
```yaml
# 方案 A - flutter_tesseract_ocr（成熟，仅 Android/iOS/Web）
  flutter_tesseract_ocr: ^0.4.30

# 方案 B - flusseract（跨平台，含 Windows/Linux/macOS）
  flusseract: ^0.1.1
```

**特点：**
- 开源免费，无平台限制（Windows / Linux / macOS / Android / iOS）
- 4.0 版本基于 LSTM 神经网络引擎
- 支持 100+ 语言，含中文简体/繁体
- 可离线运行，无需网络

**缺点：**
- 精度不如 ML Kit（尤其是复杂背景或手写体）
- 速度较慢（CPU 推理）
- 包体积大：自带 `eng.traineddata` ~15MB，中文包 ~30MB+
- 需要下载语言训练数据文件（`.traineddata`）放到 assets 中

**使用示例（flutter_tesseract_ocr）：**
```dart
String text = await FlutterTesseractOcr.extractText(
  imagePath,
  language: 'chi_sim',   // 中文简体
  args: {
    "psm": "6",          // Page segmentation mode
  },
);
```

**结论：** 需要桌面平台（Windows）OCR 时的首选。折多多目前主攻移动端，可作为 ML Kit 不可用时的兜底方案。

---

### 3. Apple Vision Framework（iOS 原生）

**特点：**
- iOS 系统原生 API，零依赖
- 精度极高，由 Apple 持续优化
- 支持 13 种语言
- 可通过 platform channel 调用

**缺点：**
- iOS only，Android 不可用
- 需要写 Swift/ObjC 平台代码

**结论：** iOS 平台可选用，但会增加维护成本。建议通过 ML Kit 统一 Android/iOS 逻辑。

---

### 4. Windows OCR（桌面端） 

**依赖：**
```yaml
dependencies:
  windows_ocr: ^0.1.0
```

**特点：**
- 基于 Windows 系统 OCR API（`Windows.Media.Ocr`）
- 支持 26+ 语言 + 4 种亚洲语言（含中文）
- 零额外包体积
- 支持 PDF / 条形码 / MRZ

**缺点：**
- Windows only

**结论：** 若折多多将来发布 Windows 桌面版，可使用此方案。

---

### 5. flutter_ocr_kit（增强方案）

**依赖：**
```yaml
dependencies:
  flutter_ocr_kit:
    git:
      url: https://github.com/robert008/flutter_ocr_kit.git
```

**特点：**
- ML Kit + ONNX Runtime 做版面分析
- 支持文档版面检测（表格、标题、段落）
- 边缘 AI 全离线

**缺点：**
- 个人维护，活跃度低
- 需要额外下载 ONNX 模型（123MB）
- 集成复杂度高

**结论：** 不需要版面分析功能时无需考虑。

---

## 三、推荐方案

### 针对折多多 App

```
┌─────────────────────────────────────────────┐
│           OCR 策略决策树                    │
├─────────────────────────────────────────────┤
│                                             │
│  1. 平台识别                               │
│     ├── Android → Google ML Kit             │
│     ├── iOS     → Google ML Kit             │
│     └── Windows → Tesseract (flusseract)    │
│                                             │
│  2. 兜底策略                                │
│     └── ML Kit 不可用 → fallback Tesseract  │
│                                             │
│  3. 包体积优化                              │
│     └── Tesseract 语言包按需下载            │
└─────────────────────────────────────────────┘
```

### 具体实施建议

#### 阶段一（当前推荐）
- **主方案：** `google_mlkit_text_recognition`
- **范围：** Android + iOS
- **理由：** 精度最高、官方维护、包体积最小、集成最简单

#### 阶段二（未来扩展）
- **桌面端：** `flusseract` 或 `windows_ocr`
- **兜底：** Tesseract 退路

---

## 四、参考资料

- [Google ML Kit Text Recognition](https://pub.dev/packages/google_mlkit_text_recognition)
- [flutter_tesseract_ocr](https://pub.dev/packages/flutter_tesseract_ocr)
- [flusseract](https://pub.dev/packages/flusseract)
- [windows_ocr](https://pub.dev/packages/windows_ocr)
- [flutter_ocr_kit](https://github.com/robert008/flutter_ocr_kit)
- [Tesseract OCR GitHub](https://github.com/tesseract-ocr/tesseract)
