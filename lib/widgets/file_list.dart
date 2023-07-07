import 'dart:io';

import 'package:flutter/material.dart';

//I used set for better performance when deleting by value and since it will not contain the same file i think there will be no drawback

//FileSet also controls the deleteMode for FileEditPage

class FileList extends ChangeNotifier {
  late List<ExpansionTileController> controllerList;
  List<FileSystemEntity> fileList;
  bool deleteMode = false;

  FileList({required this.fileList}) {
    controllerList = [for (var _ in fileList) ExpansionTileController()];
  }

  void removeByVal(FileSystemEntity file) {
    file.deleteSync();
    int index = fileList.indexOf(file);
    controllerList[index].collapse();

    notifyListeners();

    fileList.removeAt(index);
    controllerList.removeAt(index);

    notifyListeners();
  }

  void toggleDeleteMode() {
    deleteMode = !deleteMode;
    if (deleteMode == true) {
      for (ExpansionTileController controller in controllerList) {
        controller.collapse();
      }
    }
    notifyListeners();
  }

  void addFile(File file) async {
    await file.create();
    fileList.add(file);
    controllerList.add(ExpansionTileController());
    notifyListeners();
  }
}
