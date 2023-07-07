import 'package:flutter/material.dart';
import 'package:nfc_app/routes/file_edit_page.dart';
import 'package:nfc_app/routes/file_select_page.dart';
import 'package:nfc_app/routes/main_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/file_data.dart';

class MainApp extends StatelessWidget {
  final String directoryPath;

  final SharedPreferences pref;

  const MainApp(
    this.pref, {
    required this.directoryPath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FileData(pref, directoryPath: directoryPath),
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 16, 16, 205),
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routes: {
          "main_page": (context) => const MainPage(),
          "file_edit_page": (context) => const FileEditPage(),
          "file_select_page": (context) => const FileSelectionPage(),
        },
        initialRoute: "main_page",
      ),
    );
  }
}
