use std::path::PathBuf;
use std::str::FromStr;
use std::sync::OnceLock;
use std::vec;
use std::{collections::HashMap, sync::LazyLock};

use crate::sort_type;
use crate::types::Season;
use crate::{
    media_type,
    types::{Channel, ChannelHttpHeaders, Filters, Source},
    view_type,
};
use anyhow::{Context, Result, anyhow};
use r2d2::{Pool, PooledConnection};
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::{OptionalExtension, Row, Transaction, params, params_from_iter};
use rusqlite_migration::{M, Migrations};

const PAGE_SIZE: u8 = 36;
pub const DB_NAME: &str = "db_rust.sqlite";
pub const DB_USER_NAME: &str = "db_rust_user.sqlite";
pub const LAST_SEEN_VERSION_KEY: &str = "last_seen_version";
pub static DB_PATH_OVERRIDE: OnceLock<String> = OnceLock::new();
static CONN: LazyLock<Pool<SqliteConnectionManager>> =
    LazyLock::new(|| create_connection_pool(DB_NAME, true));
static USER_CONN: LazyLock<Pool<SqliteConnectionManager>> =
    LazyLock::new(|| create_connection_pool(DB_USER_NAME, false));

pub fn get_conn() -> Result<PooledConnection<SqliteConnectionManager>> {
    CONN.try_get().context("No sqlite conns available")
}

pub fn get_user_conn() -> Result<PooledConnection<SqliteConnectionManager>> {
    USER_CONN.try_get().context("No sqlite conns available")
}

fn create_connection_pool(db_name: &str, attach_user_db: bool) -> Pool<SqliteConnectionManager> {
    let user_db_path = get_and_create_db_path(DB_USER_NAME);
    let manager =
        SqliteConnectionManager::file(get_and_create_db_path(db_name)).with_init(move |c| {
            c.pragma_update_and_check(None, "journal_mode", "WAL", |_| Ok(()))?;
            c.pragma_update(None, "temp_store", "MEMORY")?;
            if attach_user_db {
                c.execute("ATTACH DATABASE ?1 AS user_db", [&user_db_path])?;
                c.pragma_update_and_check(Some("user_db"), "journal_mode", "WAL", |_| Ok(()))?;
            }
            Ok(())
        });
    r2d2::Pool::builder().max_size(20).build(manager).unwrap()
}

fn get_and_create_db_path(db_name: &str) -> String {
    let mut path = PathBuf::from_str(DB_PATH_OVERRIDE.get().unwrap()).unwrap();
    if !path.exists() {
        std::fs::create_dir_all(&path).unwrap();
    }
    path.push(db_name);
    return path.to_string_lossy().to_string();
}

pub fn apply_migrations() -> Result<()> {
    apply_user_migrations()?;
    apply_main_migrations()?;
    Ok(())
}

fn apply_user_migrations() -> Result<()> {
    let mut conn = get_user_conn()?;
    let migrations = Migrations::new(vec![M::up(
        r#"
CREATE TABLE "settings" (
  "key"   VARCHAR(50) PRIMARY KEY,
  "value" VARCHAR(100)
);

CREATE TABLE "channel_user_data" (
  "channel_id"   INTEGER PRIMARY KEY,
  "favorite"     integer NOT NULL DEFAULT 0,
  "last_watched" integer,
  "position"     integer
);

CREATE INDEX index_channel_user_data_favorite ON channel_user_data(favorite);
CREATE INDEX index_channel_user_data_last_watched ON channel_user_data(last_watched);

ANALYZE;
"#,
    )]);
    migrations.to_latest(&mut conn)?;
    Ok(())
}

fn apply_main_migrations() -> Result<()> {
    let mut sql = get_conn()?;
    let migrations = Migrations::new(vec![
        M::up(
            r#"
CREATE TABLE "sources" (
  "id"                INTEGER PRIMARY KEY,
  "name"              varchar(100),
  "source_type"       integer,
  "url"               varchar(500),
  "username"          varchar(100),
  "password"          varchar(100),
  "enabled"           integer DEFAULT 1,
  "user_agent"        varchar(500),
  "stream_user_agent" varchar(500),
  "last_updated"      integer
);

CREATE TABLE "groups" (
  "id"          INTEGER PRIMARY KEY,
  "name"        varchar(100),
  "image"       varchar(500),
  "source_id"   integer,
  "media_type"  integer,
  FOREIGN KEY (source_id) REFERENCES sources(id)
);

CREATE TABLE "channels" (
  "id"           INTEGER PRIMARY KEY,
  "name"         varchar(100),
  "image"        varchar(500),
  "url"          varchar(500),
  "media_type"   integer,
  "source_id"    integer,
  "favorite"     integer,
  "series_id"    integer,
  "group_id"     integer,
  "stream_id"    integer,
  "last_watched" integer,
  "tv_archive"   integer,
  "season_id"    integer,
  "episode_num"  integer,
  FOREIGN KEY (source_id) REFERENCES sources(id),
  FOREIGN KEY (group_id) REFERENCES groups(id)
);

CREATE TABLE "channel_http_headers" (
  "id"           INTEGER PRIMARY KEY,
  "channel_id"   integer,
  "referrer"     varchar(500),
  "user_agent"   varchar(500),
  "http_origin"  varchar(500),
  "ignore_ssl"   integer DEFAULT 0,
  FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE
);

CREATE TABLE "movie_positions" (
  "id"         INTEGER PRIMARY KEY,
  "channel_id" integer,
  "position"   integer,
  FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE
);

CREATE TABLE "seasons" (
  "id"            INTEGER PRIMARY KEY,
  "name"          VARCHAR(50),
  "season_number" integer,
  "series_id"     integer,
  "source_id"     integer,
  "image"         varchar(200),
  FOREIGN KEY (source_id) REFERENCES sources(id) ON DELETE CASCADE
);

CREATE TABLE "settings" (
  "key"   VARCHAR(50) PRIMARY KEY,
  "value" VARCHAR(100)
);

CREATE INDEX index_channel_name ON channels(name);
CREATE UNIQUE INDEX channels_unique ON channels(name, source_id, url, series_id, season_id);

CREATE UNIQUE INDEX index_source_name ON sources(name);
CREATE INDEX index_source_enabled ON sources(enabled);

CREATE UNIQUE INDEX index_group_unique ON groups(name, source_id);
CREATE INDEX index_group_name ON groups(name);

CREATE INDEX index_channel_source_id ON channels(source_id);
CREATE INDEX index_channel_favorite ON channels(favorite);
CREATE INDEX index_channel_series_id ON channels(series_id);
CREATE INDEX index_channel_group_id ON channels(group_id);
CREATE INDEX index_channel_media_type ON channels(media_type);
CREATE INDEX index_channels_stream_id ON channels(stream_id);
CREATE INDEX index_channels_last_watched ON channels(last_watched);
CREATE INDEX index_channels_tv_archive ON channels(tv_archive);
CREATE INDEX index_channels_season_id ON channels(season_id);
CREATE INDEX index_channels_episode_num ON channels(episode_num);

CREATE INDEX index_group_source_id ON groups(source_id);
CREATE INDEX index_groups_media_type ON groups(media_type);

CREATE UNIQUE INDEX index_channel_http_headers_channel_id ON channel_http_headers(channel_id);
CREATE UNIQUE INDEX index_movie_positions_channel_id ON movie_positions(channel_id);
CREATE UNIQUE INDEX unique_seasons ON seasons(season_number, series_id, source_id);

ANALYZE;
"#,
        ),
        M::up(
            r#"
INSERT OR IGNORE INTO user_db.settings (key, value)
SELECT key, value FROM main.settings WHERE true;

CREATE TEMP TABLE channel_keep AS
SELECT id, MIN(id) OVER (
  PARTITION BY name, source_id, url, COALESCE(series_id, -1), COALESCE(season_id, -1)
) AS keep_id
FROM channels;

INSERT INTO user_db.channel_user_data (channel_id, favorite, last_watched)
SELECT k.keep_id, MAX(COALESCE(c.favorite, 0)), MAX(c.last_watched)
FROM channels c
JOIN temp.channel_keep k ON k.id = c.id
WHERE c.favorite = 1 OR c.last_watched IS NOT NULL
GROUP BY k.keep_id
ON CONFLICT (channel_id) DO UPDATE SET
  favorite = excluded.favorite,
  last_watched = excluded.last_watched;

INSERT INTO user_db.channel_user_data (channel_id, position)
SELECT k.keep_id, MAX(m.position)
FROM movie_positions m
JOIN temp.channel_keep k ON k.id = m.channel_id
WHERE m.position IS NOT NULL
GROUP BY k.keep_id
ON CONFLICT (channel_id) DO UPDATE SET position = excluded.position;

DELETE FROM channels
WHERE id IN (SELECT id FROM temp.channel_keep WHERE id != keep_id);

DROP TABLE temp.channel_keep;

DROP INDEX index_channel_favorite;
DROP INDEX index_channels_last_watched;
DROP INDEX channels_unique;
ALTER TABLE channels DROP COLUMN favorite;
ALTER TABLE channels DROP COLUMN last_watched;
DROP TABLE movie_positions;
DROP TABLE settings;

ALTER TABLE channels ADD COLUMN modified integer;
ALTER TABLE groups ADD COLUMN modified integer;

CREATE UNIQUE INDEX channels_unique
ON channels(name, source_id, url, COALESCE(series_id, -1), COALESCE(season_id, -1));

ANALYZE;
"#,
        ),
    ]);
    migrations.to_latest(&mut sql)?;
    Ok(())
}

fn create_or_find_source_by_name(tx: &Transaction, source: &Source) -> Result<i64> {
    let id: Option<i64> = tx
        .query_row(
            "SELECT id FROM sources WHERE name = ?1",
            params![source.name],
            |r| r.get(0),
        )
        .optional()?;
    if let Some(id) = id {
        return Ok(id);
    }
    tx.execute(
    "INSERT INTO sources (name, source_type, url, username, password, user_agent) VALUES (?, ?, ?, ?, ?, ?)",
    params![source.name, source.source_type.clone() as u8, source.url, source.username, source.password, source.user_agent],
    )?;
    Ok(tx.last_insert_rowid())
}

pub fn start_refresh(tx: &Transaction, source: &mut Source) -> Result<i64> {
    let source_id = match source.id {
        Some(id) => id,
        None => create_or_find_source_by_name(tx, source)?,
    };
    source.id = Some(source_id);
    Ok(tx.query_row(
        r#"
        UPDATE sources
        SET last_updated = MAX(?1, COALESCE(last_updated, 0) + 1)
        WHERE id = ?2
        RETURNING last_updated
        "#,
        params![chrono::Utc::now().timestamp(), source_id],
        |r| r.get(0),
    )?)
}

pub fn delete_stale(tx: &Transaction, source_id: i64, modified: i64) -> Result<()> {
    tx.execute(
        r#"
        DELETE FROM channels
        WHERE source_id = ?1
        AND series_id IS NULL
        AND modified IS NOT ?2
        "#,
        params![source_id, modified],
    )?;
    tx.execute(
        r#"
        DELETE FROM channels
        WHERE source_id = ?1
        AND series_id IS NOT NULL
        AND series_id NOT IN (
            SELECT CAST(url AS INTEGER)
            FROM channels
            WHERE source_id = ?1
            AND media_type = ?2
            AND url IS NOT NULL
        )
        "#,
        params![source_id, media_type::SERIE],
    )?;
    tx.execute(
        r#"
        DELETE FROM seasons
        WHERE source_id = ?1
        AND series_id NOT IN (
            SELECT CAST(url AS INTEGER)
            FROM channels
            WHERE source_id = ?1
            AND media_type = ?2
            AND url IS NOT NULL
        )
        "#,
        params![source_id, media_type::SERIE],
    )?;
    tx.execute(
        r#"
        DELETE FROM groups
        WHERE source_id = ?1
        AND modified IS NOT ?2
        "#,
        params![source_id, modified],
    )?;
    Ok(())
}

pub fn delete_orphan_user_data() -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        r#"
        DELETE FROM user_db.channel_user_data
        WHERE NOT EXISTS (
            SELECT 1 FROM main.channels c WHERE c.id = channel_user_data.channel_id
        )
        OR (favorite = 0 AND last_watched IS NULL AND position IS NULL)
        "#,
        params![],
    )?;
    Ok(())
}

pub fn insert_season(tx: &Transaction, season: Season) -> Result<i64> {
    tx.execute(
        r#"
        INSERT INTO seasons (name, image, series_id, season_number, source_id)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT (series_id, season_number, source_id)
        DO UPDATE SET
          image = excluded.image,
          name = excluded.name
        "#,
        params![
            season.name,
            season.image,
            season.series_id,
            season.season_number,
            season.source_id,
        ],
    )?;
    Ok(tx.query_row(
        r#"
        SELECT id
        FROM seasons
        WHERE series_id = ?
        AND season_number = ?
        AND source_id = ?
      "#,
        params![season.series_id, season.season_number, season.source_id],
        |r| r.get(0),
    )?)
}

pub fn insert_channel(tx: &Transaction, channel: Channel, modified: i64) -> Result<i64> {
    Ok(tx.prepare_cached(
        r#"
INSERT INTO channels (name, group_id, image, url, source_id, media_type, series_id, stream_id, tv_archive, season_id, episode_num, modified)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT (name, source_id, url, COALESCE(series_id, -1), COALESCE(season_id, -1))
DO UPDATE SET
    group_id = excluded.group_id,
    media_type = excluded.media_type,
    stream_id = excluded.stream_id,
    image = excluded.image,
    tv_archive = excluded.tv_archive,
    episode_num = excluded.episode_num,
    modified = excluded.modified
RETURNING id;
"#,
    )?
    .query_row(
        params![
            channel.name,
            channel.group_id,
            channel.image,
            channel.url,
            channel.source_id,
            channel.media_type as u8,
            channel.series_id,
            channel.stream_id,
            channel.tv_archive,
            channel.season_id,
            channel.episode_num,
            modified
        ],
        |r| r.get(0),
    )?)
}

pub fn set_channel_headers(
    tx: &Transaction,
    channel_id: i64,
    headers: Option<ChannelHttpHeaders>,
) -> Result<()> {
    let Some(headers) = headers else {
        tx.prepare_cached("DELETE FROM channel_http_headers WHERE channel_id = ?")?
            .execute(params![channel_id])?;
        return Ok(());
    };
    tx.prepare_cached(
        r#"
INSERT INTO channel_http_headers (channel_id, referrer, user_agent, http_origin, ignore_ssl)
VALUES (?, ?, ?, ?, ?)
ON CONFLICT (channel_id) DO UPDATE SET
    referrer = excluded.referrer,
    user_agent = excluded.user_agent,
    http_origin = excluded.http_origin,
    ignore_ssl = excluded.ignore_ssl;
"#,
    )?
    .execute(params![
        channel_id,
        headers.referrer,
        headers.user_agent,
        headers.http_origin,
        headers.ignore_ssl
    ])?;
    Ok(())
}

fn get_or_insert_group(
    tx: &Transaction,
    group: &str,
    image: &Option<String>,
    source_id: &i64,
    media_type: u8,
    modified: i64,
) -> Result<i64> {
    Ok(tx.query_row(
        r#"
        INSERT INTO groups (name, image, source_id, media_type, modified)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT (name, source_id) DO UPDATE SET modified = excluded.modified
        RETURNING id;
        "#,
        params![group, &image, source_id, media_type, modified],
        |row| row.get(0),
    )?)
}

pub fn set_channel_group_id(
    groups: &mut HashMap<String, i64>,
    channel: &mut Channel,
    tx: &Transaction,
    source_id: &i64,
    modified: i64,
) -> Result<()> {
    if channel.group.is_none() {
        return Ok(());
    }
    if !groups.contains_key(channel.group.as_ref().unwrap()) {
        let id = get_or_insert_group(
            tx,
            channel.group.as_ref().unwrap(),
            &channel.image,
            source_id,
            channel.media_type,
            modified,
        )?;
        groups.insert(channel.group.clone().unwrap(), id);
        channel.group_id = Some(id);
    } else {
        channel.group_id = groups
            .get(channel.group.as_ref().unwrap())
            .map(|x| x.to_owned());
    }
    Ok(())
}

pub fn get_channel_headers_by_id(id: i64) -> Result<Option<ChannelHttpHeaders>> {
    let sql = get_conn()?;
    let headers = sql
        .query_row(
            "SELECT * FROM channel_http_headers WHERE channel_id = ?",
            params![id],
            row_to_channel_headers,
        )
        .optional()?;
    Ok(headers)
}

fn row_to_channel_headers(row: &Row) -> Result<ChannelHttpHeaders, rusqlite::Error> {
    Ok(ChannelHttpHeaders {
        id: row.get("id")?,
        channel_id: row.get("channel_id")?,
        http_origin: row.get("http_origin")?,
        referrer: row.get("referrer")?,
        user_agent: row.get("user_agent")?,
        ignore_ssl: row.get("ignore_ssl")?,
    })
}

pub fn get_settings() -> Result<HashMap<String, String>> {
    let sql = get_user_conn()?;
    let map = sql
        .prepare("SELECT key, value FROM Settings")?
        .query_map([], |row| {
            let key: String = row.get(0)?;
            let value: String = row.get(1)?;
            Ok((key, value))
        })?
        .filter_map(Result::ok)
        .collect();
    Ok(map)
}

pub fn update_settings(map: HashMap<String, Option<String>>) -> Result<()> {
    let mut sql: PooledConnection<SqliteConnectionManager> = get_user_conn()?;
    let tx = sql.transaction()?;
    for (key, value) in map {
        tx.execute(
            r#"
            INSERT INTO Settings (key, value)
            VALUES (?1, ?2)
            ON CONFLICT(key) DO UPDATE SET value = ?2
            "#,
            params![key, value],
        )?;
    }
    tx.commit()?;
    Ok(())
}

pub fn search(filters: Filters) -> Result<Vec<Channel>> {
    if filters.view_type == view_type::CATEGORIES
        && filters.group_id.is_none()
        && filters.series_id.is_none()
    {
        return search_group(filters);
    }
    if filters.series_id.is_some() && filters.season.is_none() {
        return search_series(filters);
    }
    let sql = get_conn()?;
    let offset: u16 = filters.page as u16 * PAGE_SIZE as u16 - PAGE_SIZE as u16;
    let media_types = match filters.series_id.is_some() {
        true => vec![1],
        false => filters.media_types.clone().unwrap_or(vec![]),
    };
    let query = filters.query.unwrap_or("".to_string());
    let keywords: Vec<String> = match filters.use_keywords {
        true => query
            .split(" ")
            .map(|f| format!("%{f}%").to_string())
            .collect(),
        false => vec![format!("%{query}%")],
    };
    let mut sql_query = format!(
        r#"
        SELECT c.*, COALESCE(u.favorite, 0) AS favorite
        FROM channels c
        LEFT JOIN user_db.channel_user_data u ON u.channel_id = c.id
        WHERE ({})
        AND media_type IN ({})
        AND source_id IN ({})
        AND url IS NOT NULL"#,
        get_keywords_sql(keywords.len()),
        generate_placeholders(media_types.len()),
        generate_placeholders(filters.source_ids.len()),
    );
    let mut baked_params = 2;
    if filters.view_type == view_type::FAVORITES && filters.series_id.is_none() {
        sql_query += "\nAND u.favorite = 1";
    }

    if filters.series_id.is_some() {
        sql_query += &format!("\nAND series_id = ?");
        baked_params += 1;
    } else if filters.group_id.is_some() {
        sql_query += &format!("\nAND group_id = ?");
        baked_params += 1;
    }
    if filters.season.is_some() {
        sql_query += &format!("\nAND season_id = ?");
        baked_params += 1;
    }
    let order = match filters.sort {
        sort_type::ALPHABETICAL_DESC => "DESC",
        _ => "ASC",
    };
    if filters.view_type == view_type::HISTORY {
        sql_query += "\nAND u.last_watched IS NOT NULL";
        sql_query += "\nORDER BY u.last_watched DESC";
    } else if filters.season.is_some() {
        sql_query += &format!("\nORDER BY episode_num {0}, name {0}", order)
    } else if filters.sort != sort_type::PROVIDER {
        sql_query += &format!("\nORDER BY name {}", order);
    }
    sql_query += "\nLIMIT ?, ?";
    let mut params: Vec<&dyn rusqlite::ToSql> = Vec::with_capacity(
        baked_params + media_types.len() + filters.source_ids.len() + keywords.len(),
    );
    params.extend(to_to_sql(&keywords));
    params.extend(to_to_sql(&media_types));
    params.extend(to_to_sql(&filters.source_ids));
    if let Some(ref series_id) = filters.series_id {
        params.push(series_id);
    } else if let Some(ref group) = filters.group_id {
        params.push(group);
    }
    if let Some(ref season) = filters.season {
        params.push(season);
    }
    params.push(&offset);
    params.push(&PAGE_SIZE);
    let channels: Vec<Channel> = sql
        .prepare(&sql_query)?
        .query_map(params_from_iter(params), row_to_channel)?
        .filter_map(Result::ok)
        .collect();
    Ok(channels)
}

fn search_series(filters: Filters) -> Result<Vec<Channel>> {
    let sql = get_conn()?;
    let offset: u16 = filters.page as u16 * PAGE_SIZE as u16 - PAGE_SIZE as u16;
    let query = filters.query.unwrap_or("".to_string());
    let keywords: Vec<String> = match filters.use_keywords {
        true => query
            .split(" ")
            .map(|f| format!("%{f}%").to_string())
            .collect(),
        false => vec![format!("%{query}%")],
    };
    let mut sql_query = format!(
        r#"
      SELECT *
      FROM seasons
      WHERE ({})
      AND source_id = ?
      AND series_id = ?
      "#,
        get_keywords_sql(keywords.len()),
    );
    let order = match filters.sort {
        sort_type::ALPHABETICAL_DESC => "DESC",
        _ => "ASC",
    };
    sql_query += &format!("\nORDER BY season_number {}", order);
    sql_query += "\nLIMIT ?, ?";
    let mut params: Vec<&dyn rusqlite::ToSql> =
        Vec::with_capacity(2 + filters.source_ids.len() + keywords.len());
    params.extend(to_to_sql(&keywords));
    params.push(filters.source_ids.first().context("no source ids")?);
    params.push(filters.series_id.as_ref().context("no series id")?);
    params.push(&offset);
    params.push(&PAGE_SIZE);
    let channels: Vec<Channel> = sql
        .prepare(&sql_query)?
        .query_map(params_from_iter(params), season_row_to_channel)?
        .filter_map(Result::ok)
        .collect();
    Ok(channels)
}

fn season_row_to_channel(row: &Row) -> std::result::Result<Channel, rusqlite::Error> {
    Ok(Channel {
        id: row.get("id")?,
        image: row.get("image")?,
        favorite: false,
        group: None,
        group_id: None,
        media_type: media_type::SEASON,
        name: row.get("name")?,
        series_id: row.get("series_id")?,
        season_id: None,
        source_id: None,
        stream_id: None,
        tv_archive: None,
        url: None,
        episode_num: None,
    })
}

fn to_to_sql<T: rusqlite::ToSql>(values: &[T]) -> Vec<&dyn rusqlite::ToSql> {
    values.iter().map(|x| x as &dyn rusqlite::ToSql).collect()
}

fn get_keywords_sql(size: usize) -> String {
    std::iter::repeat("name LIKE ?")
        .take(size)
        .collect::<Vec<_>>()
        .join(" AND ")
}

fn generate_placeholders(size: usize) -> String {
    std::iter::repeat("?")
        .take(size)
        .collect::<Vec<_>>()
        .join(",")
}

pub fn series_has_episodes(series_id: i64, source_id: i64) -> Result<bool> {
    let sql = get_conn()?;
    let series_exists = sql
        .query_row(
            r#"
      SELECT 1
      FROM channels
      WHERE series_id = ? AND source_id = ?
      LIMIT 1
    "#,
            params![series_id, source_id],
            |row| row.get::<_, u8>(0),
        )
        .optional()?
        .is_some();
    Ok(series_exists)
}

pub fn search_group(filters: Filters) -> Result<Vec<Channel>> {
    let sql = get_conn()?;
    let offset: u16 = filters.page as u16 * PAGE_SIZE as u16 - PAGE_SIZE as u16;
    let query = filters.query.unwrap_or("".to_string());
    let media_types = filters.media_types.unwrap_or_else(|| vec![]);
    let keywords: Vec<String> = match filters.use_keywords {
        true => query
            .split(" ")
            .map(|f| format!("%{f}%").to_string())
            .collect(),
        false => vec![format!("%{query}%")],
    };
    let mut params: Vec<&dyn rusqlite::ToSql> = Vec::with_capacity(2 + filters.source_ids.len());
    let mut sql_query = format!(
        r#"
        SELECT *
        FROM groups
        WHERE ({})
        AND source_id in ({})
        AND (media_type IS NULL OR media_type in ({}))
    "#,
        get_keywords_sql(keywords.len()),
        generate_placeholders(filters.source_ids.len()),
        generate_placeholders(media_types.len())
    );
    if filters.sort != sort_type::PROVIDER {
        let order = match filters.sort {
            sort_type::ALPHABETICAL_ASC => "ASC",
            sort_type::ALPHABETICAL_DESC => "DESC",
            _ => "ASC",
        };
        sql_query += &format!("\nORDER BY name {}", order);
    }
    sql_query += "\nLIMIT ?, ?";
    params.extend(to_to_sql(&keywords));
    params.extend(to_to_sql(&filters.source_ids));
    params.extend(to_to_sql(&media_types));
    params.push(&offset);
    params.push(&PAGE_SIZE);
    let channels: Vec<Channel> = sql
        .prepare(&sql_query)?
        .query_map(params_from_iter(params), row_to_group)?
        .filter_map(Result::ok)
        .collect();
    Ok(channels)
}

fn row_to_group(row: &Row) -> std::result::Result<Channel, rusqlite::Error> {
    let channel = Channel {
        id: row.get("id")?,
        name: row.get("name")?,
        group: None,
        image: row.get("image")?,
        media_type: media_type::GROUP,
        url: None,
        series_id: None,
        group_id: None,
        favorite: false,
        source_id: row.get("source_id")?,
        stream_id: None,
        tv_archive: None,
        season_id: None,
        episode_num: None,
    };
    Ok(channel)
}

fn row_to_channel(row: &Row) -> std::result::Result<Channel, rusqlite::Error> {
    let channel = Channel {
        id: row.get("id")?,
        name: row.get("name")?,
        group_id: row.get("group_id")?,
        image: row.get("image")?,
        media_type: row.get("media_type")?,
        source_id: row.get("source_id")?,
        url: row.get("url")?,
        favorite: row.get("favorite")?,
        episode_num: row.get("episode_num")?,
        series_id: None,
        group: None,
        stream_id: row.get("stream_id")?,
        tv_archive: row.get("tv_archive")?,
        season_id: row.get("season_id")?,
    };
    Ok(channel)
}

pub fn delete_source(id: i64) -> Result<()> {
    let mut sql = get_conn()?;
    let tx = sql.transaction()?;
    tx.execute(
        r#"
        DELETE FROM channels
        WHERE source_id = ?;
    "#,
        params![id],
    )?;
    tx.execute(
        r#"
        DELETE FROM groups
        WHERE source_id = ?;
    "#,
        params![id],
    )?;
    tx.execute(
        r#"
        DELETE FROM seasons
        WHERE source_id = ?;
    "#,
        params![id],
    )?;
    let count = tx.execute(
        r#"
        DELETE FROM sources
        WHERE id = ?;
    "#,
        params![id],
    )?;
    if count != 1 {
        return Err(anyhow!("No sources were deleted"));
    }
    tx.commit()?;
    sql.execute("ANALYZE;", params![])?;
    Ok(())
}

pub fn source_name_exists(name: &str) -> Result<bool> {
    let sql = get_conn()?;
    Ok(sql
        .query_row(
            r#"
    SELECT 1
    FROM sources
    WHERE name = ?1
    "#,
            [name],
            |row| row.get::<_, u8>(0),
        )
        .optional()?
        .is_some())
}

pub fn favorite_channel(channel_id: i64, favorite: bool) -> Result<()> {
    let sql = get_user_conn()?;
    sql.execute(
        r#"
        INSERT INTO channel_user_data (channel_id, favorite)
        VALUES (?1, ?2)
        ON CONFLICT (channel_id) DO UPDATE SET favorite = excluded.favorite
    "#,
        params![channel_id, favorite],
    )?;
    Ok(())
}

pub fn get_sources() -> Result<Vec<Source>> {
    let sql = get_conn()?;
    let sources: Vec<Source> = sql
        .prepare("SELECT * FROM sources")?
        .query_map([], row_to_source)?
        .filter_map(Result::ok)
        .collect();
    Ok(sources)
}

pub fn get_enabled_sources_minimal() -> Result<Vec<i64>> {
    let sql = get_conn()?;
    Ok(sql
        .prepare("SELECT id FROM sources where enabled = 1")?
        .query_map([], |row| row.get(0))?
        .filter_map(Result::ok)
        .collect())
}

fn row_to_source(row: &Row) -> std::result::Result<Source, rusqlite::Error> {
    Ok(Source {
        id: row.get("id")?,
        name: row.get("name")?,
        username: row.get("username")?,
        password: row.get("password")?,
        url: row.get("url")?,
        source_type: row.get("source_type")?,
        url_origin: None,
        enabled: row.get("enabled")?,
        user_agent: row.get("user_agent")?,
        stream_user_agent: row.get("stream_user_agent")?,
        last_updated: row.get("last_updated")?,
    })
}

pub fn get_source_from_id(source_id: i64) -> Result<Source> {
    let sql = get_conn()?;
    Ok(sql.query_row(
        r#"
    SELECT * FROM sources where id = ?"#,
        [source_id],
        row_to_source,
    )?)
}

pub fn set_source_enabled(value: bool, source_id: i64) -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        r#"
        UPDATE sources
        SET enabled = ?
        WHERE id = ?
    "#,
        params![value, source_id],
    )?;
    Ok(())
}

pub fn do_tx<F, T>(f: F) -> Result<T>
where
    F: FnOnce(&Transaction) -> Result<T>,
{
    let mut sql = get_conn()?;
    let tx = sql.transaction()?;
    let result = f(&tx)?;
    tx.commit()?;
    Ok(result)
}

pub fn update_source(source: Source) -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        r#"
        UPDATE sources
        SET username = ?, password = ?, url = ?, user_agent = ?, stream_user_agent = ?
        WHERE id = ?"#,
        params![
            source.username,
            source.password,
            source.url,
            source.user_agent,
            source.stream_user_agent,
            source.id
        ],
    )?;
    Ok(())
}

pub fn analyze(tx: &Transaction) -> Result<()> {
    tx.execute("ANALYZE;", params![])?;
    Ok(())
}

pub fn add_last_watched(id: i64) -> Result<()> {
    let mut sql = get_user_conn()?;
    let tx = sql.transaction()?;
    tx.execute(
        r#"
          INSERT INTO channel_user_data (channel_id, last_watched)
          VALUES (?, strftime('%s', 'now'))
          ON CONFLICT (channel_id) DO UPDATE SET last_watched = excluded.last_watched
        "#,
        params![id],
    )?;
    tx.execute(
        r#"
		  UPDATE channel_user_data
          SET last_watched = NULL
          WHERE last_watched IS NOT NULL
		  AND channel_id NOT IN (
				SELECT channel_id
				FROM channel_user_data
				WHERE last_watched IS NOT NULL
				ORDER BY last_watched DESC
				LIMIT 36
		  )
        "#,
        params![],
    )?;
    tx.commit()?;
    Ok(())
}

pub fn clear_history() -> Result<()> {
    let sql = get_user_conn()?;
    sql.execute(
        r#"
          UPDATE channel_user_data
          SET last_watched = NULL
          WHERE last_watched IS NOT NULL
        "#,
        params![],
    )?;
    Ok(())
}

pub fn set_movie_position(channel_id: i64, movie_position: i64) -> Result<()> {
    let sql = get_user_conn()?;
    sql.execute(
        r#"
        INSERT INTO channel_user_data (channel_id, position)
        VALUES (?, ?)
        ON CONFLICT (channel_id) DO UPDATE SET position = excluded.position
        "#,
        params![channel_id, movie_position],
    )?;
    Ok(())
}

pub fn get_movie_position(channel_id: i64) -> Result<Option<i64>> {
    let sql = get_user_conn()?;
    let position: Option<Option<i64>> = sql
        .query_row(
            r#"
        SELECT position
        FROM channel_user_data
        WHERE channel_id = ?
        LIMIT 1
    "#,
            params!(channel_id),
            |row| row.get(0),
        )
        .optional()?;
    Ok(position.flatten())
}

pub fn get_whats_new() -> Result<Option<String>> {
    let sql = get_user_conn()?;
    let version: Option<String> = sql
        .query_row(
            r#"
        SELECT value 
        FROM settings
        WHERE key = ?
        LIMIT 1
    "#,
            params![LAST_SEEN_VERSION_KEY],
            |row| row.get(0),
        )
        .optional()?;
    Ok(version)
}

pub fn has_sources() -> Result<bool> {
    let sql = get_conn()?;
    Ok(sql
        .query_row("SELECT 1 FROM sources LIMIT 1", [], |row| {
            row.get::<_, u8>(0)
        })
        .optional()?
        .is_some())
}

pub fn get_sources_by_type(source_type: u8) -> Result<Vec<Source>> {
    let sql = get_conn()?;
    let sources: Vec<Source> = sql
        .prepare("SELECT * FROM sources WHERE source_type = ?")?
        .query_map([source_type], row_to_source)?
        .filter_map(Result::ok)
        .collect();
    Ok(sources)
}
