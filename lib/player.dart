import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
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
  late mkvideo.VideoController videoController =
      mkvideo.VideoController(player);
  late final GlobalKey<VideoState> key = GlobalKey<VideoState>();
  @override
  void initState() {
    super.initState();
    mk.MediaKit.ensureInitialized();
    initAsync();
  }

  initAsync() async {
    await player.open(mk.Media(widget.channel.url!));
    await player.setPlaylistMode(mk.PlaylistMode.single);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await key.currentState?.enterFullscreen();
    });
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
          normal: const MaterialVideoControlsThemeData(),
          fullscreen: MaterialVideoControlsThemeData(
              speedUpOnLongPress: false,
              seekOnDoubleTap: widget.channel.mediaType != MediaType.livestream,
              displaySeekBar: widget.channel.mediaType != MediaType.livestream,
              seekBarMargin: const EdgeInsets.only(bottom: 60),
              seekGesture: widget.channel.mediaType != MediaType.livestream),
          child: Video(
              key: key,
              controller: videoController,
              onExitFullscreen: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                SystemChrome.setPreferredOrientations([]);
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              }),
        ));
  }
}
