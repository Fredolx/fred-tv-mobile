import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:video_player/video_player.dart';

class Player extends StatefulWidget {
  final Channel channel;
  const Player({super.key, required this.channel});

  @override
  State<StatefulWidget> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.channel.url!))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Chewie(
          controller: ChewieController(
              videoPlayerController: _controller,
              looping: true,
              isLive: widget.channel.mediaType == MediaType.livestream,
              allowPlaybackSpeedChanging: false,
              additionalOptions: (context) => [
                    OptionItem(
                      onTap: (_) => debugPrint('My option works!'),
                      iconData: Icons.chat,
                      title: 'My localized title',
                    )
                  ],
              autoPlay: true),
        ));
  }
}
