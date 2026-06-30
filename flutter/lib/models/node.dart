import 'package:open_tv/models/node_type.dart';

class Node {
  final int id;
  final String name;
  final NodeType type;
  String? query;
  Node({
    required this.id,
    required this.name,
    required this.type,
    this.query,
  });
  @override
  String toString() {
    return name;
  }
}
