// 同步操作结果模型
//
// 定义增量同步和全量同步的返回结果。

class SyncResult {
  final SyncResultType type;
  final String? message;
  final int? changeCount;
  final int? fileSize;
  final int? dealCount;
  /// 本次推送的 ZIP 文件名（仅增量推送成功时返回）
  final String? pushedZipName;
  /// 同步后的远端 synccloud.json 内容摘要（仅增量推送成功时返回）
  final String? syncCloudSummary;
  /// 是否需要重启应用（全量下载后数据库已替换，需重启才能继续使用）
  final bool needsRestart;

  const SyncResult._(
    this.type, {
    this.message,
    this.changeCount,
    this.fileSize,
    this.dealCount,
    this.pushedZipName,
    this.syncCloudSummary,
    this.needsRestart = false,
  });

  const SyncResult.success({
    this.message,
    this.changeCount,
    this.fileSize,
    this.dealCount,
    this.pushedZipName,
    this.syncCloudSummary,
    this.needsRestart = false,
  }) : type = SyncResultType.success;

  const SyncResult.noChanges({this.message})
      : type = SyncResultType.noChanges,
        changeCount = 0,
        fileSize = null,
        dealCount = null,
        pushedZipName = null,
        syncCloudSummary = null,
        needsRestart = false;

  const SyncResult.conflict({this.message})
      : type = SyncResultType.conflict,
        changeCount = 0,
        fileSize = null,
        dealCount = null,
        pushedZipName = null,
        syncCloudSummary = null,
        needsRestart = false;

  const SyncResult.cancelled({this.message})
      : type = SyncResultType.cancelled,
        changeCount = 0,
        fileSize = null,
        dealCount = null,
        pushedZipName = null,
        syncCloudSummary = null,
        needsRestart = false;

  const SyncResult.failure(this.message)
      : type = SyncResultType.failure,
        changeCount = 0,
        fileSize = null,
        dealCount = null,
        pushedZipName = null,
        syncCloudSummary = null,
        needsRestart = false;

  bool get success => type == SyncResultType.success || type == SyncResultType.noChanges;
  bool get isSuccess => success;
  bool get isNoChanges => type == SyncResultType.noChanges;
  bool get isFailure => type == SyncResultType.failure;
  bool get isConflict => type == SyncResultType.conflict;
  bool get isCancelled => type == SyncResultType.cancelled;
}

enum SyncResultType {
  success,
  noChanges,
  conflict,
  cancelled,
  failure,
}
