import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_tv/models/view_type.dart';
import 'package:open_tv/settings_view.dart';

class BottomNav extends StatefulWidget {
  final Function(ViewType) updateViewMode;
  final ViewType startingView;
  final bool blockSettings;
  final bool autofocus;
  final FocusNode? navFocusNode;
  const BottomNav(
      {super.key,
      required this.updateViewMode,
      this.startingView = ViewType.all,
      this.blockSettings = false,
      this.autofocus = false,
      this.navFocusNode});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  final FocusScopeNode _navScopeNode = FocusScopeNode();
  bool _justAutofocused = false;

  @override
  void initState() {
    super.initState();
    _navScopeNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        FocusScope.of(context).focusInDirection(TraversalDirection.up);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    setState(() {
      _selectedIndex = widget.startingView.index;
    });
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // We are programmatically restoring focus.
        // Mark this flag so onFocusChange knows to ignore the entry logic.
        _justAutofocused = true;
        final nodes = _navScopeNode.traversalDescendants.toList();
        if (_selectedIndex < nodes.length) {
          nodes[_selectedIndex].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _navScopeNode.dispose();
    super.dispose();
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
        child: Focus(
            focusNode: widget.navFocusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                if (_justAutofocused) {
                  _justAutofocused = false;
                  return;
                }
                _navScopeNode.requestFocus();
                final first = _navScopeNode.traversalDescendants.firstOrNull;
                first?.requestFocus();
              }
            },
            child: FocusScope(
                node: _navScopeNode,
                child: FocusTraversalGroup(
                    policy: WidgetOrderTraversalPolicy(),
                    child: NavigationBar(
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.list),
                          label: 'All',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.dashboard),
                          label: 'Categories',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.star),
                          label: 'Favorites',
                        ),
                        NavigationDestination(
                            icon: Icon(Icons.history), label: "History"),
                        NavigationDestination(
                          icon: Icon(Icons.settings),
                          label: 'Settings',
                        ),
                      ],
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: onBarTapped,
                    )))));
  }
}
