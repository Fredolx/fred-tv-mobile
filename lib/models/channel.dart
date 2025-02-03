import 'package:open_tv/models/media_type.dart';

class Channel {
  int? id;
  String name;
  int? groupId;
  String? group;
  String? image;
  String url;
  MediaType mediaType;
  int sourceId;
  bool favorite;
  int? seriesId;
  int? streamId;

  Channel({
    this.id,
    required this.name,
    this.group,
    this.groupId,
    this.image,
    required this.url,
    required this.mediaType,
    required this.sourceId,
    required this.favorite,
    this.seriesId,
    this.streamId,
  });
}
