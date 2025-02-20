import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/bottom_nav.dart';
import 'package:open_tv/channel_tile.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/filters.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/view_type.dart';
import 'package:open_tv/error.dart';

class Home extends StatefulWidget {
  final ViewType startingView;
  const Home({super.key, this.startingView = ViewType.all});
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    initializeAsync();
  }

  Future<void> initializeAsync() async {
    final sources = await Sql.getEnabledSourcesMinimal();
    filters.sourceIds = sources.map((x) => x.id).toList();
    await load();
  }

  Future<void> loadMore() async {
    filters.page++;
    load(true);
  }

  toggleSearch() {
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
    Error.tryAsyncNoLoading(() async {
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

  void navbarChanged(ViewType view) {
    filters.viewType = view;
    _scrollController.jumpTo(0);
    load(false);
  }

  void _scrollListener() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !searchMode,
        onPopInvokedWithResult: (didPop, result) {
          if (searchMode) {
            toggleSearch();
          }
        },
        child: Scaffold(
            body: Column(children: [
              Offstage(
                  offstage: !searchMode,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                            _debounce =
                                Timer(const Duration(milliseconds: 500), () {
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
                                  filters.useKeywords = !filters.useKeywords;
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
                  )),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth = 150;
                    double cardHeight = 60;
                    int crossAxisCount = (constraints.maxWidth / cardWidth)
                        .floor()
                        .clamp(1, 4)
                        .toInt();
                    return GridView.builder(
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 12,
                        childAspectRatio: cardWidth / cardHeight,
                      ),
                      itemCount: channels.length,
                      itemBuilder: (context, index) {
                        final channel = channels[index];
                        return ChannelTile(
                          channel: channel,
                        );
                      },
                    );
                  },
                ),
              ))
            ]),
            bottomNavigationBar: BottomNav(
              updateViewMode: navbarChanged,
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
