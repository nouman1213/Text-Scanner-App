import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_recognizer/image_cropper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool textScanning = false;

  XFile? imageFile;
  bool isVisible = false;
  String scannedText = "";

  @override
  Widget build(BuildContext context) {
    var hieght = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: const Text("Text Scanner"),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.all(hieght * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (textScanning)
                  const Center(child: CircularProgressIndicator()),
                if (!textScanning && imageFile == null)
                  SizedBox(
                    width: double.infinity,
                    height: hieght * 0.4,
                   
                    
                    child: Image.asset('assets/bg.png'),
                  ),
                if (imageFile != null) Image.file(File(imageFile!.path)),
                SizedBox(
                  height: hieght * 0.024,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            backgroundColor: Colors.white,
                            shadowColor: Colors.grey[400],
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            scannedText = '';
                            getImage(ImageSource.gallery);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: hieght * 0.010,
                              horizontal: hieght * 0.010,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: hieght * 0.04,
                                  color: Colors.teal,
                                ),
                                Text(
                                  "Gallery",
                                  style: TextStyle(
                                      fontSize: hieght * 0.019,
                                      color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            backgroundColor: Colors.white,
                            shadowColor: Colors.grey[400],
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            scannedText = '';

                            getImage(ImageSource.camera);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: hieght * 0.010,
                              horizontal: hieght * 0.010,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: hieght * 0.04,
                                  color: Colors.teal,
                                ),
                                Text(
                                  "Camera",
                                  style: TextStyle(
                                      fontSize: hieght * 0.019,
                                      color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: hieght * 0.044,
                ),
                Text(
                  scannedText,
                  style: TextStyle(
                    fontSize: hieght * 0.03,
                  ),
                ),
                scannedText != ''
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              onPressed: () async {
                                FlutterClipboard.copy(scannedText).then(
                                  (value) {
                                    return ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text('Text Copied'),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.copy_rounded)),
                          IconButton(
                              onPressed: () async {
                                await FlutterShare.share(title: scannedText);
                              },
                              icon: const Icon(Icons.share_rounded))
                        ],
                      )
                    : const Text('')
              ],
            )),
      )),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);

      if (pickedImage != null) {
        final croppedImage = await imageCropperView(pickedImage.path);
        XFile img = XFile(croppedImage);

        textScanning = true;
        imageFile = img;
        setState(() {});
        //print('....setsate done');

        getRecognisedText(img);
      }
    } catch (e) {
      textScanning = false;
      // print(">>>>>>>>>" + e.toString());
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
      }
    }
    textScanning = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }
}
