import 'package:flutter/foundation.dart';
import 'package:open_tv/error.dart';
import 'package:open_tv/native_bridge.dart';

class RefreshService {
  RefreshService._();
  static final RefreshService instance = RefreshService._();

  final ValueNotifier<bool> isRefreshing = ValueNotifier(false);
  final ValueNotifier<bool> playerVisible = ValueNotifier(false);

  Future<void> refreshAllOnStart() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      await Error.tryAsyncNoLoading(
        () => NativeBridge.instance.refreshAll(),
        true,
        "Refreshed all sources",
      );
    } finally {
      isRefreshing.value = false;
    }
  }
}
