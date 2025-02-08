import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Error {
  static void handleError(BuildContext context, Object error) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[700],
            content: const Text(
                "An error occured. Click on 'Details' for more information"),
            action: SnackBarAction(
                label: 'Details',
                textColor: Colors.white,
                onPressed: () async => {
                      await showDialog(
                          context: context,
                          builder: (builder) => AlertDialog(
                                title: const Text('Error'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                        "The following error occured. If this error persists, please report it.\n"),
                                    Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(
                                            8.0), // Padding inside the box
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxHeight: 200),
                                            child: SingleChildScrollView(
                                                child: Text(
                                              error.toString(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ))))
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    child: const Text('Report issue'),
                                    onPressed: () async {
                                      final Uri url = Uri.parse(
                                          'https://github.com/fredolx/open-tv-mobile');
                                      await launchUrl(url,
                                          mode: LaunchMode.externalApplication);
                                    },
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    child: const Text('Copy'),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text: error.toString()));
                                    },
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    child: const Text('Close'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ))
                    })),
      );
    }
  }

  static void showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
