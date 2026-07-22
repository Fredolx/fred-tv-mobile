import 'package:flutter/foundation.dart';
import 'package:open_tv/error.dart';
import 'package:open_tv/models/source.dart';
import 'package:open_tv/native_bridge.dart';

class RefreshService {
  RefreshService._();
  static final RefreshService instance = RefreshService._();

  final ValueNotifier<bool> isRefreshing = ValueNotifier(false);
  final ValueNotifier<bool> playerVisible = ValueNotifier(false);

  Future<void> refreshAll() => _refresh(
    () => NativeBridge.instance.refreshAll(),
    "Successfully refreshed all sources",
  );

  Future<void> refreshSource(Source source) => _refresh(
    () => NativeBridge.instance.refreshSource(source),
    "Source has been refreshed successfully",
  );

  Future<void> _refresh(
    Future<void> Function() refresh,
    String successMessage,
  ) async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      await Error.tryAsyncNoLoading(refresh, true, successMessage);
    } finally {
      isRefreshing.value = false;
    }
  }
}
