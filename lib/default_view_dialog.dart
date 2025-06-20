import 'package:flutter/material.dart';
import 'package:open_tv/models/view_type.dart';

class DefaultViewDialog extends StatelessWidget {
  const DefaultViewDialog({super.key, required this.action});
  final Function(ViewType view) action;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Default view"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            ViewType.values.take(4).map(getDefaultViewDialogItem).toList(),
      ),
    );
  }

  Widget getDefaultViewDialogItem(ViewType view) {
    return ListTile(
        title: Text(viewTypeToString(view)), onTap: () => action(view));
  }
}
