use crate::api::types::{
    Channel,
    ChannelHttpHeaders,
    ChannelPreserve,
    Filters,
    MediaType,
    Season,
    SortType,
    Source,
    SourceType,
    ViewType, // avoid conflict if MediaType imported above
};
use anyhow::{anyhow, Context, Result};
use directories::ProjectDirs;
use r2d2::{Pool, PooledConnection};
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::{params, params_from_iter, OptionalExtension, Row, Transaction};
use rusqlite_migration::{Migrations, M};
use std::{collections::HashMap, sync::LazyLock};

const PAGE_SIZE: u8 = 36;
pub const DB_NAME: &str = "db.sqlite";
static CONN: LazyLock<Pool<SqliteConnectionManager>> = LazyLock::new(|| create_connection_pool());

pub(crate) fn get_conn() -> Result<PooledConnection<SqliteConnectionManager>> {
    CONN.try_get().context("No sqlite conns available")
}

fn create_connection_pool() -> Pool<SqliteConnectionManager> {
    let manager = SqliteConnectionManager::file(get_and_create_sqlite_db_path());
    r2d2::Pool::builder().max_size(20).build(manager).unwrap()
}

fn get_and_create_sqlite_db_path() -> String {
    let mut path = ProjectDirs::from("dev", "fredol", "open-tv")
        .unwrap()
        .data_dir()
        .to_owned();
    if !path.exists() {
        std::fs::create_dir_all(&path).unwrap();
    }
    path.push(DB_NAME);
    return path.to_string_lossy().to_string();
}

fn create_structure() -> Result<()> {
    let sql = get_conn()?;
    sql.execute_batch(
        r#"
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
  "image" varchar(500),
  "url" varchar(500),
  "media_type" integer,
  "source_id" integer,
  "favorite" integer,
  "series_id" integer,
  "group_id" integer,
  FOREIGN KEY (source_id) REFERENCES sources(id)
  FOREIGN KEY (group_id) REFERENCES groups(id)
);

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
CREATE UNIQUE INDEX channels_unique ON channels(name, url);

CREATE UNIQUE INDEX index_source_name ON sources(name);
CREATE INDEX index_source_enabled ON sources(enabled);

CREATE UNIQUE INDEX index_group_unique ON groups(name, source_id);
CREATE INDEX index_group_name ON groups(name);

CREATE INDEX index_channel_source_id ON channels(source_id);
CREATE INDEX index_channel_favorite ON channels(favorite);
CREATE INDEX index_channel_series_id ON channels(series_id);
CREATE INDEX index_channel_group_id ON channels(group_id);
CREATE INDEX index_channel_media_type ON channels(media_type);

CREATE INDEX index_group_source_id ON groups(source_id);
"#,
    )?;
    Ok(())
}

fn structure_exists() -> Result<bool> {
    let sql = get_conn()?;
    let table_exists: bool = sql
        .query_row(
            "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'channels' LIMIT 1",
            [],
            |row| row.get::<_, u8>(0),
        )
        .optional()?
        .is_some();
    Ok(table_exists)
}

pub(crate) fn create_or_initialize_db() -> Result<()> {
    if !structure_exists()? {
        create_structure()?;
    }
    apply_migrations()?;
    Ok(())
}

fn apply_migrations() -> Result<()> {
    let mut sql = get_conn()?;
    let migrations = Migrations::new(vec![
        M::up(
            r#"
                DROP INDEX IF EXISTS channels_unique;
                CREATE UNIQUE INDEX channels_unique ON channels(name, url, source_id);
                CREATE TABLE IF NOT EXISTS "channel_http_headers" (
                    "id" INTEGER PRIMARY KEY,
                    "channel_id" integer,
                    "referrer" varchar(500),
                    "user_agent" varchar(500),
                    "http_origin" varchar(500),
                    "ignore_ssl" integer DEFAULT 0,
                    FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE
                );
                CREATE UNIQUE INDEX IF NOT EXISTS index_channel_http_headers_channel_id ON channel_http_headers(channel_id);
                ALTER TABLE sources ADD COLUMN use_tvg_id integer;
                UPDATE sources SET use_tvg_id = 1 WHERE source_type in (0,1);
            "#,
        ),
        M::up(
            r#"
                ALTER TABLE channels ADD COLUMN stream_id integer;
                CREATE INDEX IF NOT EXISTS index_channels_stream_id on channels(stream_id);
                CREATE TABLE IF NOT EXISTS "epg" (
                  "id" INTEGER PRIMARY KEY,
                  "epg_id" varchar(25),
                  "channel_name" varchar(100),
                  "title" varchar(100),
                  "start_timestamp" INTEGER
                );
                CREATE UNIQUE INDEX IF NOT EXISTS index_epg_epg_id on epg(epg_id);
            "#,
        ),
        M::up(
            r#"
              ALTER TABLE channels ADD COLUMN last_watched integer;
              CREATE INDEX index_channels_last_watched on channels(last_watched);

              DROP INDEX IF EXISTS channels_unique;
              DELETE FROM channels
              WHERE ROWID NOT IN (
                  SELECT MIN(ROWID)
                  FROM channels
                  GROUP BY name, source_id
              );
              CREATE UNIQUE INDEX channels_unique ON channels(name, source_id);
            "#,
        ),
        M::up(
            r#"
              ALTER TABLE channels ADD COLUMN tv_archive integer;
              CREATE INDEX index_channels_tv_archive on channels(tv_archive);
            "#,
        ),
        M::up(
            r#"
              ALTER TABLE groups
              ADD COLUMN media_type INTEGER;
              CREATE INDEX index_groups_media_type ON groups(media_type);

              ALTER TABLE channels
              ADD COLUMN season_id INTEGER;
              CREATE INDEX index_channels_season_id ON channels(season_id);

              ALTER TABLE channels
              ADD COLUMN episode_num INTEGER;
              CREATE INDEX index_channels_episode_num on channels(episode_num);

              CREATE TABLE IF NOT EXISTS "seasons" (
                "id" INTEGER PRIMARY KEY,
                "name" VARCHAR(50),
                "season_number" INTEGER,
                "series_id" INTEGER,
                "source_id" INTEGER,
                "image" varchar(200),
                FOREIGN KEY (source_id) REFERENCES sources(id) ON DELETE CASCADE
              );
              CREATE INDEX index_seasons_name ON seasons(name);
              CREATE UNIQUE INDEX unique_seasons ON seasons(season_number, series_id, source_id);
            "#,
        ),
        M::up(
            r#"
              DROP INDEX IF EXISTS channels_unique;
              CREATE UNIQUE INDEX channels_unique ON channels(name, source_id, url, series_id, season_id);
        "#,
        ),
        M::up(
            r#"
              ALTER TABLE sources ADD COLUMN user_agent varchar(500);
              ALTER TABLE sources ADD COLUMN max_streams integer;
              ALTER TABLE sources ADD COLUMN stream_user_agent varchar(500);
              ALTER TABLE channels ADD COLUMN hidden integer DEFAULT 0;
              ALTER TABLE groups ADD COLUMN hidden integer DEFAULT 0;
              CREATE INDEX index_channels_hidden ON channels(hidden);
              CREATE INDEX index_groups_hidden ON groups(hidden);
              ANALYZE;
            "#,
        ),
        M::up(
            r#"
              ALTER TABLE sources ADD COLUMN last_updated integer;
              ANALYZE;
            "#,
        ),
    ]);
    migrations.to_latest(&mut sql)?;
    Ok(())
}

pub(crate) fn drop_db() -> Result<()> {
    let sql = get_conn()?;
    sql.execute_batch(
        "DROP TABLE channels; DROP TABLE groups; DROP TABLE sources; DROP TABLE settings;",
    )?;
    Ok(())
}

pub(crate) fn create_or_find_source_by_name(tx: &Transaction, source: &Source) -> Result<i64> {
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
    "INSERT INTO sources (name, source_type, url, username, password, use_tvg_id, user_agent, max_streams, last_updated) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
    params![source.name, source.source_type.clone() as u8, source.url, source.username, source.password, source.use_tvg_id, source.user_agent, source.max_streams, chrono::Utc::now().timestamp()],
    )?;
    Ok(tx.last_insert_rowid())
}

pub(crate) fn insert_season(tx: &Transaction, season: Season) -> Result<i64> {
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

pub(crate) fn insert_channel(tx: &Transaction, channel: Channel) -> Result<()> {
    tx.execute(
        r#"
INSERT INTO channels (name, group_id, image, url, source_id, media_type, series_id, favorite, stream_id, tv_archive, season_id, episode_num)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT (name, source_id, url, series_id, season_id)
DO UPDATE SET
    url = excluded.url,
    media_type = excluded.media_type,
    stream_id = excluded.stream_id,
    image = excluded.image,
    series_id = excluded.series_id,
    tv_archive = excluded.tv_archive,
    season_id = excluded.season_id;
"#,
        params![
            channel.name,
            channel.group_id,
            channel.image,
            channel.url,
            channel.source_id,
            channel.media_type as u8,
            channel.series_id,
            channel.favorite,
            channel.stream_id,
            channel.tv_archive,
            channel.season_id,
            channel.episode_num
        ],
    )?;
    Ok(())
}

pub(crate) fn insert_channel_headers(tx: &Transaction, headers: ChannelHttpHeaders) -> Result<()> {
    tx.execute(
        r#"
INSERT OR IGNORE INTO channel_http_headers (channel_id, referrer, user_agent, http_origin, ignore_ssl)
VALUES (?, ?, ?, ?, ?);
"#,
        params![
            headers.channel_id,
            headers.referrer,
            headers.user_agent,
            headers.http_origin,
            headers.ignore_ssl
        ],
    )?;
    Ok(())
}

fn get_or_insert_group(
    tx: &Transaction,
    group: &str,
    image: &Option<String>,
    source_id: &i64,
    media_type: MediaType,
) -> Result<i64> {
    let rows_changed = tx.execute(
        r#"
        INSERT OR IGNORE INTO groups (name, image, source_id, media_type)
        VALUES (?, ?, ?, ?);
        "#,
        params![group, &image, source_id, media_type as u8],
    )?;
    if rows_changed == 0 {
        return Ok(tx.query_row(
            "SELECT id FROM groups WHERE name = ? and source_id = ?",
            params![group, source_id],
            |row| row.get::<_, i64>("id"),
        )?);
    }
    Ok(tx.last_insert_rowid())
}

pub(crate) fn set_channel_group_id(
    groups: &mut HashMap<String, i64>,
    channel: &mut Channel,
    tx: &Transaction,
    source_id: &i64,
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

pub(crate) fn get_channel_headers_by_id(id: i64) -> Result<Option<ChannelHttpHeaders>> {
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

pub(crate) fn get_settings() -> Result<HashMap<String, String>> {
    let sql = get_conn()?;
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

pub(crate) fn update_settings(map: HashMap<String, String>) -> Result<()> {
    let mut sql: PooledConnection<SqliteConnectionManager> = get_conn()?;
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

pub(crate) fn search(filters: Filters) -> Result<Vec<Channel>> {
    if filters.view_type == ViewType::Categories
        && filters.group_id.is_none()
        && filters.series_id.is_none()
    {
        return search_group(filters);
    }
    if filters.view_type == ViewType::Hidden {
        return search_hidden(filters);
    }
    if filters.series_id.is_some() && filters.season.is_none() {
        return search_series(filters);
    }
    let sql = get_conn()?;
    let offset: u16 = filters.page as u16 * PAGE_SIZE as u16 - PAGE_SIZE as u16;
    let media_types = match filters.series_id.is_some() {
        true => vec![1],
        false => filters
            .media_types
            .clone()
            .unwrap()
            .iter()
            .map(|x| *x as u8)
            .collect(),
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
        SELECT * FROM CHANNELS
        WHERE ({})
        AND media_type IN ({})
        AND source_id IN ({})
        AND url IS NOT NULL
        AND hidden = 0"#,
        get_keywords_sql(keywords.len()),
        generate_placeholders(media_types.len()),
        generate_placeholders(filters.source_ids.len()),
    );
    let mut baked_params = 2;
    if filters.view_type == ViewType::Favorites && filters.series_id.is_none() {
        sql_query += "\nAND favorite = 1";
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
        SortType::AlphabeticalDesc => "DESC",
        _ => "ASC",
    };
    if filters.view_type == ViewType::History {
        sql_query += "\nAND last_watched IS NOT NULL";
        sql_query += "\nORDER BY last_watched DESC";
    } else if filters.season.is_some() {
        sql_query += &format!("\nORDER BY episode_num {0}, name {0}", order)
    } else if filters.sort != SortType::Provider {
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
        SortType::AlphabeticalDesc => "DESC",
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
        media_type: MediaType::Season,
        name: row.get("name")?,
        series_id: row.get("series_id")?,
        season_id: None,
        source_id: None,
        stream_id: None,
        tv_archive: None,
        url: None,
        episode_num: None,
        hidden: Some(false),
    })
}

fn search_hidden(filters: Filters) -> Result<Vec<Channel>> {
    let sql = get_conn()?;
    let offset: u16 = filters.page as u16 * PAGE_SIZE as u16 - PAGE_SIZE as u16;

    let media_types = match filters.series_id.is_some() {
        true => vec![1],
        false => filters
            .media_types
            .clone()
            .unwrap()
            .iter()
            .map(|x| *x as u8)
            .collect(),
    };

    let query = filters.query.unwrap_or("".to_string());
    let keywords: Vec<String> = match filters.use_keywords {
        true => query
            .split(" ")
            .map(|f| format!("%{f}%").to_string())
            .collect(),
        false => vec![format!("%{query}%")],
    };

    let keywords_sql = get_keywords_sql(keywords.len());
    let media_placeholders = generate_placeholders(media_types.len());
    let source_placeholders = generate_placeholders(filters.source_ids.len());

    let sql_query = format!(
        r#"
        SELECT id, image, name, series_id, source_id, stream_id, tv_archive, url, episode_num, hidden, media_type, NULL as group_id, NULL as season_id, favorite
        FROM channels
        WHERE ({})
        AND media_type IN ({})
        AND source_id IN ({})
        AND hidden = 1
        UNION ALL
        SELECT id, image, name, NULL as series_id, source_id, NULL as stream_id, NULL as tv_archive, NULL as url, NULL as episode_num, hidden, 3 as media_type, NULL as group_id, NULL as season_id, 0 as favorite
        FROM groups
        WHERE ({})
        AND source_id IN ({})
        AND (media_type IS NULL OR media_type IN ({}))
        AND hidden = 1
        ORDER BY name ASC
        LIMIT ?, ?
        "#,
        keywords_sql,
        media_placeholders,
        source_placeholders,
        keywords_sql,
        source_placeholders,
        media_placeholders
    );

    let mut params: Vec<&dyn rusqlite::ToSql> = Vec::new();

    // Channels params
    params.extend(to_to_sql(&keywords));
    params.extend(to_to_sql(&media_types));
    params.extend(to_to_sql(&filters.source_ids));

    // Groups params
    params.extend(to_to_sql(&keywords));
    params.extend(to_to_sql(&filters.source_ids));
    params.extend(to_to_sql(&media_types));

    params.push(&offset);
    params.push(&PAGE_SIZE);

    let channels: Vec<Channel> = sql
        .prepare(&sql_query)?
        .query_map(params_from_iter(params), row_to_channel)?
        .filter_map(Result::ok)
        .collect();

    Ok(channels)
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

pub(crate) fn series_has_episodes(series_id: u64, source_id: i64) -> Result<bool> {
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

fn to_sql_like(query: Option<String>) -> String {
    query.map(|x| format!("%{x}%")).unwrap_or("%".to_string())
}

pub(crate) fn search_group(filters: Filters) -> Result<Vec<Channel>> {
    let sql = get_conn()?;
    let offset: u16 = filters.page as u16 * PAGE_SIZE as u16 - PAGE_SIZE as u16;
    let query = filters.query.unwrap_or("".to_string());
    let media_types: Vec<u8> = filters
        .media_types
        .context("no media types")?
        .iter()
        .map(|x| *x as u8)
        .collect();
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
    sql_query += "\nAND hidden = 0";
    if filters.sort != SortType::Provider {
        let order = match filters.sort {
            SortType::AlphabeticalAsc => "ASC",
            SortType::AlphabeticalDesc => "DESC",
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
        media_type: MediaType::Group,
        url: None,
        series_id: None,
        group_id: None,
        favorite: false,
        source_id: row.get("source_id")?,
        stream_id: None,
        tv_archive: None,
        season_id: None,
        episode_num: None,
        hidden: row.get("hidden")?,
    };
    Ok(channel)
}

fn row_to_channel(row: &Row) -> std::result::Result<Channel, rusqlite::Error> {
    let media_type = row.get::<_, u8>("media_type")?;
    let channel = Channel {
        id: row.get("id")?,
        name: row.get("name")?,
        group_id: row.get("group_id")?,
        image: row.get("image")?,
        media_type: media_type.into(),
        source_id: row.get("source_id")?,
        url: row.get("url")?,
        favorite: row.get("favorite")?,
        episode_num: row.get("episode_num")?,
        series_id: None,
        group: None,
        stream_id: row.get("stream_id")?,
        tv_archive: row.get("tv_archive")?,
        season_id: row.get("season_id")?,
        hidden: row.get("hidden")?,
    };
    Ok(channel)
}

pub(crate) fn delete_channels_by_source(tx: &Transaction, source_id: i64) -> Result<()> {
    tx.execute(
        r#"
        DELETE FROM channels
        WHERE source_id = ?
    "#,
        params![source_id.to_string()],
    )?;
    Ok(())
}

pub(crate) fn delete_seasons_by_source(tx: &Transaction, source_id: i64) -> Result<()> {
    tx.execute(
        r#"
        DELETE FROM seasons
        WHERE source_id = ?
    "#,
        params![source_id],
    )?;
    Ok(())
}

pub(crate) fn delete_groups_by_source(tx: &Transaction, source_id: i64) -> Result<()> {
    tx.execute(
        r#"
        DELETE FROM groups
        WHERE source_id = ?
    "#,
        params!(source_id),
    )?;
    Ok(())
}

pub(crate) fn delete_source(id: i64) -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        r#"
        DELETE FROM channels
        WHERE source_id = ?;
    "#,
        params![id],
    )?;
    sql.execute(
        r#"
        DELETE FROM groups
        WHERE source_id = ?;
    "#,
        params![id],
    )?;
    sql.execute(
        r#"
        DELETE FROM seasons
        WHERE source_id = ?;
    "#,
        params![id],
    )?;
    let count = sql.execute(
        r#"
        DELETE FROM sources
        WHERE id = ?;
    "#,
        params![id],
    )?;
    if count != 1 {
        return Err(anyhow!("No sources were deleted"));
    }
    sql.execute("ANALYZE;", params![])?;
    Ok(())
}

pub(crate) fn get_channel_count_by_source(id: i64) -> Result<u64> {
    let sql = get_conn()?;
    let count = sql.query_row(
        "SELECT COUNT(*) FROM channels WHERE source_id = ?",
        params![id],
        |row| row.get::<_, u64>(0),
    )?;
    Ok(count)
}

pub(crate) fn source_name_exists(name: &str) -> Result<bool> {
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

pub(crate) fn favorite_channel(channel_id: i64, favorite: bool) -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        r#"
        UPDATE channels
        SET favorite = ?1
        WHERE id = ?2
    "#,
        params![favorite, channel_id],
    )?;
    Ok(())
}

pub(crate) fn hide_channel(channel_id: i64, hidden: bool) -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        r#"
        UPDATE channels
        SET hidden = ?1
        WHERE id = ?2
    "#,
        params![hidden, channel_id],
    )?;
    Ok(())
}

pub(crate) fn hide_group(group_id: i64, hidden: bool) -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        r#"
        UPDATE groups
        SET hidden = ?1
        WHERE id = ?2
    "#,
        params![hidden, group_id],
    )?;
    Ok(())
}

pub(crate) fn remove_last_watched(channel_id: i64) -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        r#"
        UPDATE channels
        SET last_watched = NULL
        WHERE id = ?1
    "#,
        params![channel_id],
    )?;
    Ok(())
}

pub(crate) fn get_sources() -> Result<Vec<Source>> {
    let sql = get_conn()?;
    let sources: Vec<Source> = sql
        .prepare("SELECT * FROM sources")?
        .query_map([], row_to_source)?
        .filter_map(Result::ok)
        .collect();
    Ok(sources)
}

pub(crate) fn get_enabled_sources() -> Result<Vec<Source>> {
    let sql = get_conn()?;
    let sources: Vec<Source> = sql
        .prepare("SELECT * FROM sources WHERE enabled = 1")?
        .query_map([], row_to_source)?
        .filter_map(Result::ok)
        .collect();
    Ok(sources)
}

fn row_to_source(row: &Row) -> std::result::Result<Source, rusqlite::Error> {
    Ok(Source {
        id: row.get("id")?,
        name: row.get("name")?,
        username: row.get("username")?,
        password: row.get("password")?,
        url: row.get("url")?,
        source_type: SourceType::from(row.get::<_, u8>("source_type")?),
        url_origin: None, // url_origin is not persisted or needed here?
        enabled: row.get("enabled")?,
        use_tvg_id: row.get("use_tvg_id")?,
        user_agent: row.get("user_agent")?,
        max_streams: row.get("max_streams")?,
        stream_user_agent: row.get("stream_user_agent")?,
        last_updated: row.get("last_updated")?,
    })
}

pub(crate) fn get_source_from_id(source_id: i64) -> Result<Source> {
    let sql = get_conn()?;
    Ok(sql.query_row(
        r#"
    SELECT * FROM sources where id = ?"#,
        [source_id],
        row_to_source,
    )?)
}

pub(crate) fn set_source_enabled(value: bool, source_id: i64) -> Result<()> {
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

fn channel_headers_empty(headers: &ChannelHttpHeaders) -> bool {
    return headers.ignore_ssl.is_none()
        && headers.http_origin.is_none()
        && headers.referrer.is_none()
        && headers.user_agent.is_none();
}

pub(crate) fn do_tx<F, T>(f: F) -> Result<T>
where
    F: FnOnce(&Transaction) -> Result<T>,
{
    let mut sql = get_conn()?;
    let tx = sql.transaction()?;
    let result = f(&tx)?;
    tx.commit()?;
    Ok(result)
}

pub(crate) fn update_source(source: Source) -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        r#"
        UPDATE sources
        SET username = ?, password = ?, url = ?, use_tvg_id = ?, user_agent = ?, max_streams = ?, stream_user_agent = ?
        WHERE id = ?"#,
        params![
            source.username,
            source.password,
            source.url,
            source.use_tvg_id,
            source.user_agent,
            source.max_streams,
            source.stream_user_agent,
            source.id
        ],
    )?;
    Ok(())
}

pub(crate) fn wipe(tx: &Transaction, id: i64) -> Result<()> {
    delete_seasons_by_source(tx, id)?;
    delete_channels_by_source(tx, id)?;
    delete_groups_by_source(tx, id)?;
    Ok(())
}

pub(crate) fn get_preserve(tx: &Transaction, source_id: i64) -> Result<Vec<ChannelPreserve>> {
    let mut channels: Vec<ChannelPreserve> = tx
        .prepare(
            r#"
              SELECT name, favorite, last_watched, hidden
              FROM channels
              WHERE (favorite = 1 OR last_watched IS NOT NULL OR hidden = 1)
              AND series_id IS NULL
              AND source_id = ?
            "#,
        )?
        .query_map(params![source_id], row_to_channel_preserve)?
        .filter_map(Result::ok)
        .collect();

    let groups: Vec<ChannelPreserve> = tx
        .prepare(
            r#"
              SELECT name, hidden
              FROM groups
              WHERE hidden = 1
              AND source_id = ?
            "#,
        )?
        .query_map(params![source_id], row_to_group_preserve)?
        .filter_map(Result::ok)
        .collect();

    channels.extend(groups);
    Ok(channels)
}

fn row_to_channel_preserve(row: &Row) -> Result<ChannelPreserve, rusqlite::Error> {
    Ok(ChannelPreserve {
        name: row.get("name")?,
        favorite: row.get("favorite")?,
        last_watched: row.get("last_watched")?,
        hidden: row.get("hidden")?,
        is_group: false,
    })
}

fn row_to_group_preserve(row: &Row) -> Result<ChannelPreserve, rusqlite::Error> {
    Ok(ChannelPreserve {
        name: row.get("name")?,
        hidden: row.get("hidden")?,
        favorite: false,
        last_watched: None,
        is_group: true,
    })
}

pub(crate) fn restore_preserve(
    tx: &Transaction,
    source_id: i64,
    preserve: Vec<ChannelPreserve>,
) -> Result<()> {
    for item in preserve {
        if item.is_group {
            tx.execute(
                r#"
                  UPDATE groups
                  SET hidden = ?
                  WHERE name = ?
                  AND source_id = ?
                "#,
                params![item.hidden, item.name, source_id],
            )?;
        } else {
            tx.execute(
                r#"
                  UPDATE channels
                  SET favorite = ?, last_watched = ?, hidden = ?
                  WHERE name = ?
                  AND source_id = ?
                "#,
                params![
                    item.favorite,
                    item.last_watched,
                    item.hidden,
                    item.name,
                    source_id
                ],
            )?;
        }
    }
    Ok(())
}

pub(crate) fn analyze(tx: &Transaction) -> Result<()> {
    tx.execute("ANALYZE;", params![])?;
    Ok(())
}

pub(crate) fn add_last_watched(id: i64) -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        r#"
          UPDATE channels
          SET last_watched = strftime('%s', 'now')
          WHERE id = ?
        "#,
        params![id],
    )?;
    sql.execute(
        r#"
		  UPDATE channels
          SET last_watched = NULL
          WHERE last_watched IS NOT NULL
		  AND id NOT IN (
				SELECT id
				FROM channels
				WHERE last_watched IS NOT NULL
				ORDER BY last_watched DESC
				LIMIT 36
		  )
        "#,
        params![],
    )?;
    Ok(())
}

pub(crate) fn clear_history() -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        r#"
          UPDATE channels
          SET last_watched = NULL
          WHERE last_watched IS NOT NULL
        "#,
        params![],
    )?;
    Ok(())
}

pub(crate) fn update_source_last_updated(source_id: i64) -> Result<()> {
    let sql = get_conn()?;
    sql.execute(
        "UPDATE sources SET last_updated = ? WHERE id = ?",
        params![chrono::Utc::now().timestamp(), source_id],
    )?;
    Ok(())
}

pub(crate) fn has_sources() -> Result<bool> {
    let sql = get_conn()?;
    Ok(sql
        .query_row(
            r#"
          SELECT 1
          FROM channels
          LIMIT 1
        "#,
            params![],
            |row| row.get::<_, u8>(0),
        )
        .optional()?
        .is_some())
}
