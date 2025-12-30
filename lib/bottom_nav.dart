import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_tv/models/view_type.dart';
import 'package:open_tv/settings_view.dart';

class BottomNav extends StatefulWidget {
  final Function(ViewType) updateViewMode;
  final ViewType startingView;
  final bool blockSettings;
  final bool useRail;
  const BottomNav({
    super.key,
    required this.updateViewMode,
    this.startingView = ViewType.all,
    this.blockSettings = false,
    this.useRail = false,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.startingView.index;
    });
  }

  void onBarTapped(int index) {
    if (widget.blockSettings && index == ViewType.settings.index) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Settings disabled while refreshing on start")));
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == ViewType.settings.index) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SettingsView(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        ),
        (route) => false,
      );
      return;
    }
    widget.updateViewMode(ViewType.values[_selectedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useRail) {
      return Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceBright,
              border: Border(
                  right: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      width: 1))),
          child: NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: onBarTapped,
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.list),
                label: Text('All'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Categories'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star),
                label: Text('Favorites'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('History'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ));
    }
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            border: Border(
                top: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceBright,
                    width: 1))),
        child: BottomNavigationBar(
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'All',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "History"),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: onBarTapped,
          type: BottomNavigationBarType.fixed,
        ));
  }
}

bool shouldUseSideNav(BuildContext context) {
  final media = MediaQuery.of(context);
  final navigationMode =
      MediaQuery.maybeNavigationModeOf(context) ?? NavigationMode.traditional;
  final isLargeLandscape =
      media.size.width >= 900 && media.size.width > media.size.height;
  final isAndroidLike =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  return isLargeLandscape &&
      (navigationMode == NavigationMode.directional || isAndroidLike);
}
