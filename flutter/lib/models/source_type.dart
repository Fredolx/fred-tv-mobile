enum SourceType { m3u, m3uUrl, xtream }

extension SourceTypeExtension on SourceType {
  String get label {
    switch (this) {
      case SourceType.m3u:
        return "M3U";
      case SourceType.m3uUrl:
        return "M3U Url";
      case SourceType.xtream:
        return "Xtream";
    }
  }
}
