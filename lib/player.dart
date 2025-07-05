import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/home.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mkvideo;

class Player extends StatefulWidget {
  final Channel channel;
  const Player({super.key, required this.channel});
  @override
  State<StatefulWidget> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late mk.Player player = mk.Player();
  late StreamSubscription<Duration> subscription;
  late mkvideo.VideoController videoController =
      mkvideo.VideoController(player);
  late final GlobalKey<VideoState> key = GlobalKey<VideoState>();
  @override
  void initState() {
    super.initState();
    mk.MediaKit.ensureInitialized();
    initAsync();
  }

  Future<void> initAsync() async {
    final seconds = widget.channel.mediaType == MediaType.movie
        ? await Sql.getPosition(widget.channel.id!)
        : null;
    await player.open(mk.Media(
      widget.channel.url!,
      start: seconds != null ? Duration(seconds: seconds) : null,
    ));
    await key.currentState?.enterFullscreen();
    player.setPlaylistMode(mk.PlaylistMode.single);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: MaterialVideoControlsTheme(
          normal: getThemeData(context),
          fullscreen: getThemeData(context),
          child: Video(
            key: key,
            controller: videoController,
            onExitFullscreen: () async => onExit(),
          ),
        ));
  }

  void onExit() async {
    if (widget.channel.mediaType == MediaType.movie) {
      Sql.setPosition(widget.channel.id!, player.state.position.inSeconds);
    }
    await key.currentState!.exitFullscreen();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Home()));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
    );
  }
}
