import 'package:flutter/material.dart';
import 'package:open_tv/models/view_type.dart';
import 'package:open_tv/settings_view.dart';

class BottomNav extends StatefulWidget {
  final Function(ViewType) updateViewMode;
  final ViewType startingView;
  final bool blockSettings;
  const BottomNav({
    super.key,
    required this.updateViewMode,
    this.startingView = ViewType.all,
    this.blockSettings = false,
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
