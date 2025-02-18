import 'package:open_tv/models/view_type.dart';

class Settings {
  ViewType defaultView;
  bool refreshOnStart;

  Settings({
    this.defaultView = ViewType.all,
    this.refreshOnStart = false,
  });
}
