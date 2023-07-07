import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:learning_text_recognition/learning_text_recognition.dart';
import 'package:nfc_app/utils/file_operations.dart';
import 'package:nfc_app/utils/nfc_tag_operations.dart';
import 'package:nfc_app/widgets/main_page_button.dart';
import 'package:nfc_app/widgets/nfc_alert_box.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';

import 'camera_page.dart';
import '../widgets/file_data.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _onTheScreen = false;

  void toggleOnScreen() async {
    Future(
      () => setState(
        () {
          _onTheScreen = !_onTheScreen;
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fileData = Provider.of<FileData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            fileData.currentFile == ""
                ? "Chose a File"
                : "Current File: ${basenameWithoutExtension(fileData.currentFile)}",
            style: const TextStyle(overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 10,
          ),
          FractionallySizedBox(
            alignment: Alignment.center,
            child: MainPageButton(
              routeName: "file_select_page",
              toggleFunction: toggleOnScreen,
              buttonText: "Chose File",
            ),
          ),
          FractionallySizedBox(
            alignment: Alignment.center,
            child: MainPageButton(
              routeName: "file_edit_page",
              toggleFunction: toggleOnScreen,
              buttonText: "Edit Files",
            ),
          ),
          StreamBuilder(
            stream: newNfcTAgStream(),
            builder: (context, snapshot) {
              print(snapshot.connectionState);
              if (snapshot.connectionState == ConnectionState.active) {
                NFCAvailability nfcAvailability = snapshot.data!.$1;
                if (_onTheScreen) {
                  return const SizedBox.shrink();
                }
                if (nfcAvailability == NFCAvailability.not_supported) {
                  return Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey,
                    ),
                    child: const Center(child: Text("Nfc is not supported")),
                  );
                }
                if (nfcAvailability == NFCAvailability.disabled) {
                  return Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey,
                    ),
                    child: const Center(child: Text("Nfc is disabled")),
                  );
                }
                if (nfcAvailability == NFCAvailability.available &&
                    fileData.currentFile != "") {
                  String tagId = getLabelTag(snapshot.data!.$2!.id);
                  Future(
                    () {
                      setState(() {
                        _onTheScreen = true;
                      });

                      if (getTags(file: File(fileData.currentFile))
                          .contains(tagId)) {
                        showDialog(
                          context: context,
                          builder: (context) => NfcAlertBox(tag: tagId),
                        ).then(
                          (value) => toggleOnScreen(),
                        );
                        return;
                      } else {
                        availableCameras().then((cameras) {
                          CameraDescription backCamera = cameras.firstWhere(
                              (element) =>
                                  element.lensDirection ==
                                  CameraLensDirection.back);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return CameraPage(
                                  textRecognition: TextRecognition(),
                                  description: backCamera,
                                  tagID: tagId,
                                );
                              },
                            ),
                          ).then((value) => toggleOnScreen());
                        });
                      }
                    },
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Icon(
                    Icons.phonelink_ring,
                    weight: 0.5,
                    size: 150,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Bring Phone closer to \nNfc Device",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Stream<NFCTag> nfcTagStream() async* {
  yield await FlutterNfcKit.poll(timeout: const Duration(days: 100));
  await Future.delayed(const Duration(seconds: 1));
  yield* nfcTagStream();
}

Stream<(NFCAvailability, NFCTag?)> newNfcTAgStream() async* {
  await Future.delayed(const Duration(milliseconds: 500));
  NFCAvailability nfcAvailability = await FlutterNfcKit.nfcAvailability;
  if (nfcAvailability == NFCAvailability.available) {
    NFCTag tag = await FlutterNfcKit.poll(
      timeout: const Duration(days: 100),
    );
    nfcAvailability = await FlutterNfcKit.nfcAvailability;
    yield (nfcAvailability, tag);
  } else {
    yield (nfcAvailability, null);
  }
  yield* newNfcTAgStream();
}
