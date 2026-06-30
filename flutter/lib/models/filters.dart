import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/view_type.dart';

class Filters {
  String? query;
  List<int>? sourceIds;
  List<MediaType>? mediaTypes;
  ViewType viewType;
  int page;
  int? seriesId;
  int? groupId;
  bool useKeywords;

  Filters({
    this.query,
    this.sourceIds,
    this.mediaTypes,
    required this.viewType,
    this.page = 1,
    this.seriesId,
    this.groupId,
    this.useKeywords = false,
  });
}
