import 'package:flutter/material.dart';

class NfcAlertBox extends StatelessWidget {
  final String tag;
  const NfcAlertBox({required this.tag, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Tag $tag already exists in the file"),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.exit_to_app),
        )
      ],
    );
  }
}
