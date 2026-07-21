import 'package:flutter/widgets.dart';

class IdData<T> {
  int id;
  T data;
  IconData? icon;

  IdData({required this.id, required this.data, this.icon});
}
