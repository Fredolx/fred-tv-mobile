import 'package:open_tv/models/media_type.dart';

class Channel {
  int? id;
  String? name;
  int? groupId;
  String? image;
  String? url;
  MediaType? mediaType;
  int? sourceId;
  bool? favorite;
  int? streamId;

  Channel({
    this.id,
    this.name,
    this.groupId,
    this.image,
    this.url,
    this.mediaType,
    this.sourceId,
    this.favorite,
    this.streamId,
  });
}
