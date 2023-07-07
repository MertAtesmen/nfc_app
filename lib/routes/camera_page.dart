import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_text_recognition/learning_text_recognition.dart';
import 'package:learning_input_image/learning_input_image.dart';
import 'package:nfc_app/utils/file_operations.dart';
import 'package:nfc_app/utils/nfc_tag_operations.dart';
import 'package:provider/provider.dart';

import '../widgets/file_data.dart';

class CameraPage extends StatefulWidget {
  final CameraDescription description;
  final String tagID;
  final TextRecognition textRecognition;
  const CameraPage(
      {required this.textRecognition,
      required this.description,
      required this.tagID,
      super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;

  @override
  void initState() {
    _controller = CameraController(
      widget.description,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.textRecognition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FileData fileData = Provider.of<FileData>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          FutureBuilder(
            future: _controller.initialize(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPW(
                  tagID: widget.tagID,
                  controller: _controller,
                  textRecognition: widget.textRecognition,
                  currFile: fileData.currentFile,
                );
              }
              return const Center(
                child: Text("Loading.."),
              );
            },
          )
        ],
      ),
    );
  }
}

class CameraPW extends StatefulWidget {
  final CameraController controller;
  final TextRecognition textRecognition;
  final String tagID;
  final String currFile;
  const CameraPW(
      {required this.textRecognition,
      required this.tagID,
      required this.controller,
      super.key,
      required this.currFile});

  @override
  State<CameraPW> createState() => _CameraPwState();
}

enum CameraPWState {
  match,
  noMatch,
  counterExceed;
}

class _CameraPwState extends State<CameraPW> {
  bool _lock = false;
  bool _wrongSize = false;

  void _checkImage(CameraImage image) {
    {
      if (_lock) return;
      /*if (_counter > 100) {
        widget.controller.stopImageStream();
        setState(() {
          _cameraPWState = CameraPWState.counterExceed;
        });
        Future.delayed(const Duration(milliseconds: 2000),
            () => Navigator.of(context).pop());
      }*/
      setState(() {
        _lock = true;
      });
      _proccesImage(image).then((temp) {
        // if (_counter > 100) return;
        String recognizedText = temp == null ? "" : temp.text.split(" ").join();
        recognizedText.replaceAll(" ", "");
        bool isTag = isAtag(recognizedText);
        if (!isTag) {
          setState(() {
            _lock = false;
          });
          return;
        }
        if (recognizedText.length != 12 && recognizedText.isNotEmpty) {
          setState(() {
            _lock = false;
            _wrongSize = true;
          });
          return;
        }
        if (recognizedText == widget.tagID) {
          setState(() {});
          addTag(file: File(widget.currFile), tag: widget.tagID);

          Navigator.of(context).pop();
          Future.delayed(
            const Duration(milliseconds: 200),
            () => Fluttertoast.showToast(
              msg: "Tag Added",
              toastLength: Toast.LENGTH_SHORT,
            ),
          );
        } else {
          setState(() {
            _lock = false;
            _wrongSize = false;
          });
        }
      });
    }
  }

  Future<RecognizedText?> _proccesImage(CameraImage image) async {
    WriteBuffer writeBuffer = WriteBuffer();
    for (Plane plane in image.planes) {
      writeBuffer.putUint8List(plane.bytes);
    }
    Uint8List bytes = writeBuffer.done().buffer.asUint8List();
    var inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageData(
          size: Size(
            image.width.toDouble(),
            image.height.toDouble(),
          ),
          rotation: InputImageRotation.ROTATION_90),
    );

    return await widget.textRecognition.process(inputImage);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(milliseconds: 500),
        () =>
            widget.controller.startImageStream((image) => _checkImage(image)));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var fileData = Provider.of<FileData>(context);
    return Column(
      children: [
        Container(
          height: 400,
          alignment: Alignment.center,
          child: CameraPreview(widget.controller),
        ),
        SizedBox(
          height: 150,
          child: _wrongSize
              ? Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                  width: 200,
                  color: Colors.red,
                  child: const Center(
                    child: Text(
                      "The Length is Not Correct !",
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),
                )
              : Column(
                  children: [
                    const Text(
                      "The Expected tag ID is:",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.tagID,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
        ),
        SizedBox(
          height: 62,
          child: TextButton(
            onPressed: () {
              addTag(file: File(fileData.currentFile), tag: widget.tagID);
              Navigator.pop(context);
            },
            child: const Text("Add Anyways"),
          ),
        ),
      ],
    );
  }
}
