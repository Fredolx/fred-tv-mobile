import 'package:flutter/material.dart';
import 'package:open_tv/backend/settings_service.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/home.dart';
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
        title: 'Open TV',
        theme: ThemeData(
          useMaterial3: true, // Enables Material You
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: skipSetup ? Home(settings: settings) : const Setup());
  }
}
