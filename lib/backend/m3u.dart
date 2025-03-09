import 'dart:convert';
import 'dart:io';

import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/backend/utils.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/channel_http_headers.dart';
import 'package:open_tv/models/channel_preserve.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/source.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:http/http.dart' as http;

final nameRegex = RegExp(r'tvg-name="([^"]*)"');
final nameRegexAlt = RegExp(r'^(.*),([^,\n\r\t]*)$');
final idRegex = RegExp(r'tvg-id="([^"]*)"');
final logoRegex = RegExp(r'tvg-logo="([^"]*)"');
final groupRegex = RegExp(r'group-title="([^"]*)"');
final httpOriginRegex = RegExp(r'http-origin=(.+)');
final httpReferrerRegex = RegExp(r'http-referrer=(.+)');
final httpUserAgentRegex = RegExp(r'http-user-agent=(.+)');

Future<void> processM3U(Source source, bool wipe, [String? path]) async {
  path ??= source.url;
  List<ChannelPreserve>? preserve;
  var file = File(path!)
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter());
  List<Future<void> Function(SqliteWriteContext, Map<String, String>)>
      statements = [];
  statements.add(Sql.getOrCreateSourceByName(source));
  if (wipe) {
    preserve = await Sql.getChannelsPreserve(source.id!);
    statements.add(Sql.wipeSource(source.id!));
  }
  String? lastLine;
  String? channelLine;
  ChannelHttpHeaders? headers;
  var httpHeadersSet = false;
  await for (var line in file) {
    final lineUpper = line.toUpperCase();
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
  if (preserve != null) {
    statements.add(Sql.restorePreserve(preserve));
  }
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
  var name = getName(l1)?.trim();
  if (name == null) return null;
  return Channel(
      name: name,
      group: groupRegex.firstMatch(l1)?[1]?.trim(),
      image: logoRegex.firstMatch(l1)?[1]?.trim(),
      favorite: false,
      mediaType: getMediaType(last),
      sourceId: -1,
      url: last);
}

String? getName(String l1) {
  var name = nameRegex.firstMatch(l1)?[1];
  name ??= nameRegexAlt.firstMatch(l1)?[2];
  name ??= idRegex.firstMatch(l1)?[1];
  return name;
}

bool setChannelHeaders(
  String headerLine,
  ChannelHttpHeaders headers,
) {
  final userAgent = httpUserAgentRegex.firstMatch(headerLine)?[1];
  if (userAgent != null) {
    headers.userAgent = userAgent;
    return true;
  }
  final referrer = httpReferrerRegex.firstMatch(headerLine)?[1];
  if (referrer != null) {
    headers.referrer = referrer;
    return true;
  }
  final origin = httpOriginRegex.firstMatch(headerLine)?[1];
  if (origin != null) {
    headers.httpOrigin = origin;
    return true;
  }
  return false;
}

Future<void> processM3UUrl(Source source, bool wipe) async {
  var path = await downloadM3U(source.url!);
  await processM3U(source, wipe, path);
}

Future<String> downloadM3U(String urlStr) async {
  final url = Uri.parse(urlStr);
  final client = http.Client();
  final request = http.Request('GET', url);
  final response = await client.send(request);
  if (response.statusCode != 200) {
    throw Exception('Failed to download file: ${response.statusCode}');
  }
  final path = await Utils.getTempPath("get.m3u");
  final file = File(path);
  final sink = file.openWrite();
  await for (var chunk in response.stream) {
    sink.add(chunk);
  }
  await sink.close();
  client.close();
  return path;
}
