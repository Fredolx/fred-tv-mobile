import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/view_type.dart';

class Settings {
  ViewType defaultView;
  bool refreshOnStart;
  bool showLivestreams;
  bool showMovies;
  bool showSeries;
  bool forceTVMode;
  String hwdec;
  bool displayResample;
  int bufferSeconds;
  Settings({
    this.defaultView = ViewType.all,
    this.refreshOnStart = false,
    this.showLivestreams = true,
    this.showMovies = true,
    this.showSeries = true,
    this.forceTVMode = false,
    this.hwdec = 'auto',
    this.displayResample = true,
    this.bufferSeconds = 60,
  });

  List<MediaType> getMediaTypes() {
    return [
      if (showLivestreams) MediaType.livestream,
      if (showMovies) MediaType.movie,
      if (showSeries) MediaType.serie,
    ];
  }
}
