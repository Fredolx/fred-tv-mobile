import 'dart:convert';
import 'dart:io';

import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/channel_http_headers.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/source.dart';
import 'package:sqlite_async/sqlite_async.dart';

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
      .transform(utf8.decoder)
      .transform(const LineSplitter());
  List<Future<void> Function(SqliteWriteContext, Map<String, String>)>
      statements = [];
  statements.add(Sql.getOrCreateSourceByName(source));
  String? lastLine;
  String? channelLine;
  ChannelHttpHeaders? headers;
  var httpHeadersSet = false;
  await for (var line in file) {
    var lineUpper = line.toUpperCase();
    if (lineUpper.startsWith("#EXTINF")) {
      if (channelLine != null) {
        commitChannel(channelLine, lastLine!, httpHeadersSet ? headers : null,
            statements);
      }
      channelLine = line;
      lastLine = null;
      httpHeadersSet = false;
      headers = null;
    } else if (lineUpper.startsWith("#EXTVLCOPT")) {
      headers ??= ChannelHttpHeaders();
      if (setChannelHeaders(line, headers)) {
        httpHeadersSet = true;
      }
    } else {
      lastLine = line;
    }
  }
  commitChannel(channelLine!, lastLine!, headers, statements);
  statements.add(Sql.updateGroups());
  await Sql.commitWrite(statements);
}

void commitChannel(
    String l1,
    String last,
    ChannelHttpHeaders? headers,
    List<Future<void> Function(SqliteWriteContext, Map<String, String>)>
        statements) {
  var channel = getChannelFromLines(l1, last);
  if (channel == null) return;
  statements.add(Sql.insertChannel(channel));
  if (headers != null) {
    statements.add(Sql.insertChannelHeaders(headers));
  }
}

MediaType getMediaType(String url) {
  if (url.endsWith('.mp4') || url.endsWith('.mkv')) {
    return MediaType.movie;
  }
  return MediaType.livestream;
}

Channel? getChannelFromLines(String l1, String last) {
  var name = getName(l1);
  if (name == null) return null;
  return Channel(
      name: name,
      group: groupRegex.firstMatch(l1)?[1],
      image: logoRegex.firstMatch(l1)?[1],
      favorite: false,
      mediaType: getMediaType(last),
      sourceId: -1,
      url: last);
}

String? getName(String l1) {
  var name = nameRegex.firstMatch(l1)?[1];
  name ??= nameRegexAlt.firstMatch(l1)?[1];
  name ??= idRegex.firstMatch(l1)?[1];
  return name;
}

bool setChannelHeaders(
  String headerLine,
  ChannelHttpHeaders headers,
) {
  var userAgent = httpUserAgentRegex.firstMatch(headerLine)?[1];
  if (userAgent != null) {
    headers.userAgent = userAgent;
    return true;
  }
  var referrer = httpReferrerRegex.firstMatch(headerLine)?[1];
  if (referrer != null) {
    headers.referrer = referrer;
    return true;
  }
  var origin = httpOriginRegex.firstMatch(headerLine)?[1];
  if (origin != null) {
    headers.httpOrigin = origin;
    return true;
  }
  return false;
}
