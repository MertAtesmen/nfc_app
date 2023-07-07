import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences pref = await SharedPreferences.getInstance();

  Directory appDir = (await getExternalStorageDirectory()) ??
      (await getApplicationDocumentsDirectory());

  Directory fileDir = Directory("${appDir.path}/files");
  if (!fileDir.existsSync()) fileDir.createSync();

  runApp(
    MainApp(
      pref,
      directoryPath: fileDir.path,
    ),
  );
}
