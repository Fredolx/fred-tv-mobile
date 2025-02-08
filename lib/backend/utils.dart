import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static String? _appDir;
  static Future<String> get appDir async {
    _appDir ??= (await getApplicationSupportDirectory()).path;
    return _appDir!;
  }

  static Future<String> getTempPath(String fileName) async {
    var path = await appDir;
    var tempDir = join(path, "temp");
    Directory(tempDir).create(recursive: true);
    return join(tempDir, fileName);
  }
}
