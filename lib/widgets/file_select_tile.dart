import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'file_data.dart';

class FileSelectTile extends StatelessWidget {
  final FileSystemEntity file;
  const FileSelectTile({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final FileData fileData = Provider.of<FileData>(context);
    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => fileData.setCurrentFile(file.path),
      ),
      title: Text(basenameWithoutExtension(file.path)),
    );
  }
}
