// 同步状态模型
//
// 定义 synclocal.json 和 synccloud.json 的数据结构。

import 'dart:convert';

/// 同步状态（对应 synclocal.json / synccloud.json）
class SyncState {
  final int version;
  final String lastSyncDeviceId;
  final DateTime? lastSyncTime;
  final List<String> changelogZip;
  final List<DeviceSyncLog> deviceSyncLog;

  SyncState({
    required this.version,
    required this.lastSyncDeviceId,
    this.lastSyncTime,
    required this.changelogZip,
    required this.deviceSyncLog,
  });

  factory SyncState.empty(String deviceId) => SyncState(
    version: 0,
    lastSyncDeviceId: deviceId,
    lastSyncTime: null,
    changelogZip: [],
    deviceSyncLog: [
      DeviceSyncLog(
        deviceId: deviceId,
        lastVersion: 0,
        changelogZip: [],
        deviceName: deviceId,
        lastSyncTime: null,
      ),
    ],
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'lastSyncDeviceId': lastSyncDeviceId,
    'lastSyncTime': lastSyncTime?.toIso8601String(),
    'changelogZip': changelogZip,
    'deviceSyncLog': deviceSyncLog.map((e) => e.toJson()).toList(),
  };

  factory SyncState.fromJson(Map<String, dynamic> json) => SyncState(
    version: json['version'] as int? ?? 0,
    lastSyncDeviceId: json['lastSyncDeviceId'] as String? ?? '',
    lastSyncTime: json['lastSyncTime'] != null
        ? DateTime.tryParse(json['lastSyncTime'] as String)
        : null,
    changelogZip: (json['changelogZip'] as List?)?.map((e) => e as String).toList() ?? [],
    deviceSyncLog: (json['deviceSyncLog'] as List?)
            ?.map((e) => DeviceSyncLog.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  String toRawJson() => jsonEncode(toJson());

  SyncState copyWith({
    int? version,
    String? lastSyncDeviceId,
    DateTime? lastSyncTime,
    List<String>? changelogZip,
    List<DeviceSyncLog>? deviceSyncLog,
  }) => SyncState(
    version: version ?? this.version,
    lastSyncDeviceId: lastSyncDeviceId ?? this.lastSyncDeviceId,
    lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    changelogZip: changelogZip ?? this.changelogZip,
    deviceSyncLog: deviceSyncLog ?? this.deviceSyncLog,
  );
}

/// 设备同步日志
class DeviceSyncLog {
  final String deviceId;
  final int lastVersion;
  final List<String> changelogZip;
  final String deviceName;
  final DateTime? lastSyncTime;

  DeviceSyncLog({
    required this.deviceId,
    required this.lastVersion,
    required this.changelogZip,
    required this.deviceName,
    this.lastSyncTime,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'lastVersion': lastVersion,
    'changelogZip': changelogZip,
    'deviceName': deviceName,
    'lastSyncTime': lastSyncTime?.toIso8601String(),
  };

  factory DeviceSyncLog.fromJson(Map<String, dynamic> json) => DeviceSyncLog(
    deviceId: json['deviceId'] as String? ?? '',
    lastVersion: json['lastVersion'] as int? ?? 0,
    changelogZip: (json['changelogZip'] as List?)?.map((e) => e as String).toList() ?? [],
    deviceName: json['deviceName'] as String? ?? '',
    lastSyncTime: json['lastSyncTime'] != null
        ? DateTime.tryParse(json['lastSyncTime'] as String)
        : null,
  );

  DeviceSyncLog copyWith({
    int? lastVersion,
    List<String>? changelogZip,
    String? deviceName,
    DateTime? lastSyncTime,
  }) => DeviceSyncLog(
    deviceId: deviceId,
    lastVersion: lastVersion ?? this.lastVersion,
    changelogZip: changelogZip ?? this.changelogZip,
    deviceName: deviceName ?? this.deviceName,
    lastSyncTime: lastSyncTime ?? this.lastSyncTime,
  );
}
