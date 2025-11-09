import 'package:flutter/material.dart';
import 'package:open_tv/backend/settings_service.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/home.dart';
import 'package:open_tv/models/filters.dart';
import 'package:open_tv/models/home_manager.dart';
import 'package:open_tv/models/settings.dart';
import 'package:open_tv/setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasSources = await Sql.hasSources();
  final settings = await SettingsService.getSettings();
  runApp(MyApp(
    skipSetup: hasSources,
    settings: settings,
  ));
}

class MyApp extends StatelessWidget {
  final bool skipSetup;
  final Settings settings;
  const MyApp({super.key, required this.skipSetup, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fred TV',
        theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                surface: Colors.black,
                brightness: Brightness.dark,
                surfaceContainer: Color.fromARGB(255, 29, 36, 41)),
            useMaterial3: true),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: skipSetup
            ? Home(
                firstLaunch: true,
                refresh: settings.refreshOnStart,
                home: HomeManager(
                    filters: Filters(
                  viewType: settings.defaultView,
                )))
            : const Setup());
  }
}
