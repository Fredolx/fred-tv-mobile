import 'package:flutter/material.dart';
import 'package:open_tv/backend/settings_service.dart';
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
                      "https://github.com/Fredolx/open-tv-mobile/discussions/1",
                    ),
                    mode: LaunchMode.externalApplication);
                Navigator.pop(context, false);
              },
              child: const Text("Donate")),
          TextButton(
              onPressed: () async {
                await SettingsService.updateLastSeenVersion();
                Navigator.pop(context, true);
              },
              child: const Text("Don't show again"))
        ],
        content: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
              child: const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: const Text(
                    '''
Hi! Thanks for supporting Open TV. I am really sorry for the many bugs that have been missed in testing. The good news is, they're getting fixed! Here's everything new:

- Vastly improved navigation. Going back in a view doesn't reset it anymore, including your scroll position.
- Added subtitles and audio options in player
- Fixed xtream bugs
- Added a notification when successfully adding favorites
- Lots more behind the scenes. 

Big thank you for everyone that donated and purchased the app. It wouldn't be possible without your help. I will continue working very hard on it and I am terribly sorry if you experienced bugs with this first version.
If you like Open TV, please consider donating (Even a dollar helps tremendously), reporting issues on the github and sharing it with your friends.
''',
                  ))),
        ));
  }
}
