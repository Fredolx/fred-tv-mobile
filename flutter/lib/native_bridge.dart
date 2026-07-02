import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import 'generated/generated_proto.pb.dart' as pb;
import 'generated/bindings.dart' as ffi;

class NativeBridge {
  final ffi.RustLibBindings _bindings;
  int _nextTaskId = 0;
  final Map<int, Completer<pb.FFIResult>> _pendingRequests = {};
  late final NativeCallable<Void Function(Uint64, ffi.Bytes)> _globalCallback;

  NativeBridge(this._bindings) {
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
    void Function(
      int taskId,
      ffi.FfiCallback callback,
    ) ffiAction,
  ) {
    final taskId = _nextTaskId++;
    final completer = Completer<pb.FFIResult>();
    _pendingRequests[taskId] = completer;
    ffiAction(taskId, _globalCallback.nativeFunction);
    return completer.future;
  }

  Future<pb.FFIResult> _executeWithMsg<T extends $pb.GeneratedMessage>(
    T request,
    void Function(
      int taskId,
      ffi.Bytes message,
      ffi.FfiCallback callback,
    ) ffiAction,
  ) {
    final pbBytes = request.writeToBuffer();
    final nativeBuffer = malloc.allocate<Uint8>(pbBytes.length);
    final requestBytes = malloc.allocate<ffi.Bytes>(1);

    try {
      final pointerList = nativeBuffer.asTypedList(pbBytes.length);
      pointerList.setAll(0, pbBytes);

      requestBytes.ref.ptr = nativeBuffer;
      requestBytes.ref.len = pbBytes.length;

      return _executeAsync((id, cb) {
        ffiAction(id, requestBytes.ref, cb);
      });
    } finally {
      malloc.free(nativeBuffer);
      malloc.free(requestBytes);
    }
  }

  Future<pb.FFIResult> initialize() {
    return _executeAsync((id, cb) {
      _bindings.initialize(id, cb);
    });
  }

  Future<pb.FFIResult> processSource(pb.Source source) {
    return _executeWithMsg(source, (id, msg, cb) {
      _bindings.process_source(id, cb, msg);
    });
  }

  Future<pb.FFIResult> refreshSource(pb.Source source) {
    return _executeWithMsg(source, (id, msg, cb) {
      _bindings.refresh_source(id, cb, msg);
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
  }
}
