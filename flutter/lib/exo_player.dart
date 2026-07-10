import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:open_tv/error.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/channel_http_headers.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/settings.dart';
import 'package:open_tv/native_bridge.dart';

/// Native Media3/ExoPlayer screen used only on Android. Every other platform
/// keeps the media_kit [Player]. Orchestration (headers, positions, exit) stays
/// in Dart; the native [PlatformView] only renders and drives the controls.
class ExoPlayerScreen extends StatefulWidget {
  final Channel channel;
  final Settings settings;
  const ExoPlayerScreen({
    super.key,
    required this.channel,
    required this.settings,
  });

  @override
  State<ExoPlayerScreen> createState() => _ExoPlayerScreenState();
}

class _ExoPlayerScreenState extends State<ExoPlayerScreen> {
  static const _viewType = "dev.fredol.open_tv/exoplayer";

  MethodChannel? _channel;
  bool _exiting = false;
  bool _ready = false;
  Map<String, dynamic> _creationParams = const {};

  bool get _isLive => widget.channel.mediaType == MediaType.livestream;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _init();
  }

  Future<void> _init() async {
    final ChannelHttpHeaders? headers = (await Error.tryAsyncNoLoading(() async {
      return await NativeBridge.instance.getChannelHeaders(widget.channel.id!);
    }, context)).data;
    final seconds = widget.channel.mediaType == MediaType.movie
        ? (await Error.tryAsyncNoLoading(() async {
            return await NativeBridge.instance.getMoviePosition(
              widget.channel.id!,
            );
          }, context)).data
        : null;
    if (!mounted) return;
    setState(() {
      _creationParams = {
        "url": widget.channel.url,
        "isLive": _isLive,
        "startPositionMs": (seconds ?? 0) * 1000,
        "title": widget.channel.name,
        "referer": headers?.referrer,
        "origin": headers?.httpOrigin,
        "userAgent": headers?.userAgent,
      };
      _ready = true;
    });
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel("dev.fredol.open_tv/exoplayer_$id");
    _channel!.setMethodCallHandler((call) async {
      if (call.method == "onBack") {
        _onExit();
      }
      return null;
    });
  }

  Future<void> _onExit() async {
    if (_exiting) return;
    _exiting = true;
    if (widget.channel.mediaType == MediaType.movie && _channel != null) {
      try {
        final posMs = await _channel!.invokeMethod<int>("getPosition") ?? 0;
        await NativeBridge.instance.setMoviePosition(
          widget.channel.id!,
          posMs ~/ 1000,
        );
      } catch (_) {
        // Best-effort; never block exit on position persistence.
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onExit();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _ready ? _buildPlatformView() : const SizedBox.shrink(),
      ),
    );
  }

  // D-pad / focus handling for Android TV lives entirely in native Kotlin
  // (MainActivity.dispatchKeyEvent -> ExoPlayerView), so Flutter's focus system
  // stays out of the way for this screen.
  Widget _buildPlatformView() {
    return PlatformViewLink(
      viewType: _viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        final controller = PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () => params.onFocusChanged(true),
        );
        controller.addOnPlatformViewCreatedListener(params.onPlatformViewCreated);
        controller.addOnPlatformViewCreatedListener(_onPlatformViewCreated);
        controller.create();
        return controller;
      },
    );
  }
}
