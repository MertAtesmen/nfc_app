import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import "package:provider/provider.dart";

import '../widgets/file_data.dart';
import '../widgets/file_select_tile.dart';

class FileSelectionPage extends StatelessWidget {
  const FileSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fileData = Provider.of<FileData>(context);
    final fileList = Directory(fileData.directoryPath).listSync();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          fileData.currentFile == ""
              ? "Chose a File"
              : "Current File: ${basenameWithoutExtension(fileData.currentFile)}",
          style: const TextStyle(overflow: TextOverflow.ellipsis),
        ),
      ),
      body: ListView.builder(
          itemCount: fileList.length,
          itemBuilder: (context, index) {
            return FileSelectTile(file: fileList[index]);
          }),
    );
  }
}
