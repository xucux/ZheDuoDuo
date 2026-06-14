# Flutter Desktop 版本开发方案

## 一、项目现状分析

| 维度 | 现状 | Desktop 兼容性 |
|------|------|----------------|
| **平台目录** | 无任何平台目录（android/ios/windows/macos/linux） | 需要创建 |
| **dart:io** | 15 处使用 | Desktop 原生支持，无需改动 |
| **google_mlkit_text_recognition** | OCR 核心依赖 | **不支持 Desktop**，仅 Android/iOS |
| **flutter_image_compress** | 图片压缩 | Windows/macOS 支持，Linux 部分支持 |
| **image_picker** | 拍照/相册 | Desktop 支持（相册可用，摄像头需额外处理） |
| **file_picker** | 文件选择 | Desktop 完全支持 |
| **share_plus** | 分享 | Desktop 支持 |
| **drift + sqlite3_flutter_libs** | 数据库 | Desktop 完全支持 |
| **dio / crypto** | 网络与签名 | Desktop 完全支持 |
| **permission_handler** | 权限 | Desktop 有限支持，多数权限无需 |

## 二、核心障碍：OCR 方案

`google_mlkit_text_recognition` **仅支持 Android/iOS**，这是最大的阻塞点。需要替换为跨平台方案：

采用【**条件编译**：移动端 ML Kit + 桌面端 Tesseract】

| 方案 | 优势 | 劣势 |
|------|------|------|
| **Tesseract OCR**（推荐） | 开源免费、全平台支持 | 精度略低于 ML Kit，需打包语言包 |
| **百度/腾讯云 OCR API** | 精度高、无需本地模型 | 需联网、有调用成本 |
| **条件编译**：移动端 ML Kit + 桌面端 Tesseract | 各平台最优体验 | 维护两套代码 |

## 三、实施步骤

### 第 1 步：创建 Desktop 平台支持

```bash
# 在项目根目录执行，为现有项目添加桌面平台
flutter create --platforms=windows,macos,linux .
```

先跑通 Windows，解决编译问题。

### 第 2 步：处理 OCR 平台差异

将 `OcrService` 抽象为接口，按平台分别实现：

```dart
// 抽象接口
abstract class OcrService {
  Future<String> recognizeImage(String imagePath);
  Future<RecognizedText> recognizeDetailed(String imagePath);
}

// 移动端实现 - google_mlkit
class MlKitOcrService implements OcrService { ... }

// 桌面端实现 - tesseract
class TesseractOcrService implements OcrService { ... }
```

推荐使用 [`tesseract_ocr`](https://pub.dev/packages/tesseract_ocr) 或通过进程调用 Tesseract CLI。

### 第 3 步：处理拍照功能

Desktop 一般无摄像头，`ImageSource.camera` 需要条件处理：

```dart
Future<void> _pickImage(ImageSource source) async {
  // Desktop 端隐藏拍照按钮或回退到文件选择
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    if (source == ImageSource.camera) {
      // Desktop 端用文件选择替代拍照
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      // ...
      return;
    }
  }
  // 原有逻辑
}
```

### 第 4 步：UI 适配

Desktop 屏幕更大，需要调整布局：

| 移动端 | Desktop 端 |
|--------|-----------|
| 单列列表 | 多列/侧边栏布局 |
| 底部导航 | 侧边导航栏 |
| 全屏页面 | 可用对话框/抽屉 |
| 触摸操作 | 鼠标右键菜单、快捷键 |

可通过 `MediaQuery` 或 `LayoutBuilder` 做响应式适配，也可用 `Platform.isWindows` 等判断。

### 第 5 步：窗口配置

在 `windows/runner/main.cpp`（或 macOS 的 `MainFlutterWindow.swift`）中配置窗口大小、标题等。推荐使用 [`window_manager`](https://pub.dev/packages/window_manager) 插件统一管理：

```yaml
# pubspec.yaml
dependencies:
  window_manager: ^0.4.0
```

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setSize(const Size(1024, 768));
      await windowManager.setMinimumSize(const Size(800, 600));
      await windowManager.setTitle('折多多');
      await windowManager.show();
    });
  }
  runApp(const App());
}
```

### 第 6 步：构建与测试

```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## 四、工作量评估

| 任务 | 复杂度 |
|------|--------|
| 创建平台目录 + 编译通过 | 低 |
| OCR 方案替换（最大工作量） | 高 |
| 拍照功能适配 | 低 |
| UI 响应式适配 | 中 |
| 窗口管理配置 | 低 |
| 打包与分发（安装包、签名） | 中 |

## 五、依赖兼容性明细

| 依赖包 | Windows | macOS | Linux | 备注 |
|--------|---------|-------|-------|------|
| drift + sqlite3_flutter_libs | ✅ | ✅ | ✅ | 完全支持 |
| dio | ✅ | ✅ | ✅ | 纯 Dart，无平台依赖 |
| crypto | ✅ | ✅ | ✅ | 纯 Dart |
| path_provider | ✅ | ✅ | ✅ | 完全支持 |
| file_picker | ✅ | ✅ | ✅ | 完全支持 |
| image_picker | ✅ | ✅ | ✅ | 桌面端仅支持相册，不支持拍照 |
| flutter_image_compress | ✅ | ✅ | ⚠️ | Linux 需额外配置 |
| share_plus | ✅ | ✅ | ✅ | 完全支持 |
| url_launcher | ✅ | ✅ | ✅ | 完全支持 |
| package_info_plus | ✅ | ✅ | ✅ | 完全支持 |
| connectivity_plus | ✅ | ✅ | ✅ | 完全支持 |
| google_mlkit_text_recognition | ❌ | ❌ | ❌ | **仅 Android/iOS** |
| permission_handler | ⚠️ | ⚠️ | ⚠️ | 桌面端权限模型不同，多数无需请求 |
| window_manager | ✅ | ✅ | ✅ | 需新增依赖 |
