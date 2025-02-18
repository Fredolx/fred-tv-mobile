import 'dart:collection';

import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/models/settings.dart';
import 'package:open_tv/models/view_type.dart';

const defaultView = "defaultView";
const refreshOnStart = "refreshOnStart";

class SettingsService {
  static Future<Settings> getSettings() async {
    var settingsMap = await Sql.getSettings();
    var settings = Settings();
    var view = settingsMap[defaultView];
    var refresh = settingsMap[refreshOnStart];
    if (view != null) {
      settings.defaultView = ViewType.values[int.parse(view)];
    }
    if (refresh != null) {
      settings.refreshOnStart = int.parse(refresh) == 1;
    }
    return settings;
  }

  static Future<void> updateSettings(Settings settings) async {
    HashMap<String, String> settingsMap = HashMap();
    settingsMap[defaultView] = settings.defaultView.index.toString();
    settingsMap[refreshOnStart] = (settings.refreshOnStart ? 1 : 0).toString();
    await Sql.updateSettings(settingsMap);
  }
}
