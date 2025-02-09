import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:open_tv/models/result.dart';
import 'package:url_launcher/url_launcher.dart';

class Error {
  static Future<void> handleError(BuildContext context, Object error) async {
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

  static T? trySync<T>(T? Function() fn, BuildContext context,
      [String successMessage = "Action completed successfully"]) {
    context.loaderOverlay.show();
    try {
      var result = fn();
      showSuccess(context, successMessage);
      return result;
    } catch (e) {
      if (context.mounted) {
        handleError(context, e);
      }
    }
    context.loaderOverlay.hide();
    return null;
  }

  static Future<Result<T>> tryAsync<T>(
      Future<T?> Function() fn, BuildContext context,
      [String successMessage = "Action completed successfully"]) async {
    var success = false;
    if (context.mounted) {
      context.loaderOverlay.show();
    }
    try {
      var result = await fn();
      showSuccess(context, successMessage);
      success = true;
    } catch (e) {
      await handleError(context, e);
    }
    if (context.loaderOverlay.visible) {
      context.loaderOverlay.hide();
    }
    return Result(success: success);
  }
}
