import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppLogger {
  AppLogger._();

  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  Logger? _logger;
  DailyFileOutput? _fileOutput;
  bool _initialized = false;
  bool _enabled = true;

  bool get enabled => _enabled;
  set enabled(bool v) {
    _enabled = v;
    if (v && !_initialized) {
      unawaited(init());
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final logDir = await _getLogsDirectory();
    _cleanupOld(logDir);

    _fileOutput = DailyFileOutput(logDir.path);

    _logger = Logger(
      filter: DevelopmentFilter(),
      printer: _LogPrinter(),
      output: MultiOutput([ConsoleOutput(), _fileOutput!]),
    );
  }

  void v(dynamic message, [Object? error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    _logger?.t(message, error: error, stackTrace: stackTrace);
  }

  void d(dynamic message, [Object? error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    _logger?.d(message, error: error, stackTrace: stackTrace);
  }

  void i(dynamic message, [Object? error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    _logger?.i(message, error: error, stackTrace: stackTrace);
  }

  void w(dynamic message, [Object? error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    _logger?.w(message, error: error, stackTrace: stackTrace);
  }

  void e(dynamic message, [Object? error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }

  static Future<Directory> _getDataDirectory() async {
    if (Platform.isAndroid) {
      final d = await getExternalStorageDirectory();
      if (d != null) return d;
    }
    return getApplicationDocumentsDirectory();
  }

  static Future<Directory> _getLogsDirectory() async {
    final root = await _getDataDirectory();
    final dir = Directory(p.join(root.path, 'zheduoduo_data', 'logs'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static void _cleanupOld(Directory dir) {
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: 15));
      for (final f in dir.listSync().whereType<File>()) {
        try {
          if (f.lastModifiedSync().isBefore(cutoff)) f.deleteSync();
        } catch (_) {}
      }
    } catch (_) {}
  }
}

class _LogPrinter extends LogPrinter {
  _LogPrinter();

  @override
  List<String> log(LogEvent event) {
    final n = DateTime.now();
    final ts = '${n.year}-${_pad2(n.month)}-${_pad2(n.day)} '
        '${_pad2(n.hour)}:${_pad2(n.minute)}:${_pad2(n.second)}.${_pad3(n.millisecond)}';
    final lv = event.level.toString().split('.').last.toUpperCase().padRight(5);
    return ['$ts [$lv] ${event.message}'];
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');
  String _pad3(int n) => n.toString().padLeft(3, '0');
}

class DailyFileOutput extends LogOutput {
  final String dirPath;
  IOSink? _sink;
  String _currentDateStr = '';

  DailyFileOutput(this.dirPath);

  String get _dateStr {
    final n = DateTime.now();
    return '${n.year}-${_pad2(n.month)}-${_pad2(n.day)}';
  }

  String get _filePath => '$dirPath/log_$_dateStr.txt';

  @override
  Future<void> init() async {
    _openSink();
    return super.init();
  }

  void _openSink() {
    _currentDateStr = _dateStr;
    _sink = File(_filePath).openWrite(mode: FileMode.append);
  }

  /// 安全关闭旧 sink，忽略关闭过程中的错误
  Future<void> _safeClose(IOSink? sink) async {
    if (sink == null) return;
    try {
      await sink.flush();
    } catch (_) {}
    try {
      await sink.close();
    } catch (_) {}
  }

  @override
  void output(OutputEvent event) {
    try {
      final today = _dateStr;
      if (today != _currentDateStr) {
        // 日期变更：先保存旧 sink 引用，再打开新 sink，最后异步关闭旧 sink
        final oldSink = _sink;
        _openSink();
        unawaited(_safeClose(oldSink));
      }
      _sink?.writeAll(event.lines, '\n');
      _sink?.writeln();
      unawaited(_sink?.flush());
    } catch (_) {
      // sink 写入失败时尝试重新打开
      try {
        _openSink();
      } catch (_) {}
    }
  }

  @override
  Future<void> destroy() async {
    await _safeClose(_sink);
    _sink = null;
    return super.destroy();
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');
}
