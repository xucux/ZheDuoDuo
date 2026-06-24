// 同步状态管理器
//
// 管理 synclocal.json 和 synccloud.json 的读写、版本协调。

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../utils/logger_util.dart';
import 'models/sync_state.dart';
import 'transports/sync_transport.dart';

class SyncStateManager {
  String? _localStatePath;
  final String _remoteStatePath;
  SyncTransport? _transport;

  SyncStateManager({String? baseDir, String remoteStatePath = 'zheduoduo/synccloud.json'})
      : _localStatePath = baseDir != null ? p.join(baseDir, 'synclocal.json') : null,
        _remoteStatePath = remoteStatePath;

  Future<String> _ensureLocalPath() async {
    if (_localStatePath != null) return _localStatePath!;
    final dir = await getApplicationDocumentsDirectory();
    _localStatePath = p.join(dir.path, 'zheduoduo_data', 'synclocal.json');
    return _localStatePath!;
  }

  void setTransport(SyncTransport transport) {
    _transport = transport;
  }

  /// 读取本地同步状态
  Future<SyncState> readLocalState(String deviceId) async {
    final path = await _ensureLocalPath();
    final file = File(path);
    if (!file.existsSync()) {
      AppLogger.instance.i('[SyncState] 本地状态文件不存在，返回空状态');
      return SyncState.empty(deviceId);
    }
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final state = SyncState.fromJson(json);
      AppLogger.instance.i('[SyncState] 读取本地状态: version=${state.version}, 设备数=${state.deviceSyncLog.length}');
      return state;
    } catch (e) {
      AppLogger.instance.e('[SyncState] 读取本地状态失败', e);
      return SyncState.empty(deviceId);
    }
  }

  /// 写入本地同步状态
  Future<void> writeLocalState(SyncState state) async {
    final path = await _ensureLocalPath();
    final file = File(path);
    final dir = file.parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    await file.writeAsString(state.toRawJson());
    AppLogger.instance.i('[SyncState] 写入本地状态: version=${state.version} → $path');
  }

  /// 读取远端同步状态（synccloud.json）
  Future<SyncState?> readRemoteState() async {
    final transport = _transport;
    if (transport == null) return null;
    try {
      final data = await transport.download(_remoteStatePath);
      final content = utf8.decode(data);
      final json = jsonDecode(content) as Map<String, dynamic>;
      final state = SyncState.fromJson(json);
      AppLogger.instance.i('[SyncState] 读取远端状态: version=${state.version}, 设备数=${state.deviceSyncLog.length}');
      return state;
    } catch (e) {
      AppLogger.instance.w('[SyncState] 读取远端状态失败 (可能首次同步): $_remoteStatePath');
      return null;
    }
  }

  /// 写入远端同步状态（乐观锁：先读再写，版本不匹配则失败）
  Future<bool> writeRemoteState(SyncState state, {SyncState? expected}) async {
    final transport = _transport;
    if (transport == null) return false;
    try {
      // 乐观锁检查
      if (expected != null) {
        final remote = await readRemoteState();
        if (remote != null && remote.version != expected.version) {
          AppLogger.instance.w('[SyncState] 乐观锁冲突: 期望version=${expected.version}, 实际version=${remote.version}');
          return false; // 版本冲突
        }
      }
      final bytes = Uint8List.fromList(utf8.encode(state.toRawJson()));
      await transport.upload(_remoteStatePath, bytes);
      AppLogger.instance.i('[SyncState] 写入远端状态成功: version=${state.version}');
      return true;
    } catch (e) {
      AppLogger.instance.e('[SyncState] 写入远端状态失败', e);
      return false;
    }
  }

  /// 确保本地状态包含当前设备的日志记录
  Future<SyncState> ensureDeviceLog(SyncState state, String deviceId) async {
    final exists = state.deviceSyncLog.any((l) => l.deviceId == deviceId);
    if (exists) return state;
    return state.copyWith(
      deviceSyncLog: [
        ...state.deviceSyncLog,
        DeviceSyncLog(
          deviceId: deviceId,
          lastVersion: 0,
          changelogZip: [],
          deviceName: deviceId,
          lastSyncTime: null,
        ),
      ],
    );
  }

  /// 递增版本号并更新本地设备日志
  SyncState bumpVersion(SyncState state, String deviceId, String zipName) {
    final newVersion = state.version + 1;
    final updatedLogs = state.deviceSyncLog.map((l) {
      if (l.deviceId == deviceId) {
        return l.copyWith(
          lastVersion: newVersion,
          changelogZip: [...l.changelogZip, zipName],
          lastSyncTime: DateTime.now(),
        );
      }
      return l;
    }).toList();
    return state.copyWith(
      version: newVersion,
      lastSyncDeviceId: deviceId,
      lastSyncTime: DateTime.now(),
      changelogZip: [...state.changelogZip, zipName],
      deviceSyncLog: updatedLogs,
    );
  }
}
