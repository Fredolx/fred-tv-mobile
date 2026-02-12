import 'package:flutter/material.dart';

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMaterialTile(
                icon: Icons.live_tv,
                label: "Live",
                color: LinearGradient(colors: [Colors.blueGrey, Colors.blue]),
                onTap: () => {},
              ),
              _buildMaterialTile(
                icon: Icons.movie,
                label: "Vods",
                color: LinearGradient(
                  colors: [Colors.red, Colors.red.shade400],
                ),
                onTap: () => {},
              ),
              _buildMaterialTile(
                icon: Icons.local_movies,
                label: "Series",
                color: LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                ),
                onTap: () => {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialTile({
    required IconData icon,
    required String label,
    required LinearGradient color,
    required VoidCallback onTap,
  }) {
    return Ink(
      width: 225,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: color,
        border: Border.all(width: 10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 70),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
