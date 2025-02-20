import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/home.dart';
import 'package:open_tv/setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  final hasSources = await Sql.hasSources();
  runApp(MyApp(
    skipSetup: hasSources,
  ));
}

class MyApp extends StatelessWidget {
  final bool skipSetup;
  const MyApp({super.key, required this.skipSetup});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Open TV',
        theme: ThemeData(
          useMaterial3: true, // Enables Material You
          colorSchemeSeed: Colors.blue, // Uses dynamic color if supported
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: skipSetup ? const Home() : const Setup());
  }
}
