import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:open_tv/native_bridge.dart';
import 'package:open_tv/whats_new_modal.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Utils {
  static Future<bool> hasTouchScreen() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.systemFeatures.contains(
        'android.hardware.touchscreen',
      );
    }
    return true;
  }

  static Future<void> maybeShowWhatsNew(BuildContext context) async {
    final version = (await PackageInfo.fromPlatform()).version;
    if (!context.mounted) return;
    if (!await NativeBridge.instance.shouldShowWhatsNew(version)) return;
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (context) => WhatsNewModal(version: version),
    );
  }
}
