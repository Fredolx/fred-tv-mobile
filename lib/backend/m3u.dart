import 'dart:convert';
import 'dart:io';

import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/source.dart';

final nameRegex = RegExp(r'tvg-name="([^"]*)"');
final nameRegexAlt = RegExp(r',([^\n\r\t]*)');
final idRegex = RegExp(r'tvg-id="([^"]*)"');
final logoRegex = RegExp(r'tvg-logo="([^"]*)"');
final groupRegex = RegExp(r'group-title="([^"]*)"');
final httpOriginRegex = RegExp(r'http-origin=(.+)');
final httpReferrerRegex = RegExp(r'http-referrer=(.+)');
final httpUserAgentRegex = RegExp(r'http-user-agent=(.+)');

Future<void> processM3U(Source source) async {
  var file = File(source.url!)
      .openRead()
      .map(utf8.decode)
      .transform(const LineSplitter());
  var lastLine;
  var sourceId = 0;
  await for (var line in file) {
    var db = await Sql.db;
  }
}

void commitChannel(String l1, String l2, int sourceId) {
  var channel = getChannelFromLines(l1, l2, sourceId);
  if (channel == null) return;
}

MediaType getMediaType(String url) {
  if (url.endsWith('.mp4') || url.endsWith('.mkv')) {
    return MediaType.movie;
  }
  return MediaType.livestream;
}

Channel? getChannelFromLines(String l1, String l2, int sourceId) {
  var name = getName(l1);
  if (name == null) return null;
  return Channel(
      name: name,
      group: groupRegex.firstMatch(l1)?[0],
      image: logoRegex.firstMatch(l1)?[0],
      favorite: false,
      mediaType: getMediaType(l2),
      sourceId: sourceId,
      url: l2);
}

String? getName(String l1) {
  var name = nameRegex.firstMatch(l1)?[0];
  name ??= nameRegexAlt.firstMatch(l1)?[0];
  name ??= idRegex.firstMatch(l1)?[0];
  return name;
}
