import 'dart:async';
import 'dart:ffi';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import 'generated/generated_proto.pb.dart' as pb;
import 'generated/bindings.dart' as ffi;
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/source.dart';
import 'package:open_tv/models/filters.dart';
import 'package:open_tv/models/settings.dart';
import 'package:open_tv/extensions/proto_extensions.dart';
import 'package:open_tv/models/channel_http_headers.dart';

class NativeBridge {
  static NativeBridge? _instance;

  final ffi.RustLibBindings _bindings;
  int _nextTaskId = 0;
  final Map<int, Completer<pb.FFIResult>> _pendingRequests = {};
  late final NativeCallable<Void Function(Uint64, Pointer<Uint8>, Size)>
  _globalCallback;

  static NativeBridge get instance => _instance ??= NativeBridge._internal(
    ffi.RustLibBindings(_openDynamicLibrary()),
  );

  static DynamicLibrary _openDynamicLibrary() {
    if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open("libfred_tv_lib.so");
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return DynamicLibrary.process();
    }
    if (Platform.isWindows) {
      return DynamicLibrary.open("fred_tv_lib.dll");
    }
    return DynamicLibrary.open("libfred_tv_lib.so");
  }

  NativeBridge._internal(this._bindings) {
    _globalCallback =
        NativeCallable<Void Function(Uint64, Pointer<Uint8>, Size)>.listener((
          int taskId,
          Pointer<Uint8> ptr,
          int len,
        ) {
          final completer = _pendingRequests.remove(taskId);
          if (completer == null) return;

          try {
            final Uint8List copiedBytes;
            try {
              final u8List = ptr.asTypedList(len);
              copiedBytes = Uint8List.fromList(u8List);
            } finally {
              _bindings.free_message(ptr, len);
            }
            final result = pb.FFIResult.fromBuffer(copiedBytes);
            completer.complete(result);
          } catch (e, stackTrace) {
            completer.completeError(e, stackTrace);
          }
        });
  }

  Future<pb.FFIResult> _executeAsync(
    void Function(int taskId, ffi.FfiCallback callback) ffiAction,
  ) async {
    final taskId = _nextTaskId++;
    final completer = Completer<pb.FFIResult>();
    _pendingRequests[taskId] = completer;
    ffiAction(taskId, _globalCallback.nativeFunction);
    final result = await completer.future;
    if (!result.success) {
      throw Exception(
        result.hasErrorMessage() ? result.errorMessage : "Unknown FFI error",
      );
    }
    return result;
  }

  Future<pb.FFIResult> _executeWithMsg<T extends $pb.GeneratedMessage>(
    T request,
    void Function(
      int taskId,
      Pointer<Uint8> ptr,
      int len,
      ffi.FfiCallback callback,
    )
    ffiAction,
  ) async {
    final pbBytes = request.writeToBuffer();
    final nativeBuffer = malloc.allocate<Uint8>(pbBytes.length);

    try {
      final pointerList = nativeBuffer.asTypedList(pbBytes.length);
      pointerList.setAll(0, pbBytes);

      return await _executeAsync((id, cb) {
        ffiAction(id, nativeBuffer, pbBytes.length, cb);
      });
    } finally {
      malloc.free(nativeBuffer);
    }
  }

  Future<void> initialize(pb.InitMessage init) async {
    await _executeWithMsg(init, (id, ptr, len, cb) {
      _bindings.initialize(id, cb, ptr, len);
    });
  }

  Future<void> processSource(Source source) async {
    await _executeWithMsg(source.toProto(), (id, ptr, len, cb) {
      _bindings.process_source(id, cb, ptr, len);
    });
  }

  Future<void> refreshSource(Source source) async {
    await _executeWithMsg(source.toProto(), (id, ptr, len, cb) {
      _bindings.refresh_source(id, cb, ptr, len);
    });
  }

  Future<void> updateSource(Source source) async {
    await _executeWithMsg(source.toProto(), (id, ptr, len, cb) {
      _bindings.update_source(id, cb, ptr, len);
    });
  }

  Future<void> setSourceEnabled(int sourceId, bool enabled) async {
    await _executeWithMsg(
      pb.SetSourceEnabled(sourceId: Int64(sourceId), enabled: enabled),
      (id, ptr, len, cb) {
        _bindings.set_source_enabled(id, cb, ptr, len);
      },
    );
  }

  Future<void> deleteSource(int id) async {
    await _executeWithMsg(pb.IdMessage(value: Int64(id)), (id, ptr, len, cb) {
      _bindings.delete_source(id, cb, ptr, len);
    });
  }

  Future<List<Source>> getSources() async {
    final result = await _executeAsync((id, cb) {
      _bindings.get_sources(id, cb);
    });
    return result.sourceList.sources.map((s) => s.toDomain()).toList();
  }

  Future<List<int>> getEnabledSourcesMinimal() async {
    final result = await _executeAsync((id, cb) {
      _bindings.get_enabled_sources_minimal(id, cb);
    });
    return result.enabledSourcesMinimal.listId.map((e) => e.toInt()).toList();
  }

  Future<bool> hasSources() async {
    final result = await _executeAsync((id, cb) {
      _bindings.has_sources(id, cb);
    });
    return result.boolMessage.value;
  }

  Future<List<Channel>> getChannels(Filters filters) async {
    final result = await _executeWithMsg(filters.toProto(), (id, ptr, len, cb) {
      _bindings.get_channels(id, cb, ptr, len);
    });
    return result.channelList.channels.map((c) => c.toDomain()).toList();
  }

  Future<void> favorite(int channelId, bool isFavorite) async {
    await _executeWithMsg(
      pb.ToggleFavorite(channelId: Int64(channelId), favorite: isFavorite),
      (id, ptr, len, cb) {
        _bindings.favorite(id, cb, ptr, len);
      },
    );
  }

  Future<Settings> getSettings() async {
    final result = await _executeAsync((id, cb) {
      _bindings.get_settings(id, cb);
    });
    return result.settings.toDomain();
  }

  Future<void> updateSettings(Settings settings) async {
    await _executeWithMsg(settings.toProto(), (id, ptr, len, cb) {
      _bindings.update_settings(id, cb, ptr, len);
    });
  }

  Future<void> addLastWatched(int id) async {
    await _executeWithMsg(pb.IdMessage(value: Int64(id)), (id, ptr, len, cb) {
      _bindings.add_last_watched(id, cb, ptr, len);
    });
  }

  Future<void> setMoviePosition(int channelId, int position) async {
    await _executeWithMsg(
      pb.MoviePosition(channelId: Int64(channelId), position: Int64(position)),
      (id, ptr, len, cb) {
        _bindings.set_movie_position(id, cb, ptr, len);
      },
    );
  }

  Future<int?> getMoviePosition(int id) async {
    final result = await _executeWithMsg(pb.IdMessage(value: Int64(id)), (
      id,
      ptr,
      len,
      cb,
    ) {
      _bindings.get_movie_position(id, cb, ptr, len);
    });
    return result.hasMoviePosition() && result.moviePosition.hasPosition()
        ? result.moviePosition.position.toInt()
        : null;
  }

  Future<ChannelHttpHeaders?> getChannelHeaders(int id) async {
    final result = await _executeWithMsg(pb.IdMessage(value: Int64(id)), (
      id,
      ptr,
      len,
      cb,
    ) {
      _bindings.get_channel_headers(id, cb, ptr, len);
    });
    return result.hasHeaders() ? result.headers.toDomain() : null;
  }

  Future<void> getEpisodes(
    int seriesId,
    int sourceId,
    String? fallbackImage,
  ) async {
    final msg = pb.GetEpisodes(
      seriesId: Int64(seriesId),
      sourceId: Int64(sourceId),
      fallbackImage: fallbackImage,
    );
    await _executeWithMsg(msg, (id, ptr, len, cb) {
      _bindings.get_episodes(id, cb, ptr, len);
    });
  }

  Future<void> clearHistory() async {
    await _executeAsync((id, cb) {
      _bindings.clear_history(id, cb);
    });
  }

  Future<void> refreshAll() async {
    await _executeAsync((id, cb) {
      _bindings.refresh_all(id, cb);
    });
  }

  Future<bool> sourceNameExists(String name) async {
    final result = await _executeWithMsg(pb.StrMessage(value: name), (
      id,
      ptr,
      len,
      cb,
    ) {
      _bindings.source_name_exists(id, cb, ptr, len);
    });
    return result.boolMessage.value;
  }

  Future<bool> shouldShowWhatsNew(String? currentVersion) async {
    final result = await _executeWithMsg(
      pb.OptStrMessage(value: currentVersion),
      (id, ptr, len, cb) {
        _bindings.should_show_whats_new(id, cb, ptr, len);
      },
    );
    return result.boolMessage.value;
  }

  Future<void> updateLastSeenVersion(String version) async {
    await _executeWithMsg(pb.StrMessage(value: version), (id, ptr, len, cb) {
      _bindings.update_last_seen_version(id, cb, ptr, len);
    });
  }

  Future<Map<int, int>> getAllExpiries() async {
    final result = await _executeAsync((id, cb) {
      _bindings.get_all_expiries(id, cb);
    });
    return result.expiries.expiries.map(
      (key, value) => MapEntry(key.toInt(), value.toInt()),
    );
  }

  void dispose() {
    _globalCallback.close();
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError("NativeBridge was disposed."));
      }
    }
    _pendingRequests.clear();
    _instance = null;
  }
}
