import 'package:flutter/material.dart';

class CorrectionModal extends StatelessWidget {
  const CorrectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Is this the right URL?"),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Proceed anyway")),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Correct URL automatically"))
      ],
      content: const Text(
          "It seems your url is not pointing to an Xtream API server, Open TV can correct the URL automatically for you"),
    );
  }
}
