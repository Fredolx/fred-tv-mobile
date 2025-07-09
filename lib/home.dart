import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/backend/utils.dart';
import 'package:open_tv/bottom_nav.dart';
import 'package:open_tv/channel_tile.dart';
import 'package:open_tv/loading.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/filters.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/node.dart';
import 'package:open_tv/models/node_type.dart';
import 'package:open_tv/models/settings.dart';
import 'package:open_tv/models/snapshot.dart';
import 'package:open_tv/models/stack.dart' as fstack;
import 'package:open_tv/models/view_type.dart';
import 'package:open_tv/error.dart';

class Home extends StatefulWidget {
  final Settings? settings;
  final Snapshot? snapshot;
  const Home({super.key, this.settings, this.snapshot});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _debounce;
  Filters filters = Filters(
      sourceIds: [],
      mediaTypes: [MediaType.livestream, MediaType.movie, MediaType.serie],
      viewType: ViewType.all,
      page: 1,
      useKeywords: false);
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
  fstack.Stack nodeStack = fstack.Stack();

  @override
  void initState() {
    super.initState();
    bool restoreState = widget.snapshot != null;
    _scrollController.addListener(_scrollListener);
    if (widget.settings != null) {
      filters.viewType = widget.settings!.defaultView;
      filters.mediaTypes.clear();
      if (widget.settings?.showLivestreams == true) {
        filters.mediaTypes.add(MediaType.livestream);
      }
      if (widget.settings?.showMovies == true) {
        filters.mediaTypes.add(MediaType.movie);
      }
      if (widget.settings?.showSeries == true) {
        filters.mediaTypes.add(MediaType.serie);
      }
    } else if (restoreState) {
      filters = widget.snapshot!.filters;
      nodeStack = widget.snapshot!.stack;
      if (filters.query != null) {
        searchMode = true;
        searchController.text = filters.query!;
      }
    }
    initializeAsync(restoreState);
  }

  Future<void> initializeAsync(bool restoreState) async {
    if (!restoreState) {
      final sources = await Sql.getEnabledSourcesMinimal();
      filters.sourceIds = sources.map((x) => x.id).toList();
      if (widget.settings?.refreshOnStart == true) {
        refreshOnStart();
      }
    }
    await load();
  }

  Snapshot getSnapshot() {
    return Snapshot(stack: nodeStack, filters: filters);
  }

  Future<void> refreshOnStart() async {
    blockSettings = true;
    await Error.tryAsyncNoLoading(() async {
      await Utils.refreshAllSources();
    }, context, true, "Successfully refreshed all sources");
    setState(() {
      blockSettings = false;
    });
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
      filters.query = null;
      searchController.clear();
      _scrollController.jumpTo(0);
      load(false);
    }
  }

  Future<void> load([bool more = false]) async {
    if (more) {
      filters.page++;
    } else {
      filters.page = 1;
    }
    await Error.tryAsyncNoLoading(() async {
      List<Channel> channels = await Sql.search(filters);
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
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void clearFilters() {
    filters.seriesId = null;
    filters.groupId = null;
    filters.page = 1;
    nodeStack.clear();
  }

  void navbarChanged(ViewType view) {
    filters.viewType = view;
    clearFilters();
    _scrollController.jumpTo(0);
    load(false);
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
    if (nodeStack.hasNodes()) {
      undoFiltersNode(nodeStack.pop());
      load();
    } else if (searchMode) {
      toggleSearch();
    }
  }

  bool canPop() {
    return !searchMode && !nodeStack.hasNodes();
  }

  void setNode(Node node) {
    node.query = filters.query;
    nodeStack.add(node);
    setFiltersNode(node);
    _scrollController.jumpTo(0);
    load();
  }

  void setFiltersNode(Node node) {
    clearSearch();
    filters.page = 1;
    switch (node.type) {
      case NodeType.category:
        filters.viewType = ViewType.all;
        filters.groupId = node.id;
        break;
      case NodeType.series:
        filters.viewType = ViewType.all;
        filters.seriesId = node.id;
        break;
    }
  }

  void clearSearch() {
    filters.query = null;
    searchController.clear();
  }

  void undoFiltersNode(Node currentNode) {
    switch (currentNode.type) {
      case NodeType.category:
        filters.groupId = null;
        break;
      case NodeType.series:
        filters.seriesId = null;
    }
    reapplyFilters(currentNode);
    filters.viewType = currentNode.type == NodeType.category
        ? ViewType.categories
        : ViewType.all;
  }

  void reapplyFilters(Node node) {
    if (node.query != null && node.query!.isNotEmpty) {
      filters.query = node.query;
      searchController.text = filters.query!;
    } else {
      clearSearch();
    }
  }

  ViewType getStartingView() {
    if (widget.snapshot == null) {
      return filters.viewType;
    }
    if (widget.snapshot!.filters.groupId != null) {
      return ViewType.categories;
    }
    return ViewType.all;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: canPop(),
        onPopInvokedWithResult: (didPop, result) {
          handleBack();
        },
        child: Scaffold(
            appBar: nodeStack.hasNodes()
                ? AppBar(
                    title: Text(nodeStack.get().toString()),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => handleBack(),
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
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainer, // Background color
                          child: Row(
                            children: [
                              Expanded(
                                  child: TextField(
                                controller: searchController,
                                focusNode: _focusNode,
                                onChanged: (query) {
                                  _debounce?.cancel();
                                  _debounce = Timer(
                                      const Duration(milliseconds: 500), () {
                                    filters.query = query;
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
                                        filters.useKeywords =
                                            !filters.useKeywords;
                                        load(false);
                                      },
                                      icon: Icon(filters.useKeywords
                                          ? Icons.label
                                          : Icons.label_outline)),
                                  filled: true, // Light background for contrast
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 0),
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
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 315,
                  mainAxisExtent: 120,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final channel = channels[index];
                  return ChannelTile(
                    channel: channel,
                    setNode: setNode,
                    parentContext: context,
                    getSnapshot: getSnapshot,
                  );
                },
              )),
            ]))),
            bottomNavigationBar: BottomNav(
              updateViewMode: navbarChanged,
              startingView: getStartingView(),
              blockSettings: blockSettings,
            ),
            floatingActionButton: Visibility(
              visible: !searchMode,
              child: FloatingActionButton(
                onPressed: toggleSearch,
                tooltip: 'Search',
                child: const Icon(Icons.search),
              ),
            )));
  }
}
