import 'package:open_tv/models/stack.dart';
import 'package:open_tv/src/rust/api/types.dart';

class Snapshot {
  final Stack stack;
  final Filters filters;
  Snapshot({required this.stack, required this.filters});
}
