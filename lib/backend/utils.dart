import 'dart:io';

import 'package:open_tv/backend/m3u.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/backend/xtream.dart';
import 'package:open_tv/models/source.dart';
import 'package:open_tv/models/source_type.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite_async/sqlite_async.dart';

class Utils {
  static String? _appDir;
  static Future<String> get appDir async {
    _appDir ??= (await getApplicationSupportDirectory()).path;
    return _appDir!;
  }

  static Future<String> getTempPath(String fileName) async {
    final path = await appDir;
    final tempDir = join(path, "temp");
    Directory(tempDir).create(recursive: true);
    return join(tempDir, fileName);
  }

  static Future<void> refreshSource(Source source) async {
    await processSource(source, true);
  }

  static Future<void> processSource(Source source, [bool wipe = false]) async {
    switch (source.sourceType) {
      case SourceType.m3u:
        await processM3U(source, wipe);
        break;
      case SourceType.m3uUrl:
        await processM3UUrl(source, wipe);
        break;
      case SourceType.xtream:
        await processXtream(source, wipe);
        break;
    }
  }
}
