import 'package:flutter/material.dart';

class ConfirmDelete extends StatelessWidget {
  const ConfirmDelete(
      {super.key,
      required this.name,
      required this.confirm,
      required this.type});
  final VoidCallback confirm;
  final String type;
  final String name;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm deletion"),
      content: Text.rich(TextSpan(children: [
        TextSpan(text: "You are about to delete $type "),
        TextSpan(
            text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: ", are you sure?"),
      ])),
      actions: [
        TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              confirm();
            },
            child: const Text("Confirm")),
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"))
      ],
    );
  }
}
