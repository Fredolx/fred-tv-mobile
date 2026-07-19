import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/id_data.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mkvideo;
import 'package:open_tv/models/settings.dart';
import 'package:open_tv/native_bridge.dart';
import 'package:open_tv/select_dialog.dart';
import 'package:open_tv/error.dart';

class Player extends StatefulWidget {
  final Channel channel;
  final Settings settings;
  const Player({super.key, required this.channel, required this.settings});
  @override
  State<StatefulWidget> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late mk.Player player = mk.Player();
  late mkvideo.VideoController videoController = mkvideo.VideoController(
    player,
  );
  late final GlobalKey<VideoState> key = GlobalKey<VideoState>();
  bool exiting = false;
  bool fill = false;
  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    mk.MediaKit.ensureInitialized();
    initAsync();
  }

  Future<void> initAsync() async {
    player.setPlaylistMode(mk.PlaylistMode.none);
    await setMpvOptions();
    final seconds = widget.channel.mediaType == MediaType.movie
        ? (await Error.tryAsyncNoLoading(() async {
            return await NativeBridge.instance.getMoviePosition(
              widget.channel.id!,
            );
          }, context)).data
        : null;
    await _startPlayback(seconds != null ? Duration(seconds: seconds) : null);
    subscriptions.add(
      player.stream.completed.listen((completed) {
        if (completed) onDisconnect();
      }),
    );
  }

  Future<void> setMpvOptions() async {
    if (player.platform is mk.NativePlayer) {
      final nativePlayer = player.platform as mk.NativePlayer;
      if (widget.channel.mediaType == MediaType.livestream) {
        if (widget.settings.lowLatency) {
          await nativePlayer.setProperty('profile', 'low-latency');
        }
      }
    }
  }

  void onDisconnect() async {
    if (!mounted || exiting) return;
    if (widget.channel.mediaType == MediaType.livestream) {
      debugPrint("Live stream dropped/error. Attempting to reconnect...");
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || exiting) return;
      await _startPlayback(null);
    }
  }

  Future<void> _startPlayback(Duration? startPosition) async {
    while (true) {
      if (!mounted || exiting) return;
      try {
        final headers = (await Error.tryAsyncNoLoading(() async {
          return await NativeBridge.instance.getChannelHeaders(
            widget.channel.id!,
          );
        }, context)).data;
        await player.open(
          mk.Media(
            widget.channel.url!,
            start: startPosition,
            httpHeaders: headers != null
                ? {
                    if (headers.referrer != null) "Referer": headers.referrer!,
                    if (headers.httpOrigin != null)
                      "Origin": headers.httpOrigin!,
                    if (headers.userAgent != null)
                      "User-Agent": headers.userAgent!,
                  }
                : null,
          ),
        );
        if (Platform.isAndroid || Platform.isIOS) {
          await key.currentState?.enterFullscreen();
        }
        return;
      } catch (e) {
        debugPrint("Playback failed: $e. Retrying in 2s...");
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  @override
  void dispose() {
    for (final s in subscriptions) s.cancel();
    player.dispose();
    super.dispose();
  }

  Future<void> openSubtitlesModal() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SelectDialog(
        title: "Select subtitles",
        action: (id) async {
          player.setSubtitleTrack(player.state.tracks.subtitle[id]);
          Navigator.of(context).pop();
        },
        data: player.state.tracks.subtitle
            .asMap()
            .entries
            .map(
              (entry) => IdData(
                id: entry.key,
                data: entry.value.language != null
                    ? "${entry.value.language} - ${entry.value.id}"
                    : entry.value.id,
              ),
            )
            .toList(),
        previouslySelectedId: player.state.tracks.subtitle.indexOf(
          player.state.track.subtitle,
        ),
      ),
    );
  }

  Future<void> openAudioModal() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SelectDialog(
        title: "Select audio",
        action: (id) async {
          player.setAudioTrack(player.state.tracks.audio[id]);
          Navigator.of(context).pop();
        },
        data: player.state.tracks.audio
            .asMap()
            .entries
            .map(
              (entry) => IdData(
                id: entry.key,
                data:
                    entry.value.title ?? entry.value.language ?? entry.value.id,
              ),
            )
            .toList(),
        previouslySelectedId: player.state.tracks.audio.indexOf(
          player.state.track.audio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        onExit();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: MaterialVideoControlsTheme(
          normal: getThemeData(context),
          fullscreen: getThemeData(context),
          child: MaterialDesktopVideoControlsTheme(
            normal: getDesktopThemeData(context),
            fullscreen: getDesktopThemeData(context),
            child: Video(
              key: key,
              controller: videoController,
              onExitFullscreen: (Platform.isAndroid || Platform.isIOS)
                  ? () async => onExit()
                  : defaultExitNativeFullscreen,
              controls: AdaptiveVideoControls,
            ),
          ),
        ),
      ),
    );
  }

  void onExit() async {
    if (exiting) return;
    exiting = true;
    if (widget.channel.mediaType == MediaType.movie) {
      NativeBridge.instance.setMoviePosition(
        widget.channel.id!,
        player.state.position.inSeconds,
      );
    }
    if (key.currentState!.isFullscreen()) {
      await key.currentState!.exitFullscreen();
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void toggleZoom() {
    final videoAspectRatio = player.state.width! / player.state.height!;
    final deviceAspectRatio = MediaQuery.of(context).size.aspectRatio;
    key.currentState!.update(
      aspectRatio: fill ? videoAspectRatio : deviceAspectRatio,
    );
    setState(() {
      fill = !fill;
    });
  }

  MaterialVideoControlsThemeData getThemeData(BuildContext context) {
    return MaterialVideoControlsThemeData(
      speedUpOnLongPress: false,
      seekOnDoubleTap: widget.channel.mediaType != MediaType.livestream,
      displaySeekBar: widget.channel.mediaType != MediaType.livestream,
      seekBarMargin: const EdgeInsets.only(bottom: 60),
      seekBarThumbSize: 20,
      seekBarHeight: 10,
      seekGesture: widget.channel.mediaType != MediaType.livestream,
      topButtonBar: [
        IconButton(
          onPressed: onExit,
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 10),
        Text(widget.channel.name),
      ],
      bottomButtonBar: [
        IconButton(
          onPressed: openSubtitlesModal,
          icon: const Icon(Icons.subtitles, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: openAudioModal,
          icon: const Icon(Icons.music_note, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(
            Icons.aspect_ratio_outlined,
            color: Colors.white,
            size: 32,
          ),
          onPressed: toggleZoom,
        ),
        if (!(Platform.isAndroid || Platform.isIOS)) ...[
          const Spacer(),
          const MaterialFullscreenButton(iconSize: 32, iconColor: Colors.white),
        ],
      ],
    );
  }

  MaterialDesktopVideoControlsThemeData getDesktopThemeData(
    BuildContext context,
  ) {
    return MaterialDesktopVideoControlsThemeData(
      seekBarMargin: const EdgeInsets.only(bottom: 60),
      seekBarThumbSize: 20,
      seekBarHeight: 10,
      displaySeekBar: widget.channel.mediaType != MediaType.livestream,
      hideMouseOnControlsRemoval: true,
      controlsHoverDuration: const Duration(seconds: 3),
      topButtonBar: [
        IconButton(
          onPressed: onExit,
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 10),
        Text(widget.channel.name),
      ],
      bottomButtonBar: [
        IconButton(
          onPressed: openSubtitlesModal,
          icon: const Icon(Icons.subtitles, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: openAudioModal,
          icon: const Icon(Icons.music_note, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(
            Icons.aspect_ratio_outlined,
            color: Colors.white,
            size: 32,
          ),
          onPressed: toggleZoom,
        ),
        const Spacer(),
        const MaterialDesktopFullscreenButton(
          iconSize: 32,
          iconColor: Colors.white,
        ),
      ],
    );
  }
}
