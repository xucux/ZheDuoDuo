// 同步操作结果模型
//
// 定义增量同步和全量同步的返回结果。

class SyncResult {
  final SyncResultType type;
  final String? message;
  final int? changeCount;

  const SyncResult._(this.type, {this.message, this.changeCount});

  const SyncResult.success({this.message, this.changeCount})
      : type = SyncResultType.success;

  const SyncResult.noChanges({this.message})
      : type = SyncResultType.noChanges,
        changeCount = 0;

  const SyncResult.conflict({this.message})
      : type = SyncResultType.conflict,
        changeCount = 0;

  const SyncResult.cancelled({this.message})
      : type = SyncResultType.cancelled,
        changeCount = 0;

  const SyncResult.failure(this.message)
      : type = SyncResultType.failure,
        changeCount = 0;

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
