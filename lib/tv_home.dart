import 'package:flutter/material.dart';
import 'package:open_tv/menu_tile.dart';

class TvHome extends StatefulWidget {
  const TvHome({super.key});

  @override
  State<TvHome> createState() => _TvHomeState();
}

class _TvHomeState extends State<TvHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                MenuTile(
                  icon: Icons.live_tv,
                  label: "Live",
                  color: const LinearGradient(
                    colors: [Colors.blueGrey, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => print("Live Clicked"),
                ),
                MenuTile(
                  icon: Icons.movie,
                  label: "Vods",
                  color: LinearGradient(
                    colors: [Colors.red, Colors.red.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => print("Vods Clicked"),
                ),
                MenuTile(
                  icon: Icons.local_movies,
                  label: "Series",
                  color: const LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => print("Series Clicked"),
                ),
                MenuTile(
                  icon: Icons.star,
                  label: "Favorites",
                  color: LinearGradient(
                    colors: [Colors.orange.shade700, Colors.amber.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => print("Favorites Clicked"),
                ),
                MenuTile(
                  icon: Icons.settings,
                  label:
                      "Settings", // Fixed label from "Favorites" to "Settings"
                  color: LinearGradient(
                    colors: [
                      Colors.blueGrey.shade800,
                      Colors.blueGrey.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => print("Settings Clicked"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
