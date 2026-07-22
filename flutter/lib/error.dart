import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:open_tv/app_keys.dart';
import 'package:open_tv/models/result.dart';
import 'package:url_launcher/url_launcher.dart';

class Error {
  static Future<void> handleError(String error) async {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          persist: false,
          backgroundColor: Colors.red[700],
          content: const Text(
            "An error occured. Click on 'Details' for more information",
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Details',
            textColor: Colors.white,
            onPressed: () => showDialog(
              barrierDismissible: true,
              context: context,
              builder: (builder) => AlertDialog(
                title: const Text('Error'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "The following error occured. If this error persists, please report it.\n",
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        8.0,
                      ), // Padding inside the box
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Text(
                            error,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Report issue'),
                    onPressed: () async {
                      final Uri url = Uri.parse(
                        'https://github.com/fredolx/fred-tv-mobile/issues/new?template=Blank+issue',
                      );
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Copy'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: error.toString()));
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  static void showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message), persist: false),
    );
  }

  static Future<Result<T>> tryAsync<T>(
    Future<T?> Function() fn,
    BuildContext? context, [
    String? successMessage = "Action completed successfully",
    bool useLoading = true,
    bool useSuccess = true,
  ]) async {
    var success = false;
    T? result;
    if (useLoading && context != null && context.mounted) {
      context.loaderOverlay.show();
    }
    try {
      result = await fn();
      if (useSuccess) showMessage(successMessage!);
      success = true;
    } catch (e, stackTrace) {
      final error =
          "${e.toString()}\n\n-- Dart Stack Trace --\n${stackTrace.toString()}";
      await handleError(error);
    }
    if (useLoading &&
        context != null &&
        context.mounted &&
        context.loaderOverlay.visible) {
      context.loaderOverlay.hide();
    }
    return Result(success: success, data: result);
  }

  static Future<Result<T>> tryAsyncNoLoading<T>(
    Future<T?> Function() fn, [
    bool useSuccess = false,
    String? successMessage,
  ]) async {
    return await tryAsync(fn, null, successMessage, false, useSuccess);
  }
}
