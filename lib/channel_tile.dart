import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/backend/xtream.dart';
import 'package:open_tv/memory.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/error.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/node.dart';
import 'package:open_tv/models/node_type.dart';
import 'package:open_tv/player.dart';

class ChannelTile extends StatefulWidget {
  final Channel channel;
  final BuildContext parentContext;
  final Function(Node node) setNode;
  final VoidCallback? onFocusNavbar;
  const ChannelTile({
    super.key,
    required this.channel,
    required this.setNode,
    required this.parentContext,
    this.onFocusNavbar,
  });

  @override
  State<ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<ChannelTile> {
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _focusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (!FocusScope.of(
          context,
        ).focusInDirection(TraversalDirection.right)) {
          widget.onFocusNavbar?.call();
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> favorite() async {
    if (widget.channel.mediaType == MediaType.group) return;
    await Error.tryAsyncNoLoading(() async {
      await Sql.favoriteChannel(widget.channel.id!, !widget.channel.favorite);
      setState(() {
        widget.channel.favorite = !widget.channel.favorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to favorites"),
          duration: Duration(milliseconds: 500),
        ),
      );
    }, context);
  }

  Future<void> play() async {
    if (widget.channel.mediaType == MediaType.group ||
        widget.channel.mediaType == MediaType.serie) {
      if (widget.channel.mediaType == MediaType.serie &&
          !refreshedSeries.contains(widget.channel.id)) {
        await Error.tryAsync(
          () async {
            await getEpisodes(widget.channel);
            refreshedSeries.add(widget.channel.id!);
          },
          widget.parentContext,
          null,
          true,
          false,
        );
      }
      widget.setNode(
        Node(
          id: widget.channel.mediaType == MediaType.group
              ? widget.channel.id!
              : int.parse(widget.channel.url!),
          name: widget.channel.name,
          type: fromMediaType(widget.channel.mediaType),
        ),
      );
    } else {
      Sql.addToHistory(widget.channel.id!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Player(channel: widget.channel)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _focusNode.hasFocus ? 8.0 : 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: InkWell(
        focusNode: _focusNode,
        onLongPress: favorite,
        onTap: () async => await play(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: widget.channel.image != null
                      ? CachedNetworkImage(
                          imageUrl: widget.channel.image!,
                          memCacheHeight: 300,
                          memCacheWidth: 300,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.tv,
                            size: 30,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(Icons.tv, size: 30, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.channel.name,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.channel.favorite)
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Icon(Icons.star, size: 18, color: Colors.amber),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
