enum SourceType { xtream, m3uUrl, m3u }

String getSourceTypeString(SourceType source) {
  switch (source) {
    case SourceType.m3u:
      return "M3U";
    case SourceType.m3uUrl:
      return "M3U Url";
    case SourceType.xtream:
      return "Xtream";
  }
}
