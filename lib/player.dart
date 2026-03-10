import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:open_tv/backend/settings_service.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/id_data.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/settings.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mkvideo;
import 'package:open_tv/select_dialog.dart';

class Player extends StatefulWidget {
  final Channel channel;
  const Player({super.key, required this.channel});
  @override
  State<StatefulWidget> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late mk.Player player = mk.Player();
  mkvideo.VideoController? videoController;
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
    final settings = await SettingsService.getSettings();
    final vo =
        settings.videoOutput == 'direct' ? 'mediacodec_embed' : null;
    videoController = mkvideo.VideoController(
      player,
      configuration: mkvideo.VideoControllerConfiguration(
        vo: vo,
        hwdec: settings.hwdec,
        enableHardwareAcceleration: true,
        androidAttachSurfaceAfterVideoParameters: true,
      ),
    );
    setState(() {});
    await _applyMpvProperties(settings);
    final seconds = widget.channel.mediaType == MediaType.movie
        ? await Sql.getPosition(widget.channel.id!)
        : null;
    await _startPlayback(seconds != null ? Duration(seconds: seconds) : null);

    void onDisconnect() async {
      if (!mounted || exiting) return;
      if (widget.channel.mediaType == MediaType.livestream) {
        debugPrint("Live stream dropped/error. Attempting to reconnect...");
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted || exiting) return;
        await _startPlayback(null);
      }
    }

    subscriptions.add(player.stream.completed.listen((completed) {
      if (completed) onDisconnect();
    }));

    subscriptions.add(player.stream.error.listen((error) async {
      debugPrint("Stream error: $error");
      await Future.delayed(const Duration(seconds: 2));
      if (!player.state.playing) {
        onDisconnect();
      }
    }));
  }

  Future<void> _applyMpvProperties(Settings settings) async {
    try {
      final nativePlayer = player.platform as dynamic;
      await nativePlayer.setProperty('profile', 'fast');
      await nativePlayer.setProperty('deband', 'no');
      await nativePlayer.setProperty('framedrop', 'vo');
      await nativePlayer.setProperty('video-latency-hacks', 'yes');
      await nativePlayer.setProperty('cache', 'yes');
      await nativePlayer.setProperty(
          'cache-secs', settings.bufferSeconds.toString());
      await nativePlayer.setProperty('demuxer-max-bytes', '150MiB');
      await nativePlayer.setProperty('demuxer-max-back-bytes', '50MiB');
    } catch (e) {
      debugPrint('Failed to set mpv properties: $e');
    }
  }

  Future<void> _startPlayback(Duration? startPosition) async {
    while (true) {
      if (!mounted || exiting) return;
      try {
        final headers = await Sql.getChannelHeaders(widget.channel.id!);
        await player.open(mk.Media(widget.channel.url!,
            start: startPosition,
            httpHeaders: headers != null
                ? {
                    if (headers.referrer != null) "Referer": headers.referrer!,
                    if (headers.httpOrigin != null)
                      "Origin": headers.httpOrigin!,
                    if (headers.userAgent != null)
                      "User-Agent": headers.userAgent!,
                  }
                : null));
        await key.currentState?.enterFullscreen();
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
                .map((entry) => IdData(
                    id: entry.key,
                    data: entry.value.language != null
                        ? "${entry.value.language} - ${entry.value.id}"
                        : entry.value.id))
                .toList()));
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
                .map((entry) => IdData(
                    id: entry.key,
                    data: entry.value.title ??
                        entry.value.language ??
                        entry.value.id))
                .toList()));
  }

  @override
  Widget build(BuildContext context) {
    final vc = videoController;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          onExit();
        },
        child: Scaffold(
            backgroundColor: Colors.black,
            body: vc == null
                ? const Center(child: CircularProgressIndicator())
                : MaterialVideoControlsTheme(
                    normal: getThemeData(context),
                    fullscreen: getThemeData(context),
                    child: Video(
                      key: key,
                      controller: vc,
                      onExitFullscreen: () async => onExit(),
                    ),
                  )));
  }

  void onExit() async {
    if (exiting) return;
    exiting = true;
    if (widget.channel.mediaType == MediaType.movie) {
      Sql.setPosition(widget.channel.id!, player.state.position.inSeconds);
    }
    if (key.currentState!.isFullscreen()) {
      await key.currentState!.exitFullscreen();
    }
    Navigator.of(context).pop();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void toggleZoom() {
    final videoAspectRatio = player.state.width! / player.state.height!;
    final deviceAspectRatio = MediaQuery.of(context).size.aspectRatio;
    key.currentState!
        .update(aspectRatio: fill ? videoAspectRatio : deviceAspectRatio);
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
          SizedBox(
            width: 20,
          ),
          IconButton(
            onPressed: openAudioModal,
            icon: const Icon(Icons.music_note, color: Colors.white, size: 32),
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            icon: Icon(Icons.aspect_ratio_outlined,
                color: Colors.white, size: 32),
            onPressed: toggleZoom,
          ),
        ]);
  }
}
