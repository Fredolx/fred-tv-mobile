import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_tv/backend/settings_service.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/backend/utils.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool blockSettings = false;
  int? previousScroll;
  bool scrolledDeepEnough = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    initializeAsync();
  }

  Future<void> initializeAsync() async {
    if (widget.home.filters.sourceIds == null) {
      final sources = await Sql.getEnabledSourcesMinimal();
      widget.home.filters.sourceIds = sources.map((x) => x.id).toList();
    }
    if (widget.home.filters.mediaTypes == null) {
      widget.home.filters.mediaTypes = (await SettingsService.getSettings())
          .getMediaTypes();
    }
    await load();
    final String? version = await SettingsService.shouldShowWhatsNew();
    if (widget.firstLaunch && version != null) {
      await showWhatsNew(version);
    }
    if (widget.refresh) {
      Error.tryAsyncNoLoading(
        () async {
          setState(() {
            blockSettings = true;
          });
          await Utils.refreshAllSources();
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
      List<Channel> channels = await Sql.search(widget.home.filters);
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
                          style: TextStyle(
                            fontSize:
                                Theme.of(
                                  context,
                                ).textTheme.titleMedium?.fontSize ??
                                40,
                          ),
                          controller: searchController,
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
                              fontSize:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.fontSize ??
                                  40,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size:
                                  (Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.fontSize ??
                                      40) *
                                  1.5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              iconSize:
                                  (Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.fontSize ??
                                      40) *
                                  1.5,
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
