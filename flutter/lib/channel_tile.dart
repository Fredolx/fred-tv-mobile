import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_tv/memory.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/error.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/node.dart';
import 'package:open_tv/models/node_type.dart';
import 'package:open_tv/native_bridge.dart';
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
      await NativeBridge.instance.favorite(
        widget.channel.id!,
        !widget.channel.favorite,
      );
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

  Future<int?> _handleSeries() async {
    if (widget.channel.url?.isEmpty == true) {
      if (context.mounted) {
        Error.handleError(context, "Invalid series: series ID is null");
      }
      return null;
    }
    final seriesId = int.tryParse(widget.channel.url!);
    if (seriesId == null) {
      if (context.mounted) {
        Error.handleError(
          context,
          "Invalid series: series ID is not a valid number",
        );
      }
      return null;
    }
    await Error.tryAsync(
      () async {
        await NativeBridge.instance.getEpisodes(
          seriesId,
          widget.channel.sourceId,
          widget.channel.image,
        );
        refreshedSeries.add(seriesId);
      },
      widget.parentContext,
      null,
      true,
      false,
    );
    return seriesId;
  }

  Future<void> play() async {
    late final int? seriesId;
    if (widget.channel.mediaType == MediaType.serie) {
      seriesId = await _handleSeries();
      if (seriesId == null) return;
    }

    if (widget.channel.mediaType == MediaType.group ||
        widget.channel.mediaType == MediaType.serie ||
        widget.channel.mediaType == MediaType.season) {
      widget.setNode(
        Node(
          id: widget.channel.mediaType == MediaType.group ||
                  widget.channel.mediaType == MediaType.season
              ? widget.channel.id!
              : seriesId!,
          name: widget.channel.name,
          type: fromMediaType(widget.channel.mediaType),
        ),
      );
    } else {
      var settings = await NativeBridge.instance.getSettings();
      NativeBridge.instance.addLastWatched(widget.channel.id!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Player(channel: widget.channel, settings: settings),
        ),
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
                            size: 45,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(Icons.tv, size: 45, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.channel.name,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Theme.of(
                        context,
                      ).textTheme.titleMedium?.fontSize!,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.channel.favorite)
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Center(
                  child: const Icon(Icons.star, size: 25, color: Colors.amber),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
