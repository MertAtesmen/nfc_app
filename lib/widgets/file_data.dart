import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileData extends ChangeNotifier {
  final SharedPreferences _pref;
  String currentFile = "";
  String directoryPath;

  FileData(this._pref, {required this.directoryPath}) {
    _getcurFile();
  }

  void _getcurFile() {
    String? temp = _pref.getString("currentFile");
    if (temp != null) {
      currentFile = temp;
    } else {
      _pref.setString("currentFile", "");
    }
  }

  void setCurrentFile(String path) async {
    currentFile = "";
    notifyListeners();
    currentFile = path;
    await _pref.setString("currentFile", path);
    notifyListeners();
  }
}
