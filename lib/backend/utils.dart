import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:open_tv/backend/m3u.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/backend/xtream.dart';
import 'package:open_tv/memory.dart';
import 'package:open_tv/models/source.dart';
import 'package:open_tv/models/source_type.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

typedef ProgressCallback = void Function(String message);

class Utils {
  static String? _appDir;
  static Future<String> get appDir async {
    _appDir ??= (await getApplicationSupportDirectory()).path;
    return _appDir!;
  }

  static Future<String> getTempPath(String fileName) async {
    final path = await appDir;
    final tempDir = join(path, "temp");
    await Directory(tempDir).create(recursive: true);
    return join(tempDir, fileName);
  }

  static Future<void> refreshSource(Source source, [ProgressCallback? onProgress]) async {
    refreshedSeries.clear();
    await processSource(source, true, onProgress);
  }

  static Future<void> processSource(Source source, [bool wipe = false, ProgressCallback? onProgress]) async {
    switch (source.sourceType) {
      case SourceType.m3u:
        await processM3U(source, wipe, null, onProgress);
        break;
      case SourceType.m3uUrl:
        await processM3UUrl(source, wipe, onProgress);
        break;
      case SourceType.xtream:
        await getXtream(source, wipe, onProgress);
        break;
    }
  }

  static Future<void> refreshAllSources([ProgressCallback? onProgress]) async {
    var sources = await Sql.getSources();
    for (var i = 0; i < sources.length; i++) {
      var source = sources[i];
      ProgressCallback? sourceProgress;
      if (onProgress != null) {
        var prefix = sources.length > 1 ? "Refreshing ${source.name} (${i + 1}/${sources.length})\n" : "";
        sourceProgress = (msg) => onProgress("$prefix$msg");
      }
      await refreshSource(source, sourceProgress);
    }
  }

  static Future<bool> hasTouchScreen() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.systemFeatures
          .contains('android.hardware.touchscreen');
    }
    return true;
  }
}
