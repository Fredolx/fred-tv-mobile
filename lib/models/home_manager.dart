import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:open_tv/models/node.dart';
import 'package:open_tv/src/rust/api/types.dart';

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
        sourceIds: Int64List(0),
        sort: SortType.provider,
      ),
      node: null,
    );
  }
}
