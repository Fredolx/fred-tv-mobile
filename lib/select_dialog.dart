import 'package:flutter/material.dart';
import 'package:open_tv/models/id_data.dart';

class SelectDialog extends StatelessWidget {
  const SelectDialog(
      {super.key,
      required this.action,
      required this.data,
      required this.title});
  final Function(int id) action;
  final List<IdData<String>> data;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: data.map(getItem).toList(),
      ),
    ));
  }

  Widget getItem(IdData<String> item) {
    return ListTile(title: Text(item.data), onTap: () => action(item.id));
  }
}
