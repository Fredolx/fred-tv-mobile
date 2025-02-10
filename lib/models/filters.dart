import 'package:open_tv/models/media_type.dart';
import 'package:open_tv/models/view_type.dart';

class Filters {
  String? query;
  List<int> sourceIds;
  List<MediaType> mediaTypes;
  ViewType viewType;
  int page;
  int? seriesId;
  int? groupId;
  bool useKeywords;

  Filters({
    this.query,
    required this.sourceIds,
    required this.mediaTypes,
    required this.viewType,
    required this.page,
    this.seriesId,
    this.groupId,
    required this.useKeywords,
  });
}
