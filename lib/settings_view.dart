import 'package:flutter/material.dart';
import 'package:open_tv/backend/settings_service.dart';
import 'package:open_tv/bottom_nav.dart';
import 'package:open_tv/home.dart';
import 'package:open_tv/models/settings.dart';
import 'package:open_tv/models/view_type.dart';
import 'package:open_tv/error.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsView> {
  Settings settings = Settings();

  @override
  void initState() {
    super.initState();
    SettingsService.getSettings().then((val) {
      setState(() {
        settings = val;
      });
    });
  }

  updateView(ViewType view) {
    if (view != ViewType.settings) {
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => Home(startingView: view),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) => child,
          ));
    }
  }

  Widget getDefaultViewDialogItem(ViewType view) {
    return ListTile(
      title: Text(viewTypeToString(view)),
      onTap: () {
        setState(() {
          settings.defaultView = view;
          updateSettings();
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _showDefaultViewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Default view"),
          content: ListView(
            shrinkWrap: true,
            children: ViewType.values.map(getDefaultViewDialogItem).toList(),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  updateSettings() {
    Error.tryAsyncNoLoading(
        () async => await SettingsService.updateSettings(settings), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
          child: ListView(
            children: [
              ListTile(
                  title: const Text("Default view"),
                  subtitle: Text(viewTypeToString(settings.defaultView)),
                  onTap: () => _showDefaultViewDialog(context)),
              ListTile(
                title: const Text("Update sources on start"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: settings.refreshOnStart,
                      onChanged: (bool value) {
                        setState(() {
                          settings.refreshOnStart = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          )),
      bottomNavigationBar: BottomNav(
        updateViewMode: updateView,
        startingView: ViewType.settings,
      ),
    );
  }
}
