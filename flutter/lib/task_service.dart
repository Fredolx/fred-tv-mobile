import 'package:flutter/foundation.dart';
import 'package:open_tv/error.dart';
import 'package:open_tv/models/source.dart';
import 'package:open_tv/native_bridge.dart';

class TaskService {
  TaskService._();
  static final TaskService instance = TaskService._();

  final ValueNotifier<String?> runningTask = ValueNotifier(null);
  final ValueNotifier<bool> playerVisible = ValueNotifier(false);

  static const _deletingSource = "Deleting source";

  bool get busy => runningTask.value != null;

  bool get isDeletingSource => runningTask.value == _deletingSource;

  void notifyBusy() => Error.showMessage("${runningTask.value}, please wait");

  Future<void> refreshAll() => _run(
    "Refresh in progress",
    () => NativeBridge.instance.refreshAll(),
    "Successfully refreshed all sources",
  );

  Future<void> refreshSource(Source source) => _run(
    "Refresh in progress",
    () => NativeBridge.instance.refreshSource(source),
    "Source has been refreshed successfully",
  );

  Future<void> deleteSource(int id) => _run(
    _deletingSource,
    () => NativeBridge.instance.deleteSource(id),
    "Successfully deleted source",
  );

  Future<void> _run(
    String label,
    Future<void> Function() task,
    String successMessage,
  ) async {
    if (busy) return;
    runningTask.value = label;
    try {
      await Error.tryAsyncNoLoading(task, true, successMessage);
    } finally {
      runningTask.value = null;
    }
  }
}
