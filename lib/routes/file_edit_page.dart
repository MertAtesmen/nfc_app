import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nfc_app/widgets/file_edit_tile.dart';
import 'package:nfc_app/widgets/file_list.dart';
import "package:provider/provider.dart";
import 'package:path/path.dart';
import '../widgets/file_data.dart';

class FileEditPage extends StatelessWidget {
  const FileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    FileData fileData = Provider.of<FileData>(context);
    return ChangeNotifierProvider(
      create: (context) => FileList(
        fileList: Directory(fileData.directoryPath).listSync(),
      ),
      child: const _FileEditPage(),
    );
  }
}

class _FileEditPage extends StatefulWidget {
  const _FileEditPage({super.key});

  @override
  State<_FileEditPage> createState() => _FileEditPageState();
}

class _FileEditPageState extends State<_FileEditPage> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FileData fileData = Provider.of<FileData>(context);
    FileList fileSet = Provider.of<FileList>(context);

    void fieldTextOperation() {
      String value = _textEditingController.text;
      _textEditingController.text = "";

      if (value == "") return; //TO do make a file
      File file = File("${fileData.directoryPath}/$value.csv");

      bool contains = false;

      for (var element in fileSet.fileList) {
        if (element.path == file.path) {
          contains = true;
          break;
        }
      }
      if (!contains) {
        fileSet.addFile(file);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          fileData.currentFile == ""
              ? "Chose a File"
              : "Current File: ${basenameWithoutExtension(fileData.currentFile)}",
          style: const TextStyle(overflow: TextOverflow.ellipsis),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _textEditingController.text = "";
              fileSet.toggleDeleteMode();
            },
            icon: Icon(
              Icons.delete,
              color: fileSet.deleteMode ? Colors.red : Colors.grey,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                onSubmitted: (value) {
                  fieldTextOperation();
                },
              ),
            ),
            TextButton(
              onPressed: fieldTextOperation,
              child: const Text("Add"),
            ),
          ]),
          Expanded(
            child: ListView.builder(
              itemCount: fileSet.fileList.length,
              itemBuilder: (context, index) {
                return FileEditTile(
                  file: fileSet.fileList[index],
                  controller: fileSet.controllerList[index],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
