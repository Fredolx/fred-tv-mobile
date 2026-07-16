import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_tv/native_bridge.dart';
import 'package:open_tv/bottom_nav.dart';
import 'package:open_tv/channel_tile.dart';
import 'package:open_tv/loading.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/filters.dart';
import 'package:open_tv/models/home_manager.dart';
import 'package:open_tv/models/no_push_animation_material_page_route.dart';
import 'package:open_tv/models/node.dart';
import 'package:open_tv/models/node_type.dart';
import 'package:open_tv/models/view_type.dart';
import 'package:open_tv/error.dart';
import 'package:open_tv/whats_new_modal.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Home extends StatefulWidget {
  final HomeManager home;
  final bool refresh;
  final bool firstLaunch;
  final bool hasTouchScreen;
  const Home({
    super.key,
    required this.home,
    this.refresh = false,
    this.firstLaunch = false,
    this.hasTouchScreen = true,
  });
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _debounce;
  bool reachedMax = false;
  final int pageSize = 36;
  List<Channel> channels = [];
  TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _keywordsFocusNode = FocusNode(skipTraversal: true);
  final FocusNode _sortFocusNode = FocusNode(skipTraversal: true);
  final ScrollController _scrollController = ScrollController();
  int currentlyFocusedChannel = 0;
  bool isLoading = false;
  bool blockSettings = false;
  int? previousScroll;
  bool scrolledDeepEnough = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchFocusNode.onKeyEvent = _handleSearchKeyEvent;
    _keywordsFocusNode.onKeyEvent = _handleKeywordsKeyEvent;
    _sortFocusNode.onKeyEvent = _handleSortKeyEvent;
    initializeAsync();
  }

  Future<void> initializeAsync() async {
    if (widget.home.filters.sourceIds == null) {
      final sources = await NativeBridge.instance.getEnabledSourcesMinimal();
      widget.home.filters.sourceIds = sources;
    }
    if (widget.home.filters.mediaTypes == null) {
      widget.home.filters.mediaTypes =
          (await NativeBridge.instance.getSettings()).getMediaTypes();
    }
    await load();
    var version = (await PackageInfo.fromPlatform()).version;
    if (widget.firstLaunch &&
        await NativeBridge.instance.shouldShowWhatsNew(version)) {
      await showWhatsNew(version);
    }
    if (widget.refresh) {
      Error.tryAsyncNoLoading(
        () async {
          setState(() {
            blockSettings = true;
          });
          await NativeBridge.instance.refreshAll();
        },
        context,
        true,
        "Refreshed all sources",
      );
      setState(() {
        blockSettings = false;
      });
    }
  }

  Future<void> showWhatsNew(String version) async {
    showDialog(
      context: context,
      builder: (context) => WhatsNewModal(version: version),
    );
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> load([bool more = false]) async {
    if (more) {
      widget.home.filters.page++;
    } else {
      widget.home.filters.page = 1;
    }
    await Error.tryAsyncNoLoading(() async {
      List<Channel> channels = await NativeBridge.instance.getChannels(
        widget.home.filters,
      );
      if (!more) {
        setState(() {
          this.channels = channels;
        });
      } else {
        setState(() {
          this.channels.addAll(channels);
        });
      }
      reachedMax = channels.length < pageSize;
    }, context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    _searchFocusNode.dispose();
    _keywordsFocusNode.dispose();
    _sortFocusNode.dispose();
    super.dispose();
  }

  void _scrollListener() async {
    final bool shouldShow = _scrollController.offset > 200;

    if (scrolledDeepEnough != shouldShow) {
      setState(() => scrolledDeepEnough = shouldShow);
    }

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.75 &&
        !isLoading &&
        !reachedMax) {
      setState(() {
        isLoading = true;
      });
      await load(true);
      setState(() {
        isLoading = false;
      });
    }
  }

  void clearSearch() {
    widget.home.filters.query = null;
    searchController.clear();
  }

  bool _focusChannelsBelow() {
    return FocusScope.of(context).focusInDirection(TraversalDirection.down);
  }

  KeyEventResult _handleSearchKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.escape ||
          key == LogicalKeyboardKey.goBack) {
        bool moved = FocusScope.of(
          context,
        ).focusInDirection(TraversalDirection.down);
        if (!moved) {
          node.unfocus();
        }
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        bool moved = FocusScope.of(
          context,
        ).focusInDirection(TraversalDirection.down);
        if (moved) {
          return KeyEventResult.handled;
        }
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        _keywordsFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleKeywordsKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.arrowLeft) {
        _searchFocusNode.requestFocus();
        searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length),
        );
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        _sortFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        bool moved = FocusScope.of(
          context,
        ).focusInDirection(TraversalDirection.down);
        if (moved) {
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleSortKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.arrowLeft) {
        _keywordsFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        bool moved = FocusScope.of(
          context,
        ).focusInDirection(TraversalDirection.down);
        if (moved) {
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  ViewType getStartingView() {
    if (widget.home.filters.groupId != null) {
      return ViewType.categories;
    }
    return widget.home.filters.viewType;
  }

  void updateViewMode(ViewType type) {
    Navigator.of(context).pushAndRemoveUntil(
      NoPushAnimationMaterialPageRoute(
        builder: (context) => Home(
          home: HomeManager(
            filters: Filters(
              viewType: type,
              mediaTypes: widget.home.filters.mediaTypes,
              sourceIds: widget.home.filters.sourceIds,
            ),
          ),
        ),
      ),
      (route) => false,
    );
  }

  void setNode(Node node) {
    final home = HomeManager(
      node: node,
      filters: Filters(
        viewType: ViewType.all,
        mediaTypes: widget.home.filters.mediaTypes,
        sourceIds: widget.home.filters.sourceIds,
      ),
    );
    if (widget.home.filters.groupId != null) {
      home.filters.groupId = widget.home.filters.groupId;
    } else if (node.type == NodeType.category) {
      home.filters.groupId = node.id;
    }
    if (node.type == NodeType.series) home.filters.seriesId = node.id;
    if (node.type == NodeType.season) {
      home.filters.seriesId = widget.home.filters.seriesId;
      home.filters.seasonId = node.id;
    }
    Navigator.of(context).push(
      NoPushAnimationMaterialPageRoute(builder: (context) => Home(home: home)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.home.node != null
          ? AppBar(
              title: Text(widget.home.node.toString()),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Loading(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final int crossAxisCount = (width / 350).floor().clamp(1, 3);
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: TextField(
                          focusNode: _searchFocusNode,
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.titleMedium?.fontSize!,
                          ),
                          controller: searchController,
                          textInputAction: TextInputAction.search,
                          onEditingComplete: _focusChannelsBelow,
                          onChanged: (query) {
                            _debounce?.cancel();
                            _debounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                widget.home.filters.query = query;
                                load(false);
                              },
                            );
                          },
                          decoration: InputDecoration(
                            hintText: "Search...",
                            hintStyle: TextStyle(
                              fontSize: Theme.of(
                                context,
                              ).textTheme.titleMedium?.fontSize!,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  focusNode: _keywordsFocusNode,
                                  onPressed: () {
                                    widget.home.filters.useKeywords =
                                        !widget.home.filters.useKeywords;
                                    load(false);
                                  },
                                  icon: Icon(
                                    widget.home.filters.useKeywords
                                        ? Icons.label
                                        : Icons.label_outline,
                                  ),
                                ),
                                IconButton(
                                  focusNode: _sortFocusNode,
                                  onPressed: () {},
                                  icon: const Icon(Icons.sort),
                                ),
                              ],
                            ),
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final channel = channels[index];
                        return ChannelTile(
                          channel: channel,
                          parentContext: context,
                          setNode: setNode,
                          autofocus: index == currentlyFocusedChannel,
                          onSelect: () => currentlyFocusedChannel = index,
                        );
                      }, childCount: channels.length),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisExtent: 100,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: widget.hasTouchScreen
          ? BottomNav(
              startingView: getStartingView(),
              blockSettings: blockSettings,
              updateViewMode: updateViewMode,
            )
          : null,
      floatingActionButton: IgnorePointer(
        ignoring: !scrolledDeepEnough,
        child: AnimatedOpacity(
          opacity: scrolledDeepEnough ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: FloatingActionButton(
            onPressed: scrollToTop,
            shape: const CircleBorder(),
            tooltip: 'Scroll to Top',
            child: const Icon(Icons.arrow_upward),
          ),
        ),
      ),
    );
  }
}
