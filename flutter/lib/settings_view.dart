import 'package:flutter/material.dart';
import 'package:open_tv/extensions/int_extensions.dart';
import 'package:open_tv/native_bridge.dart';
import 'package:open_tv/bottom_nav.dart';
import 'package:open_tv/confirm_delete.dart';
import 'package:open_tv/models/filters.dart';
import 'package:open_tv/select_dialog.dart';
import 'package:open_tv/edit_dialog.dart';
import 'package:open_tv/home.dart';
import 'package:open_tv/loading.dart';
import 'package:open_tv/models/home_manager.dart';
import 'package:open_tv/models/id_data.dart';
import 'package:open_tv/models/settings.dart';
import 'package:open_tv/models/source.dart';
import 'package:open_tv/models/source_type.dart';
import 'package:open_tv/models/sort_type.dart';
import 'package:open_tv/models/view_type.dart';
import 'package:open_tv/error.dart';
import 'package:open_tv/refresh_service.dart';
import 'package:open_tv/setup.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  final bool tvMode;
  const SettingsView({super.key, this.tvMode = false});

  @override
  State<SettingsView> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsView> {
  Settings settings = Settings();
  List<Source> sources = [];
  bool loading = true;
  Future<Map<int, int>> expiriesFuture = NativeBridge.instance
      .getAllExpiries()
      .catchError((_) => <int, int>{});

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    var results = await Future.wait([
      NativeBridge.instance.getSettings(),
      NativeBridge.instance.getSources(),
    ]);
    if (!mounted) return;
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
            tvMode: widget.tvMode,
            home: HomeManager(filters: Filters(viewType: view)),
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
      builder: (builder) => EditDialog(
        source: source,
        afterSave: reloadSources,
        parentContext: context,
      ),
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
              .map((x) => IdData(id: x.index, data: viewTypeToString(x)))
              .toList(),
          action: (view) {
            setState(() {
              settings.defaultView = ViewType.values[view];
              updateSettings();
            });
            Navigator.of(context).pop();
          },
          previouslySelectedId: settings.defaultView.index,
        );
      },
    );
  }

  Future<void> _showDefaultSortDialog(BuildContext context) async {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return SelectDialog(
          title: "Default sort",
          data: SortType.values
              .map((x) => IdData(id: x.index, data: sortTypeToString(x)))
              .toList(),
          action: (sort) {
            setState(() {
              settings.defaultSort = SortType.values[sort];
              updateSettings();
            });
            Navigator.of(context).pop();
          },
          previouslySelectedId: settings.defaultSort.index,
        );
      },
    );
  }

  Future<void> toggleSource(Source source) async {
    await Error.tryAsyncNoLoading(
      () => NativeBridge.instance.setSourceEnabled(source.id!, !source.enabled),
    );
    await reloadSources();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        persist: false,
        content: Text("Source ${!source.enabled ? "enabled" : "disabled"}"),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void showRefreshInProgress() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        persist: false,
        content: Text("Refresh in progress, please wait"),
      ),
    );
  }

  Widget getSource(Source source, bool refreshing) {
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Opacity(
      opacity: refreshing ? 0.4 : 1,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 5,
        child: ListTile(
          leading: Icon(source.enabled ? Icons.tv : Icons.tv_off),
          horizontalTitleGap: 25,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(source.name),
          subtitle: Text(source.sourceType.label),
          onTap: () =>
              refreshing ? showRefreshInProgress() : showSourceActions(source),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (source.lastUpdated != null)
                Text(
                  "Last updated: ${source.lastUpdated!.toTimeAgo()}",
                  style: subtitleStyle,
                ),
              if (source.sourceType == SourceType.xtream)
                FutureBuilder<Map<int, int>>(
                  future: expiriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data!.containsKey(source.id)) {
                      return Text(
                        "Expires: ${snapshot.data![source.id]!.toTimeUntil()}",
                        style: subtitleStyle,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> refreshSource(Source source) =>
      RefreshService.instance.refreshSource(source);

  Future<void> showSourceActions(Source source) async {
    final actions = <IdData<String>>[
      IdData(
        id: 0,
        data: source.enabled ? "Disable" : "Enable",
        icon: source.enabled ? Icons.tv_off : Icons.tv,
      ),
      if (source.sourceType != SourceType.m3u)
        IdData(id: 1, data: "Refresh", icon: Icons.refresh),
      IdData(id: 2, data: "Delete", icon: Icons.delete),
    ];
    final name = source.name.length > 20
        ? "${source.name.substring(0, 20)}…"
        : source.name;
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => SelectDialog(
        title: "Select action for $name",
        data: actions,
        action: (id) {
          Navigator.of(context).pop();
          switch (id) {
            case 0:
              toggleSource(source);
            case 1:
              refreshSource(source);
            case 2:
              showConfirmDeleteDialog(source);
          }
        },
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
            () => NativeBridge.instance.deleteSource(source.id!),
            context,
            "Successfully deleted source",
          );
          await reloadSources();
          if (!mounted) return;
          if (sources.isEmpty) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => Setup(tvMode: widget.tvMode),
              ),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Future<void> reloadSources() async {
    expiriesFuture = NativeBridge.instance.getAllExpiries().catchError(
      (_) => <int, int>{},
    );
    await Error.tryAsyncNoLoading(
      () async => sources = await NativeBridge.instance.getSources(),
    );
    setState(() {
      sources;
    });
  }

  Future<void> updateSettings() async {
    await Error.tryAsyncNoLoading(
      () => NativeBridge.instance.updateSettings(settings),
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
              child: ValueListenableBuilder<bool>(
                valueListenable: RefreshService.instance.isRefreshing,
                builder: (context, refreshing, _) => ListView(
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
                      onTap: () => launchUrl(
                        Uri.parse(
                          "https://github.com/Fredolx/fred-tv-mobile/discussions/1",
                        ),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    if (!widget.tvMode)
                      ListTile(
                        title: const Text("Default view"),
                        subtitle: Text(viewTypeToString(settings.defaultView)),
                        onTap: () => _showDefaultViewDialog(context),
                      ),
                    ListTile(
                      title: const Text("Default sort"),
                      subtitle: Text(sortTypeToString(settings.defaultSort)),
                      onTap: () => _showDefaultSortDialog(context),
                    ),
                    ListTile(
                      title: const Text("Force TV Mode"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: settings.forceTVMode,
                            onChanged: (bool value) {
                              setState(() {
                                settings.forceTVMode = value;
                              });
                              updateSettings();
                            },
                          ),
                        ],
                      ),
                    ),
                    if (!widget.tvMode)
                      ListTile(
                        title: const Text("Low latency livestreams"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: settings.lowLatency,
                              onChanged: (bool value) {
                                setState(() {
                                  settings.lowLatency = value;
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
                    if (!widget.tvMode)
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
                    if (!widget.tvMode)
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
                    if (!widget.tvMode)
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
                              color: refreshing
                                  ? Theme.of(context).disabledColor
                                  : null,
                              onPressed: () => refreshing
                                  ? showRefreshInProgress()
                                  : RefreshService.instance.refreshAll(),
                              icon: const Icon(Icons.refresh),
                            ),
                            IconButton(
                              color: refreshing
                                  ? Theme.of(context).disabledColor
                                  : null,
                              onPressed: () => refreshing
                                  ? showRefreshInProgress()
                                  : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Setup(
                                          showAppBar: true,
                                          tvMode: widget.tvMode,
                                        ),
                                      ),
                                    ),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...sources.map((x) => getSource(x, refreshing)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: !widget.tvMode
          ? BottomNav(
              updateViewMode: updateView,
              startingView: ViewType.settings,
              tvMode: widget.tvMode,
            )
          : null,
    );
  }
}
