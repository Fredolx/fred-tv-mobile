import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:open_tv/bottom_nav.dart';
import 'package:open_tv/confirm_delete.dart';
import 'package:open_tv/select_dialog.dart';
import 'package:open_tv/edit_dialog.dart';
import 'package:open_tv/home.dart';
import 'package:open_tv/loading.dart';
import 'package:open_tv/models/home_manager.dart';
import 'package:open_tv/models/id_data.dart';
import 'package:open_tv/error.dart';
import 'package:open_tv/setup.dart';
import 'package:open_tv/src/rust/api/api.dart' as api;
import 'package:open_tv/src/rust/api/types.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  final bool showNavBar;

  const SettingsView({super.key, this.showNavBar = true});

  @override
  State<SettingsView> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsView> {
  Settings settings = Settings();
  List<Source> sources = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    var results = await Future.wait([api.getSettings(), api.getSources()]);
    setState(() {
      settings = results[0] as Settings;
      sources = results[1] as List<Source>;
      loading = false;
    });
  }

  void updateView(ViewType view) {
    if (view != ViewType.settings) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => Home(
            home: HomeManager(
              filters: Filters(
                viewType: view,
                sourceIds: Int64List(0),
                page: 1,
                useKeywords: false,
                sort: SortType.provider,
              ),
            ),
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        ),
        (route) => false,
      );
    }
  }

  Future<void> showEditDialog(BuildContext context, final Source source) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (builder) =>
          EditDialog(source: source, afterSave: reloadSources),
    );
  }

  Future<void> _showDefaultViewDialog(BuildContext context) async {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return SelectDialog(
          title: "Default view",
          data: ViewType.values
              .take(4)
              .map((x) => IdData(id: x.index, data: x.name))
              .toList(),
          action: (view) {
            setState(() {
              settings.defaultView = ViewType.values[view];
              updateSettings();
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> toggleSource(Source source) async {
    await Error.tryAsyncNoLoading(
      () async => await api.setSourceEnabled(
        value: source.enabled,
        sourceId: source.id!,
      ),
      context,
    );
    await reloadSources();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Source ${!source.enabled ? "enabled" : "disabled"}"),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget getSource(Source source) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ), // Spacing around the tile
      elevation: 5,
      child: ListTile(
        leading: Icon(source.enabled ? Icons.tv : Icons.tv_off),
        horizontalTitleGap: 25,
        onLongPress: () => toggleSource(source),
        contentPadding: const EdgeInsets.only(left: 20),
        title: Text(source.name),
        subtitle: Text(source.sourceType.name),
        trailing: Row(
          mainAxisSize:
              MainAxisSize.min, // Ensures the row takes up minimal space
          children: [
            Offstage(
              offstage: source.sourceType == SourceType.m3U,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  await Error.tryAsync(
                    () async {
                      await api.refreshSource(source: source);
                    },
                    context,
                    "Source has been refreshed successfully",
                  );
                },
              ),
            ),
            Offstage(
              offstage: source.sourceType == SourceType.m3U,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async => await showEditDialog(context, source),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async => await showConfirmDeleteDialog(source),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showConfirmDeleteDialog(Source source) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (builder) => ConfirmDelete(
        type: "source",
        name: source.name,
        confirm: () async {
          await Error.tryAsync(
            () async => await api.deleteSource(id: source.id!),
            context,
            "Successfully deleted source",
          );
          await reloadSources();
          if (sources.isEmpty) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Setup()),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Future<void> reloadSources() async {
    await Error.tryAsyncNoLoading(
      () async => sources = await api.getSources(),
      context,
    );
    setState(() {
      sources;
    });
  }

  Future<void> updateSettings() async {
    await Error.tryAsyncNoLoading(
      () async => await api.updateSettings(settings: settings),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Visibility(
        visible: !loading,
        child: Loading(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: const Text("Donate"),
                    subtitle: const Text(
                      "Fred TV needs your help! Consider donating ❤️",
                    ),
                    onTap: () async => await launchUrl(
                      Uri.parse(
                        "https://github.com/Fredolx/fred-tv-mobile/discussions/1",
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  ListTile(
                    title: const Text("Default view"),
                    subtitle: Text(settings.defaultView!.name),
                    onTap: () async => await _showDefaultViewDialog(context),
                  ),
                  ListTile(
                    title: const Text("Force TV Mode"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: settings.forceTvMode ?? false,
                          onChanged: (bool value) {
                            setState(() {
                              settings.forceTvMode = value;
                            });
                            updateSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text("Refresh sources on start"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: settings.refreshOnStart,
                          onChanged: (bool value) {
                            setState(() {
                              settings.refreshOnStart = value;
                            });
                            updateSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text("Show livestreams"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: settings.showLivestreams,
                          onChanged: (bool value) {
                            setState(() {
                              settings.showLivestreams = value;
                            });
                            updateSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text("Show movies"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: settings.showMovies,
                          onChanged: (bool value) {
                            setState(() {
                              settings.showMovies = value;
                            });
                            updateSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text("Show series"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: settings.showSeries,
                          onChanged: (bool value) {
                            setState(() {
                              settings.showSeries = value;
                            });
                            updateSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Sources',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async => await Error.tryAsync(
                              () async => await refreshAll(),
                              context,
                              "Successfully refreshed all sources",
                            ),
                            icon: const Icon(Icons.refresh),
                          ),
                          IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const Setup(showAppBar: true),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...sources.map(getSource),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.showNavBar
          ? BottomNav(
              updateViewMode: updateView,
              startingView: ViewType.settings,
            )
          : null,
    );
  }
}
