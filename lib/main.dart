import 'package:dynamic_color/dynamic_color.dart';
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
  static const fallbackSeed = Colors.blue;
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      final lightColorScheme = lightDynamic ??
          ColorScheme.fromSeed(
              seedColor: fallbackSeed, brightness: Brightness.light);
      final darkColorScheme = darkDynamic ??
          ColorScheme.fromSeed(
              seedColor: fallbackSeed, brightness: Brightness.dark);
      return MaterialApp(
          title: 'Fred TV',
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
          ),
          themeMode: ThemeMode.system,
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
    });
  }
}
