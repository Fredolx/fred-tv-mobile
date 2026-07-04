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
import 'package:open_tv/models/proto_extensions.dart';

class NativeBridge {
  static NativeBridge? _instance;

  final ffi.RustLibBindings _bindings;
  int _nextTaskId = 0;
  final Map<int, Completer<pb.FFIResult>> _pendingRequests = {};
  late final NativeCallable<Void Function(Uint64, ffi.Bytes)> _globalCallback;

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
    _globalCallback = NativeCallable<Void Function(Uint64, ffi.Bytes)>.listener(
      (int taskId, ffi.Bytes response) {
        final completer = _pendingRequests.remove(taskId);
        if (completer == null) return;

        try {
          final Uint8List copiedBytes;
          try {
            final u8List = response.ptr.asTypedList(response.len);
            copiedBytes = Uint8List.fromList(u8List);
          } finally {
            _bindings.free_message(response);
          }
          final result = pb.FFIResult.fromBuffer(copiedBytes);
          completer.complete(result);
        } catch (e, stackTrace) {
          completer.completeError(e, stackTrace);
        }
      },
    );
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
      throw Exception(result.hasErrorMessage() ? result.errorMessage : "Unknown FFI error");
    }
    return result;
  }

  Future<pb.FFIResult> _executeWithMsg<T extends $pb.GeneratedMessage>(
    T request,
    void Function(int taskId, ffi.Bytes message, ffi.FfiCallback callback)
    ffiAction,
  ) async {
    final pbBytes = request.writeToBuffer();
    final nativeBuffer = malloc.allocate<Uint8>(pbBytes.length);
    final requestBytes = malloc.allocate<ffi.Bytes>(1);

    try {
      final pointerList = nativeBuffer.asTypedList(pbBytes.length);
      pointerList.setAll(0, pbBytes);

      requestBytes.ref.ptr = nativeBuffer;
      requestBytes.ref.len = pbBytes.length;

      return await _executeAsync((id, cb) {
        ffiAction(id, requestBytes.ref, cb);
      });
    } finally {
      malloc.free(nativeBuffer);
      malloc.free(requestBytes);
    }
  }

  Future<void> initialize(pb.InitMessage init) async {
    await _executeWithMsg(init, (id, msg, cb) {
      _bindings.initialize(id, cb, msg);
    });
  }

  Future<void> processSource(Source source) async {
    await _executeWithMsg(source.toProto(), (id, msg, cb) {
      _bindings.process_source(id, cb, msg);
    });
  }

  Future<void> refreshSource(Source source) async {
    await _executeWithMsg(source.toProto(), (id, msg, cb) {
      _bindings.refresh_source(id, cb, msg);
    });
  }

  Future<void> deleteSource(int id) async {
    await _executeWithMsg(pb.IdMessage(value: Int64(id)), (id, msg, cb) {
      _bindings.delete_source(id, cb, msg);
    });
  }

  Future<List<Channel>> getChannels(Filters filters) async {
    final result = await _executeWithMsg(filters.toProto(), (id, msg, cb) {
      _bindings.get_channels(id, cb, msg);
    });
    return result.channelList.channels.map((c) => c.toDomain()).toList();
  }

  Future<void> favorite(int channelId, bool isFavorite) async {
    await _executeWithMsg(
      pb.ToggleFavorite(channelId: Int64(channelId), favorite: isFavorite),
      (id, msg, cb) {
        _bindings.favorite(id, cb, msg);
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
    await _executeWithMsg(settings.toProto(), (id, msg, cb) {
      _bindings.update_settings(id, cb, msg);
    });
  }

  Future<void> addLastWatched(int id) async {
    await _executeWithMsg(pb.IdMessage(value: Int64(id)), (id, msg, cb) {
      _bindings.add_last_watched(id, cb, msg);
    });
  }

  Future<void> setMoviePosition(int channelId, int position) async {
    await _executeWithMsg(
      pb.MoviePosition(channelId: Int64(channelId), position: Int64(position)),
      (id, msg, cb) {
        _bindings.set_movie_position(id, cb, msg);
      },
    );
  }

  Future<int?> getMoviePosition(int id) async {
    final result = await _executeWithMsg(pb.IdMessage(value: Int64(id)), (id, msg, cb) {
      _bindings.get_movie_position(id, cb, msg);
    });
    return result.hasMoviePosition() && result.moviePosition.hasPosition()
        ? result.moviePosition.position.toInt()
        : null;
  }

  Future<void> getEpisodes(int seriesId, int sourceId, String? fallbackImage) async {
    final msg = pb.GetEpisodes(
      seriesId: Int64(seriesId),
      sourceId: Int64(sourceId),
      fallbackImage: fallbackImage,
    );
    await _executeWithMsg(msg, (id, msg, cb) {
      _bindings.get_episodes(id, cb, msg);
    });
  }

  Future<void> clearHistory() async {
    await _executeAsync((id, cb) {
      _bindings.clear_history(id, cb);
    });
  }

  Future<bool> sourceNameExists(String name) async {
    final result = await _executeWithMsg(pb.StrMessage(value: name), (id, msg, cb) {
      _bindings.source_name_exists(id, cb, msg);
    });
    return result.boolMessage.value;
  }

  Future<bool> shouldShowWhatsNew(String? currentVersion) async {
    final result = await _executeWithMsg(pb.OptStrMessage(value: currentVersion), (id, msg, cb) {
      _bindings.should_show_whats_new(id, cb, msg);
    });
    return result.boolMessage.value;
  }

  Future<void> updateLastSeenVersion(String version) async {
    await _executeWithMsg(pb.StrMessage(value: version), (id, msg, cb) {
      _bindings.update_last_seen_version(id, cb, msg);
    });
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
