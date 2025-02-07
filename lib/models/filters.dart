class Filters {
  String? query;
  List<int> sourceIds;
  List<int> mediaTypes;
  int viewType;
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
