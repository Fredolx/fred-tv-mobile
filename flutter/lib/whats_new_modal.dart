import 'package:flutter/material.dart';
import 'package:open_tv/native_bridge.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsNewModal extends StatelessWidget {
  final String version;
  const WhatsNewModal({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("What's new: update $version"),
      actions: [
        TextButton(
          onPressed: () async {
            await launchUrl(
              Uri.parse(
                "https://github.com/Fredolx/fred-tv-mobile/discussions/1",
              ),
              mode: LaunchMode.externalApplication,
            );
            if (!context.mounted) return;
            Navigator.pop(context, false);
          },
          child: const Text("Donate"),
        ),
        TextButton(
          autofocus: true,
          onPressed: () async {
            await NativeBridge.instance.updateLastSeenVersion(
              (await PackageInfo.fromPlatform()).version,
            );
            if (!context.mounted) return;
            Navigator.pop(context, true);
          },
          child: const Text("Don't show again"),
        ),
      ],
      content: const Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text('''
Hi! Thanks for supporting Fred TV. Here's everything new:

- Completely replaced the backend to use the Rust backend from the Desktop version
- Super robust and smooth native playback on Android using ExoPlayer
- Android TV Support 
- Easy-to-use redesigned Home for TV
- Full D-Pad navigation support
- Speed and performance optimizations, the app is at least 50% faster!
- Fixed all xtream and m3u parsing issues (hopefully)
- Sorting added
- Sorting default options added to Settings
- And more behind the curtains!

If you like Fred TV, please consider donating (Even a dollar helps tremendously), reporting issues on the github and sharing it with your friends.
'''),
          ),
        ),
      ),
    );
  }
}
