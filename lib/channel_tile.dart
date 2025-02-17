import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/error.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/player.dart';

class ChannelTile extends StatefulWidget {
  final Channel channel;

  const ChannelTile({
    super.key,
    required this.channel,
  });

  @override
  State<ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<ChannelTile> {
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void favorite() async {
    if (widget.channel.mediaType == MediaType.group) return;
    await Error.tryAsyncNoLoading(() async {
      await Sql.favoriteChannel(widget.channel.id!, !widget.channel.favorite);
      setState(() {
        widget.channel.favorite = !widget.channel.favorite;
      });
    }, context);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: _focusNode.hasFocus ? 8.0 : 4.0, // Highlight when focused
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: _focusNode.hasFocus
            ? Colors.blue.shade100
            : widget.channel.favorite
                ? const Color(0xFFFFD700)
                : Colors.white,
        child: InkWell(
          focusNode: _focusNode,
          onLongPress: favorite,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => Player(channel: widget.channel))),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: widget.channel.image != null
                              ? CachedNetworkImage(
                                  fit: BoxFit.contain,
                                  imageUrl: widget.channel.image!,
                                )
                              : Image.asset(
                                  "assets/icon.png",
                                  fit: BoxFit.contain,
                                ))),
                  const Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                      flex: 8,
                      child: Text(
                        widget.channel.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ))
                ],
              )),
        ));
  }
}
