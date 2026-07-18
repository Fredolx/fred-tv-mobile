import 'dart:async';
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
import 'package:open_tv/exo_player.dart';
import 'dart:io' show Platform;

class ChannelTile extends StatefulWidget {
  final Channel channel;
  final BuildContext parentContext;
  final Function(Node node) setNode;
  final VoidCallback? onFocusNavbar;
  final VoidCallback onSelect;
  final bool autofocus;
  const ChannelTile({
    super.key,
    required this.channel,
    required this.setNode,
    required this.parentContext,
    required this.onSelect,
    this.onFocusNavbar,
    this.autofocus = false,
  });

  @override
  State<ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<ChannelTile> {
  static final _selectionKeys = {
    LogicalKeyboardKey.select,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.numpadEnter,
  };

  final FocusNode _focusNode = FocusNode();
  final _statesController = WidgetStatesController();
  Timer? _longPressTimer;
  bool _longPressTriggered = false;
  bool _selectKeyDown = false;
  InteractiveInkFeature? _inkFeature;
  BuildContext? _innerContext;

  @override
  void initState() {
    super.initState();
    _focusNode.onKeyEvent = _handleKeyEvent;
    _focusNode.addListener(_handleFocusChange);
  }

  void _showSplash() {
    final context = _innerContext;
    if (context == null) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _inkFeature?.cancel();

    final theme = Theme.of(context);
    final splashFactory = theme.splashFactory;

    _inkFeature = splashFactory.create(
      controller: Material.of(context),
      referenceBox: renderBox,
      position: renderBox.size.center(Offset.zero),
      color: theme.splashColor,
      textDirection: Directionality.of(context),
      containedInkWell: true,
      rectCallback: () => Offset.zero & renderBox.size,
      borderRadius: BorderRadius.circular(12),
    );
  }

  void _confirmSplash() {
    _inkFeature?.confirm();
    _inkFeature = null;
  }

  void _cancelSplash() {
    _inkFeature?.cancel();
    _inkFeature = null;
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _longPressTimer?.cancel();
      _longPressTriggered = false;
      _selectKeyDown = false;
      _cancelSplash();
      _statesController.update(WidgetState.pressed, false);
    }
    setState(() {});
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (!FocusScope.of(context).focusInDirection(TraversalDirection.right)) {
        widget.onFocusNavbar?.call();
      }
      return KeyEventResult.handled;
    }

    if (_selectionKeys.contains(event.logicalKey)) {
      if (event is KeyDownEvent) {
        _selectKeyDown = true;
        _longPressTimer?.cancel();
        _statesController.update(WidgetState.pressed, true);
        _showSplash();
        _longPressTimer = Timer(const Duration(milliseconds: 500), () {
          _longPressTriggered = true;
          _confirmSplash();
          _statesController.update(WidgetState.pressed, false);
          favorite();
        });
      } else if (event is KeyUpEvent) {
        if (!_selectKeyDown) {
          return KeyEventResult.handled;
        }
        _selectKeyDown = false;
        _longPressTimer?.cancel();
        _statesController.update(WidgetState.pressed, false);
        _confirmSplash();
        if (!_longPressTriggered) {
          play();
        }
        _longPressTriggered = false;
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _cancelSplash();
    _statesController.dispose();
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
      if (!mounted) return;
      setState(() {
        widget.channel.favorite = !widget.channel.favorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          persist: false,
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
    widget.onSelect();
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
          id:
              widget.channel.mediaType == MediaType.group ||
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
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Platform.isAndroid
              ? ExoPlayerScreen(channel: widget.channel, settings: settings)
              : Player(channel: widget.channel, settings: settings),
        ),
      );
      if (mounted) _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _focusNode.hasFocus ? 8.0 : 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Builder(
        builder: (innerContext) {
          _innerContext = innerContext;
          return InkWell(
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            statesController: _statesController,
            borderRadius: BorderRadius.circular(12),
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
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Center(
                      child: Icon(Icons.star, size: 25, color: Colors.amber),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
