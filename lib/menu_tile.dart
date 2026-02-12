import 'package:flutter/material.dart';

class MenuTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final LinearGradient color;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<MenuTile> {
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = _isFocused || _isHovered;
    final double scale = isActive ? 1.1 : 1.0;
    final Color borderColor = isActive ? Colors.white : Colors.transparent;
    final double shadowOpacity = isActive ? 0.5 : 0.2;
    final double shadowBlur = isActive ? 12.0 : 4.0;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(scale),
        transformAlignment: Alignment.center,
        width: 225,
        height: 200,
        decoration: BoxDecoration(
          gradient: widget.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(shadowOpacity),
              blurRadius: shadowBlur,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onFocusChange: (value) => setState(() => _isFocused = value),
            onHover: (value) => setState(() => _isHovered = value),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 70),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
