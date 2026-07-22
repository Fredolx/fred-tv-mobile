import 'package:flutter/material.dart';
import 'package:open_tv/models/view_type.dart';
import 'package:open_tv/settings_view.dart';
import 'package:open_tv/task_service.dart';

class BottomNav extends StatefulWidget {
  final Function(ViewType) updateViewMode;
  final ViewType startingView;
  final bool tvMode;
  const BottomNav({
    super.key,
    required this.updateViewMode,
    this.startingView = ViewType.all,
    this.tvMode = false,
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

  @override
  void dispose() {
    super.dispose();
  }

  void onBarTapped(int index) {
    if (TaskService.instance.isDeletingSource) {
      TaskService.instance.notifyBusy();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == ViewType.settings.index) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => SettingsView(tvMode: widget.tvMode),
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
            width: 1,
          ),
        ),
      ),
      child: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'All'),
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Categories',
          ),
          NavigationDestination(icon: Icon(Icons.star), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.history), label: "History"),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: onBarTapped,
      ),
    );
  }
}
