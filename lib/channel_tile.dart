import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_tv/models/channel.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: _focusNode.hasFocus ? 8.0 : 4.0, // Highlight when focused
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: _focusNode.hasFocus ? Colors.blue.shade100 : Colors.white,
        child: InkWell(
          focusNode: _focusNode,
          onTap: () => print("Selected ${widget.channel.name}"),
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
