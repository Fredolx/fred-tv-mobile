import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';

class Loading extends StatelessWidget {
  final Widget child;
  const Loading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayWidgetBuilder: (_) {
        return const Center(
          child: SpinKitPulsingGrid(color: Colors.blue, size: 50),
        );
      },
      child: child,
    );
  }
}
