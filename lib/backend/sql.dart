import 'package:open_tv/models/channel.dart';
import 'package:open_tv/models/channel_http_headers.dart';
import 'package:open_tv/models/source.dart';
import 'package:sqlite_async/sqlite_async.dart';

const String dbName = "db.sqlite";

class Sql {
  static SqliteDatabase? _db;

  static Future<SqliteDatabase> _createDB() async {
    var db = SqliteDatabase(path: dbName);
    var migrations = SqliteMigrations()
      ..add(SqliteMigration(1, (tx) async {
        tx.execute('''
        CREATE TABLE "sources" (
          "id"          INTEGER PRIMARY KEY,
          "name"        varchar(100),
          "source_type" integer,
          "url"         varchar(500),
          "username"    varchar(100),
          "password"    varchar(100),
          "enabled"     integer DEFAULT 1
        );

        CREATE TABLE "channels" (
          "id" INTEGER PRIMARY KEY,
          "name" varchar(100),
          "group_name" varchar(100),
          "image" varchar(500),
          "url" varchar(500),
          "media_type" integer,
          "source_id" integer,
          "favorite" integer,
          "series_id" integer,
          "group_id" integer,
          "stream_id" integer,
          FOREIGN KEY (source_id) REFERENCES sources(id)
          FOREIGN KEY (group_id) REFERENCES groups(id)
        );

        CREATE TABLE "channel_http_headers" (
            "id" INTEGER PRIMARY KEY,
            "channel_id" integer,
            "referrer" varchar(500),
            "user_agent" varchar(500),
            "http_origin" varchar(500),
            "ignore_ssl" integer DEFAULT 0,
            FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE
        );
        CREATE UNIQUE INDEX index_channel_http_headers_channel_id ON channel_http_headers(channel_id);

        CREATE TABLE "settings" (
          "key" VARCHAR(50) PRIMARY KEY,
          "value" VARCHAR(100)
        );

        CREATE TABLE "groups" (
          "id" INTEGER PRIMARY KEY,
          "name" varchar(100),
          "image" varchar(500),
          "source_id" integer,
          FOREIGN KEY (source_id) REFERENCES sources(id)
        );

        CREATE INDEX index_channel_name ON channels(name);
        CREATE UNIQUE INDEX channels_unique ON channels(name, source_id);

        CREATE UNIQUE INDEX index_source_name ON sources(name);
        CREATE INDEX index_source_enabled ON sources(enabled);

        CREATE UNIQUE INDEX index_group_unique ON groups(name, source_id);
        CREATE INDEX index_group_name ON groups(name);

        CREATE INDEX index_channel_source_id ON channels(source_id);
        CREATE INDEX index_channel_favorite ON channels(favorite);
        CREATE INDEX index_channel_series_id ON channels(series_id);
        CREATE INDEX index_channel_group_id ON channels(group_id);
        CREATE INDEX index_channel_media_type ON channels(media_type);
        CREATE INDEX index_channels_stream_id on channels(stream_id);
        CREATE INDEX indeX_channels_group_name on channels(group_name);

        CREATE INDEX index_group_source_id ON groups(source_id);
      ''');
      }));
    migrations.migrate(db);
    return db;
  }

  static Future<SqliteDatabase> get db async {
    _db ??= await _createDB();
    return _db!;
  }

  static commitWrite(
      List<Future<void> Function(SqliteWriteContext, Map<String, String>)>
          commits) async {
    var db = await Sql.db;
    Map<String, String> memory = {};
    db.writeTransaction((tx) async {
      for (var commit in commits) {
        await commit(tx, memory);
      }
    });
  }

  static Future<void> Function(SqliteWriteContext, Map<String, String> memory)
      insertChannel(Channel channel) {
    return (SqliteWriteContext tx, Map<String, String> memory) async {
      memory['lastChannelId'] = (await tx.execute('''
        INSERT INTO channels (name, image, url, source_id, media_type, series_id, favorite, stream_id)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT (name, source_id)
        DO UPDATE SET
          url = excluded.url,
          group_name = excluded.group_name,
          media_type = excluded.media_type
          stream_id = excluded.stream_id,
          image = excluded.image,
          series_id = excluded.series_id;
        SELECT last_insert_rowid();
      ''', [
        channel.name,
        channel.image,
        channel.url,
        int.parse(memory['sourceId']!)
      ]))
          .elementAt(0)
          .columnAt(0);
    };
  }

  static Future<void> Function(SqliteWriteContext, Map<String, String>)
      updateGroups() {
    return (SqliteWriteContext tx, Map<String, String> memory) async {
      var sourceId = int.parse(memory['sourceId']!);
      await tx.execute('''
      INSERT INTO groups (group_name, ?)
      SELECT DISTINCT group_name FROM channel WHERE source_id = ?
      ON CONFLICT(group_name) DO NOTHING;

      UPDATE channel
      SET group_id = (SELECT id FROM groups WHERE groups.group_name = channel.group_name);
    ''', [sourceId, sourceId]);
    };
  }

  static Future<void> Function(SqliteWriteContext, Map<String, String>)
      insertChannelHeaders(ChannelHttpHeaders headers) {
    return (SqliteWriteContext tx, Map<String, String> memory) async {
      await tx.execute('''
          INSERT OR IGNORE INTO channel_http_headers (channel_id, referrer, user_agent, http_origin, ignore_ssl)
          VALUES (?, ?, ?, ?, ?)
        ''', [int.parse(memory['lastChannelId']!)]);
    };
  }

  static Future<void> Function(SqliteWriteContext, Map<String, String>)
      getOrCreateSourceByName(Source source) {
    return (SqliteWriteContext tx, Map<String, String> memory) async {
      int? sourceId =
          (await tx.get("SELECT id FROM sources WHERE name = ?", [source.name]))
              .columnAt(0);
      if (sourceId != null) {
        memory['sourceId'] = sourceId.toString();
        return;
      }
      memory['sourceId'] = (await tx.execute('''
            INSERT INTO sources (name, source_type, url, username, password) VALUES (?, ?, ?, ?, ?);
            SELECT last_insert_rowid();
          ''', [
        source.name,
        source.sourceType,
        source.url,
        source.username,
        source.password,
      ]))
          .elementAt(0)
          .columnAt(0);
    };
  }
}
