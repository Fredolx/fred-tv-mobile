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
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Filters filters = Filters(
      sourceIds: [],
      mediaTypes: [MediaType.livestream, MediaType.movie, MediaType.serie],
      viewType: ViewType.all,
      page: 1,
      useKeywords: false);
  bool reachedMax = false;
  final int pageSize = 36;
  List<Channel> channels = [];
  @override
  void initState() {
    super.initState();
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

  search() {}

  Future<void> load([bool more = false]) async {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
      ),
      bottomNavigationBar: BottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: search,
        tooltip: 'Search',
        child: const Icon(Icons.search),
      ),
    );
  }
}
