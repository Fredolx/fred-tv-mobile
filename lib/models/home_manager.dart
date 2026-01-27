import 'package:open_tv/models/node.dart';
import 'package:open_tv/src/rust/api/sort_type.dart';
import 'package:open_tv/src/rust/api/types.dart';
import 'package:open_tv/src/rust/api/view_type.dart';

class HomeManager {
  final Filters filters;
  final Node? node;
  HomeManager({required this.filters, this.node});
  static HomeManager defaultManager() {
    return HomeManager(
      filters: Filters(
        viewType: ViewType.all,
        page: 1,
        useKeywords: false,
        sourceIds: <int>[],
        sort: SortType.provider,
      ),
      node: null,
    );
  }
}
