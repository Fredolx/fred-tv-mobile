class XtreamStream {
  final String? streamId;
  final String? name;
  final String? categoryId;
  final String? streamIcon;
  final String? seriesId;
  final String? cover;
  final String? containerExtension;

  XtreamStream({
    this.streamId,
    this.name,
    this.categoryId,
    this.streamIcon,
    this.seriesId,
    this.cover,
    this.containerExtension,
  });

  factory XtreamStream.fromJson(Map<String, dynamic> json) {
    return XtreamStream(
      streamId: json['stream_id']?.toString(),
      name: json['name']?.toString(),
      categoryId: json['category_id']?.toString(),
      streamIcon: json['stream_icon']?.toString(),
      seriesId: json['series_id']?.toString(),
      cover: json['cover']?.toString(),
      containerExtension: json['container_extension']?.toString(),
    );
  }
}

class XtreamSeries {
  final List<XtreamEpisode> episodes;

  XtreamSeries({required this.episodes});

  factory XtreamSeries.fromJson(Map<String, dynamic> json) {
    List<XtreamEpisode> episodesList = [];
    if (json["episodes"] is Map) {
      json["episodes"].forEach((season, episodesListForSeason) {
        if (episodesListForSeason is List) {
          episodesList.addAll(
            episodesListForSeason.map(
              (episodeJson) => XtreamEpisode.fromJson(episodeJson),
            ),
          );
        }
      });
    }
    return XtreamSeries(episodes: episodesList);
  }
}

class XtreamEpisode {
  final String? id;
  final String? title;
  final String? containerExtension;
  final String? episodeNum;
  final String? season;
  final XtreamEpisodeInfo? info;

  XtreamEpisode({
    this.id,
    this.title,
    this.containerExtension,
    this.episodeNum,
    this.season,
    this.info,
  });

  factory XtreamEpisode.fromJson(Map<String, dynamic> json) {
    return XtreamEpisode(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      containerExtension: json['container_extension']?.toString(),
      episodeNum: json['episode_num']?.toString(),
      season: json['season']?.toString(),
      info: (json['info'] is Map)
          ? XtreamEpisodeInfo.fromJson(json['info'])
          : null,
    );
  }
}

class XtreamEpisodeInfo {
  final String? movieImage;

  XtreamEpisodeInfo({this.movieImage});

  factory XtreamEpisodeInfo.fromJson(Map<String, dynamic> json) {
    return XtreamEpisodeInfo(movieImage: json['movie_image']?.toString());
  }
}

class XtreamCategory {
  final String? categoryId;
  final String? categoryName;

  XtreamCategory({this.categoryId, this.categoryName});

  factory XtreamCategory.fromJson(Map<String, dynamic> json) {
    return XtreamCategory(
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name']?.toString(),
    );
  }
}

class XtreamEPG {
  final List<XtreamEPGItem> epgListings;

  XtreamEPG({required this.epgListings});

  factory XtreamEPG.fromJson(Map<String, dynamic> json) {
    var listings = <XtreamEPGItem>[];
    if (json['epg_listings'] is List) {
      listings = (json['epg_listings'] as List)
          .map((e) => XtreamEPGItem.fromJson(e))
          .toList();
    }
    return XtreamEPG(epgListings: listings);
  }
}

class XtreamEPGItem {
  final String? id;
  final String? title;
  final String? description;
  final String? startTimestamp;
  final String? stopTimestamp;

  XtreamEPGItem({
    this.id,
    this.title,
    this.description,
    this.startTimestamp,
    this.stopTimestamp,
  });

  factory XtreamEPGItem.fromJson(Map<String, dynamic> json) {
    return XtreamEPGItem(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      startTimestamp: json['start_timestamp']?.toString(),
      stopTimestamp: json['stop_timestamp']?.toString(),
    );
  }
}
