import 'dart:collection';

import 'package:open_tv/backend/db_factory.dart';
import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/channel_http_headers.dart';
import 'package:open_tv/models/filters.dart';
import 'package:open_tv/models/id_data.dart';
import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/source.dart';
import 'package:open_tv/models/source_type.dart';
import 'package:open_tv/models/view_type.dart';
import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

const int pageSize = 36;

class Sql {
  static commitWrite(
      List<Future<void> Function(SqliteWriteContext, Map<String, String>)>
          commits) async {
    var db = await DbFactory.db;
    Map<String, String> memory = {};
    await db.writeTransaction((tx) async {
      for (var commit in commits) {
        await commit(tx, memory);
      }
    });
  }

  static Future<void> Function(SqliteWriteContext, Map<String, String> memory)
      insertChannel(Channel channel) {
    return (SqliteWriteContext tx, Map<String, String> memory) async {
      await tx.execute('''
        INSERT INTO channels (name, image, url, source_id, media_type, series_id, favorite, stream_id, group_name)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT (name, source_id)
        DO UPDATE SET
          url = excluded.url,
          group_name = excluded.group_name,
          media_type = excluded.media_type,
          stream_id = excluded.stream_id,
          image = excluded.image,
          series_id = excluded.series_id;
      ''', [
        channel.name,
        channel.image,
        channel.url,
        int.parse(memory['sourceId']!),
        channel.mediaType.index,
        channel.seriesId,
        channel.favorite,
        channel.streamId,
        channel.group
      ]);
      memory['lastChannelId'] =
          (await tx.get("SELECT last_insert_rowid()")).columnAt(0).toString();
    };
  }

  static Future<void> Function(SqliteWriteContext, Map<String, String>)
      updateGroups() {
    return (SqliteWriteContext tx, Map<String, String> memory) async {
      var sourceId = int.parse(memory['sourceId']!);
      await tx.execute('''
      INSERT INTO groups (name, image, source_id)
      SELECT group_name, image, ?
      FROM channels
      WHERE source_id = ?
      GROUP BY group_name;
      ON CONFLICT(name, source_id) DO NOTHING;
    ''', [sourceId, sourceId]);
      await tx.execute('''
      UPDATE channels
      SET group_id = (SELECT id FROM groups WHERE groups.name = channels.group_name);
      WHERE source_id = ?;
    ''');
    };
  }

  static Future<void> Function(SqliteWriteContext, Map<String, String>)
      insertChannelHeaders(ChannelHttpHeaders headers) {
    return (SqliteWriteContext tx, Map<String, String> memory) async {
      await tx.execute('''
          INSERT OR IGNORE INTO channel_http_headers (channel_id, referrer, user_agent, http_origin, ignore_ssl)
          VALUES (?, ?, ?, ?, ?)
        ''', [
        int.parse(memory['lastChannelId']!),
        headers.referrer,
        headers.userAgent,
        headers.httpOrigin,
        headers.ignoreSSL
      ]);
    };
  }

  static Future<void> Function(SqliteWriteContext, Map<String, String>)
      getOrCreateSourceByName(Source source) {
    return (SqliteWriteContext tx, Map<String, String> memory) async {
      var sourceId = (await tx.getOptional(
              "SELECT id FROM sources WHERE name = ?", [source.name]))
          ?.columnAt(0);
      if (sourceId != null) {
        memory['sourceId'] = sourceId.toString();
        return;
      }
      await tx.execute('''
            INSERT INTO sources (name, source_type, url, username, password) VALUES (?, ?, ?, ?, ?);
          ''', [
        source.name,
        source.sourceType.index,
        source.url,
        source.username,
        source.password,
      ]);
      memory['sourceId'] =
          (await tx.get("SELECT last_insert_rowid();")).columnAt(0).toString();
    };
  }

  static Future<List<Channel>> search(Filters filters) async {
    if (filters.viewType == ViewType.categories &&
        filters.groupId == null &&
        filters.seriesId == null) {
      return searchGroup(filters);
    }
    var db = await DbFactory.db;
    var offset = filters.page * pageSize - pageSize;
    var mediaTypes =
        filters.seriesId == null ? filters.mediaTypes.map((x) => x.index) : [1];
    var query = filters.query ?? "";
    var keywords = filters.useKeywords
        ? query.split(" ").map((f) => "%$f%").toList()
        : ["%$query%"];
    var sqlQuery = '''
        SELECT * FROM channels 
        WHERE (${getKeywordsSql(keywords.length)})
        AND media_type IN (${generatePlaceholders(mediaTypes.length)})
        AND source_id IN (${generatePlaceholders(filters.sourceIds.length)})
        AND url IS NOT NULL
    ''';
    List<Object> params = [];
    if (filters.viewType == ViewType.favorites && filters.seriesId == null) {
      sqlQuery += "\nAND favorite = 1";
    }
    if (filters.seriesId != null) {
      sqlQuery += "\nAND series_id = ?";
    } else if (filters.groupId != null) {
      sqlQuery += "\nAND group_id = ?";
    }
    sqlQuery += "\nLIMIT ?, ?";
    params.addAll(keywords);
    params.addAll(mediaTypes);
    params.addAll(filters.sourceIds);
    if (filters.seriesId != null) {
      params.add(filters.seriesId!);
    } else if (filters.groupId != null) {
      params.add(filters.groupId!);
    }
    params.add(offset);
    params.add(pageSize);
    var results = await db.getAll(sqlQuery, params);
    return results.map(rowToChannel).toList();
  }

  static Channel rowToChannel(Row row) {
    return Channel(
      id: row.columnAt(0),
      name: row.columnAt(1),
      group: row.columnAt(2),
      image: row.columnAt(3),
      url: row.columnAt(4),
      mediaType: MediaType.values[row.columnAt(5)],
      sourceId: row.columnAt(6),
      favorite: row.columnAt(7) == 1,
      seriesId: row.columnAt(8),
      groupId: row.columnAt(9),
    );
  }

  static String generatePlaceholders(int size) {
    return List.filled(size, "?").join(",");
  }

  static getKeywordsSql(int size) {
    return List.generate(size, (_) => "name LIKE ?").join(" AND ");
  }

  static Future<List<Channel>> searchGroup(Filters filters) async {
    var db = await DbFactory.db;
    var offset = filters.page * pageSize - pageSize;
    var query = filters.query ?? "";
    var keywords = filters.useKeywords
        ? query.split(" ").map((f) => "%$f%").toList()
        : ["%$query%"];
    var sqlQuery = '''
        SELECT * FROM groups 
        WHERE (${getKeywordsSql(keywords.length)})
        AND source_id IN (${generatePlaceholders(filters.sourceIds.length)})
        LIMIT ?, ?
    ''';
    List<Object> params = [];
    params.addAll(keywords);
    params.addAll(filters.sourceIds);
    params.add(offset);
    params.add(pageSize);
    var results = await db.getAll(sqlQuery, params);
    return results.map(groupChannelToRow).toList();
  }

  static Channel groupChannelToRow(Row row) {
    return Channel(
        id: row.columnAt(0),
        name: row.columnAt(1),
        image: row.columnAt(2),
        sourceId: row.columnAt(3),
        favorite: false,
        mediaType: MediaType.group);
  }

  static Future<bool> sourceNameExists(String? name) async {
    var db = await DbFactory.db;
    var result = await db.getOptional('''
      SELECT 1
      FROM sources
      WHERE name = ?
    ''', [name]);
    return result?.columnAt(0) == 1;
  }

  static Future<List<Source>> getSources() async {
    var db = await DbFactory.db;
    var results = await db.getAll('''
      SELECT * 
      FROM sources 
    ''');
    return results.map(rowToSource).toList();
  }

  static Source rowToSource(Row row) {
    return Source(
        id: row.columnAt(0),
        name: row.columnAt(1),
        sourceType: SourceType.values[row.columnAt(2)],
        url: row.columnAt(3),
        username: row.columnAt(4),
        password: row.columnAt(5),
        enabled: row.columnAt(6) == 1);
  }

  static Future<List<IdData<SourceType>>> getEnabledSourcesMinimal() async {
    var db = await DbFactory.db;
    var results = await db.getAll('''
      SELECT id, source_type
      FROM sources 
      WHERE enabled = 1
    ''');
    return results.map(rowToSourceMinimal).toList();
  }

  static IdData<SourceType> rowToSourceMinimal(Row row) {
    return IdData(
        id: row.columnAt(0), data: SourceType.values[row.columnAt(1)]);
  }

  static Future<bool> hasSources() async {
    var db = await DbFactory.db;
    var result = await db.getOptional('''
      SELECT 1
      FROM sources
      LIMIT 1
    ''');
    return result?.columnAt(0) == 1;
  }

  static Future<void> favoriteChannel(int channelId, bool favorite) async {
    var db = await DbFactory.db;
    await db.execute('''
      UPDATE channels
      SET favorite = ?
      WHERE id = ?
    ''', [favorite ? 1 : 0, channelId]);
  }

  static Future<HashMap<String, String>> getSettings() async {
    var db = await DbFactory.db;
    var results = await db.getAll('''SELECT key, value FROM Settings''');
    return HashMap.fromEntries(
        results.map((f) => MapEntry(f.columnAt(0), f.columnAt(1))));
  }

  static Future<void> updateSettings(HashMap<String, String> settings) async {
    var db = await DbFactory.db;
    await db.writeTransaction((tx) async {
      for (var entry in settings.entries) {
        await tx.execute('''
        INSERT INTO Settings (key, value)
        VALUES (?, ?)
        ON CONFLICT(key) DO UPDATE SET value = ?''',
            [entry.key, entry.value, entry.value]);
      }
    });
  }

  static deleteSource(int sourceId) async {
    var db = await DbFactory.db;
    await db.writeTransaction((tx) async {
      await tx.execute("DELETE FROM channels WHERE source_id = ?", [sourceId]);
      await tx.execute("DELETE FROM groups WHERE source_id = ?", [sourceId]);
      await tx.execute("DELETE FROM sources WHERE id = ?", [sourceId]);
    });
  }

  static Future<void> Function(SqliteWriteContext, Map<String, String>)
      wipeSource(int sourceId) {
    return (SqliteWriteContext tx, Map<String, String> memory) async {
      await tx.execute('''
        DELETE FROM channels 
        WHERE source_id = ? 
        AND favorite = 0
      ''', [sourceId]);
      await tx.execute('''
        DELETE FROM groups
        WHERE source_id = ?
      ''', [sourceId]);
    };
  }

  static updateSource(Source source) async {
    var db = await DbFactory.db;
    await db.execute('''
      UPDATE sources
      SET url = ?, username = ?, password = ?
      WHERE id = ?
    ''', [source.url, source.username, source.password, source.id]);
  }

  static Future<Source> getSourceFromId(int id) async {
    var db = await DbFactory.db;
    var result = await db.get('''SELECT * FROM sources WHERE id = ?''', [id]);
    return rowToSource(result);
  }

  static Future<void> setSourceEnabled(bool enabled, int sourceId) async {
    var db = await DbFactory.db;
    await db.execute('''
      UPDATE sources 
      SET enabled = ? 
      WHERE id = ?
    ''', [enabled, sourceId]);
  }
}
