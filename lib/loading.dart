import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';

Widget progressOverlayBuilder(dynamic progress) {
  return Column(
    children: [
      const Spacer(flex: 2),
      const SpinKitCircle(color: Colors.blue, size: 50),
      if (progress != null) ...[
        const SizedBox(height: 16),
        Text(
          progress.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center,
        ),
      ],
      const Spacer(flex: 1),
    ],
  );
}

class Loading extends StatelessWidget {
  final Widget child;
  const Loading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayWidgetBuilder: progressOverlayBuilder,
      child: child,
    );
  }
}
