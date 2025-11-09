import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_tv/backend/sql.dart';

class ServerInfo {
  final String host;
  final int port;

  const ServerInfo(this.host, this.port);

  Uri get url => Uri.parse('http://$host:$port/');

  @override
  String toString() => '$host:$port';
}

class LocalSetupServer {
  final String webAssetRootPath;

  HttpServer? _server;
  final Set<String> _existingNames = {};
  LocalSetupServer({this.webAssetRootPath = 'assets/web_setup'});

  bool get isRunning => _server != null;

  Future<ServerInfo> startServer() async {
    if (_server != null) {
      return ServerInfo(await _resolveLocalIpAddress(), _server!.port);
    }

    final server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      0,
      shared: false,
    );

    server.autoCompress = true;
    _server = server;

    unawaited(() async {
      await for (final request in server) {
        try {
          await _handleIncomingRequest(request);
        } catch (_) {
          await _respondError(request.response, 500, 'internal_error');
        }
      }
    }());

    return ServerInfo(await _resolveLocalIpAddress(), server.port);
  }

  Future<void> stopServer() async {
    final s = _server;
    _server = null;
    if (s != null) await s.close(force: true);
  }

  void registerExistingNames(Iterable<String> names) {
    _existingNames.addAll(names);
  }

  Future<void> _handleIncomingRequest(HttpRequest request) async {
    _applyCors(request.response);

    final method = request.method;
    final path = request.uri.path;

    if (method == 'OPTIONS') {
      return _respondEmpty(request.response, 204);
    }

    if (path == '/api/exists' && method == 'GET') {
      return _handleExists(request);
    }

    if (path == '/api/submit' && method == 'POST') {
      return _handleSubmit(request);
    }

    return _serveStaticAsset(request);
  }

  Future<void> _handleExists(HttpRequest request) async {
    final name = request.uri.queryParameters['name']?.trim() ?? '';
    final exists = Sql.sourceNameExists(name);
    return _respondJson(request.response, {'exists': exists});
  }

  Future<void> _handleSubmit(HttpRequest request) async {
    final body = await utf8.decodeStream(request);

    Map<String, dynamic> data;

    try {
      data = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return _respondError(request.response, 400, 'invalid_json');
    }

    final name = data['name'];
    if (name is String) {
      _existingNames.add(name.trim());
    }

    return _respondJson(request.response, {'ok': true});
  }

  Future<void> _serveStaticAsset(HttpRequest request) async {
    String path = request.uri.path;

    if (path == '/') {
      path = 'index.html';
    } else if (path.endsWith('/')) {
      path = '${path.substring(1)}index.html';
    } else {
      path = path.startsWith('/') ? path.substring(1) : path;
    }

    if (path.contains('..')) {
      return _respondError(request.response, 400, 'bad_path');
    }

    final assetKey = '$webAssetRootPath/$path';

    try {
      final data = await rootBundle.load(assetKey);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      final mime = _lookupMimeType(path);
      if (mime != null) {
        request.response.headers.contentType = ContentType.parse(mime);
      }

      request.response.add(bytes);
      await request.response.close();
    } catch (_) {
      return _respondEmpty(request.response, 404);
    }
  }

  Future<void> _respondJson(HttpResponse res, Object data) async {
    res.statusCode = 200;
    res.headers.contentType =
        ContentType('application', 'json', charset: 'utf-8');
    res.write(jsonEncode(data));
    await res.close();
  }

  Future<void> _respondError(HttpResponse res, int code, String error) async {
    res.statusCode = code;
    res.headers.contentType =
        ContentType('application', 'json', charset: 'utf-8');
    res.write(jsonEncode({'error': error}));
    await res.close();
  }

  Future<void> _respondEmpty(HttpResponse res, int code) async {
    res.statusCode = code;
    await res.close();
  }

  void _applyCors(HttpResponse response) {
    response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
      ..set('Access-Control-Allow-Headers', 'Content-Type');
  }

  Future<String> _resolveLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: true,
      );

      for (final ni in interfaces) {
        for (final addr in ni.addresses) {
          if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
    } catch (_) {}

    return InternetAddress.loopbackIPv4.address;
  }

  static const Map<String, String> _mimeMap = {
    'html': 'text/html; charset=utf-8',
    'htm': 'text/html; charset=utf-8',
    'css': 'text/css; charset=utf-8',
    'js': 'application/javascript; charset=utf-8',
    'json': 'application/json; charset=utf-8',
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'gif': 'image/gif',
    'svg': 'image/svg+xml',
    'webp': 'image/webp',
    'ico': 'image/x-icon',
    'txt': 'text/plain; charset=utf-8',
    'woff': 'font/woff',
    'woff2': 'font/woff2',
    'ttf': 'font/ttf',
    'otf': 'font/otf',
    'map': 'application/json; charset=utf-8',
  };

  String? _lookupMimeType(String path) {
    final extIndex = path.lastIndexOf('.');
    if (extIndex < 0) return null;
    final ext = path.substring(extIndex + 1).toLowerCase();
    return _mimeMap[ext];
  }
}
