import 'package:flutter/material.dart';
import 'package:open_tv/home.dart';
import 'package:open_tv/menu_tile.dart';
import 'package:open_tv/models/filters.dart';
import 'package:open_tv/models/home_manager.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/view_type.dart';
import 'package:open_tv/settings_view.dart';

class TvHome extends StatefulWidget {
  final bool nested;
  final ViewType? previousViewType;
  const TvHome({super.key, this.nested = false, this.previousViewType});

  @override
  State<TvHome> createState() => _TvHomeState();
}

class _TvHomeState extends State<TvHome> {
  void navigateHome(Filters filters) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            Home(home: HomeManager(filters: filters), hasTouchScreen: false),
      ),
    );
  }

  void navNested(ViewType viewType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TvHome(nested: true, previousViewType: viewType),
      ),
    );
  }

  void navSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => SettingsView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: widget.nested ? getMediaTypeSelectNested() : getHome(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getMediaTypeSelectNested() {
    return [
      MenuTile(
        icon: Icons.list,
        label: "All",
        color: const LinearGradient(
          colors: [Colors.blueGrey, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => navigateHome(
          Filters(
            viewType: widget.previousViewType!,
            mediaTypes: [MediaType.livestream],
          ),
        ),
      ),
      MenuTile(
        icon: Icons.live_tv,
        label: "Live",
        color: const LinearGradient(
          colors: [Colors.amber, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => navigateHome(
          Filters(
            viewType: widget.previousViewType!,
            mediaTypes: [MediaType.livestream],
          ),
        ),
      ),
      MenuTile(
        icon: Icons.movie,
        label: "Vods",
        color: LinearGradient(
          colors: [Colors.red, Colors.red.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => navigateHome(
          Filters(
            viewType: widget.previousViewType!,
            mediaTypes: [MediaType.movie],
          ),
        ),
      ),
      MenuTile(
        icon: Icons.local_movies,
        label: "Series",
        color: const LinearGradient(
          colors: [Colors.purple, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => navigateHome(
          Filters(
            viewType: widget.previousViewType!,
            mediaTypes: [MediaType.serie],
          ),
        ),
      ),
    ];
  }

  List<Widget> getHome() {
    return [
      MenuTile(
        icon: Icons.tv,
        label: "Channels",
        color: LinearGradient(
          colors: [Colors.blueGrey, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => navNested(ViewType.all),
      ),
      MenuTile(
        icon: Icons.dashboard,
        label: "Categories",
        color: LinearGradient(
          colors: [Colors.purple, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => navNested(ViewType.categories),
      ),
      MenuTile(
        icon: Icons.star,
        label: "Favorites",
        color: LinearGradient(
          colors: [Colors.orange.shade700, Colors.amber.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => navNested(ViewType.favorites),
      ),
      MenuTile(
        icon: Icons.history,
        label: "History",
        color: LinearGradient(
          colors: [Colors.teal.shade700, Colors.green.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => navNested(ViewType.history),
      ),
      MenuTile(
        icon: Icons.settings,
        label: "Settings",
        color: LinearGradient(
          colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => navigateHome(Filters(viewType: ViewType.settings)),
      ),
    ];
  }
}
