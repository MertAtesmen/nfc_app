import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:nfc_app/utils/file_operations.dart';
import 'package:nfc_app/widgets/file_list.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'file_data.dart';

class FileEditTile extends StatefulWidget {
  final FileSystemEntity file;
  final ExpansionTileController controller;
  const FileEditTile({super.key, required this.file, required this.controller});

  @override
  State<FileEditTile> createState() => _FileEditTileState();
}

class _FileEditTileState extends State<FileEditTile> {
  List<String>? _tagList;

  void initTagList() {
    setState(() {
      _tagList = getTags(file: widget.file as File);
    });
  }

  void deleteTag(String tag) {
    setState(() {
      _tagList = deleteATag(file: widget.file as File, tag: tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final FileList fileSet = Provider.of<FileList>(context);
    final FileData fileData = Provider.of<FileData>(context);
    return ExpansionTile(
      title: Text(
        basenameWithoutExtension(widget.file.path),
      ),
      leading: fileSet.deleteMode
          ? IconButton(
              onPressed: () {
                if (widget.file.path == fileData.currentFile) {
                  fileData.setCurrentFile("");
                }
                fileSet.removeByVal(widget.file);
              },
              icon: const Icon(Icons.delete))
          : null,
      controller: widget.controller,
      onExpansionChanged: (value) {
        if (_tagList == null) {
          initTagList();
        }
      },
      trailing: IconButton(
        icon: const Icon(Icons.share),
        onPressed: () {
          Share.shareXFiles([XFile(widget.file.path)]);
        },
      ),
      children: _tagList == null
          ? const []
          : [
              for (String tag in _tagList!)
                ListTile(
                  leading: IconButton(
                    onPressed: () => deleteTag(tag),
                    icon: const Icon(Icons.delete),
                  ),
                  title: Text(tag),
                )
            ],
    );
  }
}
