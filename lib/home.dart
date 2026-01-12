import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final bool autofocusBottomNav;
  const Home(
      {super.key,
      required this.home,
      this.refresh = false,
      this.autofocusBottomNav = false,
      this.firstLaunch = false});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _debounce;
  bool reachedMax = false;
  final int pageSize = 36;
  List<Channel> channels = [];
  bool searchMode = false;
  final FocusNode _focusNode = FocusNode();
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool blockSettings = false;
  int? previousScroll;
  final FocusNode _bottomNavFocusNode = FocusNode();

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
      widget.home.filters.mediaTypes =
          (await SettingsService.getSettings()).getMediaTypes();
    }
    await load();
    final String? version = await SettingsService.shouldShowWhatsNew();
    if (widget.firstLaunch && version != null) {
      await showWhatsNew(version);
    }
    if (widget.refresh) {
      Error.tryAsyncNoLoading(() async {
        setState(() {
          blockSettings = true;
        });
        await Utils.refreshAllSources();
      }, context, true, "Refreshed all sources");
      setState(() {
        blockSettings = false;
      });
    }
  }

  Future<void> showWhatsNew(String version) async {
    showDialog(
        context: context,
        builder: (context) => WhatsNewModal(version: version));
  }

  void toggleSearch() {
    setState(() {
      searchMode = !searchMode;
    });
    if (searchMode) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => FocusScope.of(context).requestFocus(_focusNode));
    } else {
      FocusScope.of(context).unfocus();
      widget.home.filters.query = null;
      searchController.clear();
      _scrollController.jumpTo(0);
      load(false);
    }
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
    _focusNode.dispose();
    _bottomNavFocusNode.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() async {
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

  void handleBack() {
    toggleSearch();
  }

  bool canPop() {
    return !searchMode;
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
                autofocusBottomNav: true,
                home: HomeManager(
                    filters: Filters(
                        viewType: type,
                        mediaTypes: widget.home.filters.mediaTypes,
                        sourceIds: widget.home.filters.sourceIds)))),
        (route) => false);
  }

  void setNode(Node node) {
    final home = HomeManager(
        node: node,
        filters: Filters(
            viewType: ViewType.all,
            mediaTypes: widget.home.filters.mediaTypes,
            sourceIds: widget.home.filters.sourceIds));
    if (widget.home.filters.groupId != null) {
      home.filters.groupId = widget.home.filters.groupId;
    } else if (node.type == NodeType.category) {
      home.filters.groupId = node.id;
    }
    if (node.type == NodeType.series) home.filters.seriesId = node.id;
    Navigator.of(context).push(NoPushAnimationMaterialPageRoute(
        builder: (context) => Home(home: home)));
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.contextMenu): () {
            debugPrint("test");
            _bottomNavFocusNode.requestFocus();
          }
        },
        child: PopScope(
            canPop: canPop(),
            onPopInvokedWithResult: (didPop, result) {
              handleBack();
            },
            child: Scaffold(
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
                        child: Column(children: [
                  AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: searchMode
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer, // Background color
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceBright,
                                          width: 1))),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: TextField(
                                    controller: searchController,
                                    focusNode: _focusNode,
                                    onChanged: (query) {
                                      _debounce?.cancel();
                                      _debounce = Timer(
                                          const Duration(milliseconds: 500),
                                          () {
                                        widget.home.filters.query = query;
                                        load(false);
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Search...",
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            widget.home.filters.useKeywords =
                                                !widget
                                                    .home.filters.useKeywords;
                                            load(false);
                                          },
                                          icon: Icon(
                                              widget.home.filters.useKeywords
                                                  ? Icons.label
                                                  : Icons.label_outline)),
                                      filled:
                                          true, // Light background for contrast
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0),
                                    ),
                                  )),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                      width: 40,
                                      child: IconButton(
                                          onPressed: toggleSearch,
                                          icon: const Icon(
                                            Icons.close,
                                          )))
                                ],
                              ),
                            )
                          : const SizedBox.shrink()),
                  Expanded(
                      child: GridView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 5),
                    itemCount: channels.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 315,
                      mainAxisExtent: 120,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final channel = channels[index];
                      return ChannelTile(
                        channel: channel,
                        parentContext: context,
                        setNode: setNode,
                        onFocusNavbar: () => _bottomNavFocusNode.requestFocus(),
                      );
                    },
                  )),
                ]))),
                bottomNavigationBar: BottomNav(
                  startingView: getStartingView(),
                  blockSettings: blockSettings,
                  updateViewMode: updateViewMode,
                  navFocusNode: _bottomNavFocusNode,
                  autofocus: widget.autofocusBottomNav,
                ),
                floatingActionButton: Visibility(
                  visible: !searchMode,
                  child: FloatingActionButton(
                    onPressed: toggleSearch,
                    tooltip: 'Search',
                    child: const Icon(Icons.search),
                  ),
                ))));
  }
}
