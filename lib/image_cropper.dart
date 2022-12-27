import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

imageCropperView(var path) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: path!,
    compressQuality: 80,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.teal,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      IOSUiSettings(
        title: 'Crop Image',
      ),
    ],
  );

  if (croppedFile != null) {
    log("Image cropped");
    return croppedFile.path;
  } else {
    log("Do nothing");
    return '';
  }
}
