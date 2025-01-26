import 'package:flutter/material.dart';
import 'package:open_tv/bottom_nav.dart';
import 'package:open_tv/channel_tile.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/setup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open TV',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Setup(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Channel> channels = [
    Channel(id: 0, name: "Test 1", mediaType: MediaType.livestream),
    Channel(id: 1, name: "Test 2", mediaType: MediaType.livestream),
    Channel(id: 2, name: "Test 3", mediaType: MediaType.livestream),
    Channel(id: 3, name: "Test 4", mediaType: MediaType.livestream),
    Channel(id: 4, name: "Test 5", mediaType: MediaType.livestream),
  ];

  void search() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = 400;
            double cardHeight = 90;
            int crossAxisCount = (constraints.maxWidth / cardWidth * 1.25)
                .floor()
                .clamp(1, 3)
                .toInt();
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
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
