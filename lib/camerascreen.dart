import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  XFile? image;
  CroppedFile? croppedFile;
  bool transformImage = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text("Image Cropper"),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            if (croppedFile == null)
              GestureDetector(
                onTap: () {
                  selectImage();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150,
                    width: width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                        child: Text(
                      "Add Image",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                  ),
                ),
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "Transform Image",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      CupertinoSwitch(
                          value: transformImage,
                          onChanged: (val) {
                            setState(() {
                              transformImage = val;
                            });
                          }),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: transformImage ? Matrix4.rotationY(math.pi) : Matrix4.rotationY(0),
                            child: Container(
                              width: width,
                              constraints: const BoxConstraints(minHeight: 100),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.grey,
                                  )),
                              child: Image.file(
                                File(croppedFile!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -10,
                          right: 0,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  croppedFile = null;
                                });
                              },
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.lightBlue,
                              )),
                        )
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          selectImage();
        },
        child: const Icon(Icons.photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// Image Picker Define Source for Image
  Future<void> pickImages({required ImageSource source}) async {
    //ImageSource.gallery
    final pickedImg = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedImg != null) {
        image = pickedImg;
      }
    });
    cropImage().whenComplete(() {
      Navigator.pop(context);
    });
  }

  /// Select an Image
  Future selectImage() async {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            color: const Color(0xff757575),
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(18),
                    topLeft: Radius.circular(18),
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      pickImages(source: ImageSource.camera);
                    },
                    child: pickImageButton(
                      text: "Camera",
                      icon: Icons.camera,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      pickImages(source: ImageSource.gallery);
                    },
                    child: pickImageButton(
                      text: "Gallery",
                      icon: Icons.photo,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  ///Image Cropper to Crop the Image
  Future cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    setState(() {
      this.croppedFile = croppedFile;
    });
  }

  ///Image Picker Button for BottomSheet
  pickImageButton({required String text, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 16),
      child: Container(
        height: 45,
        constraints: const BoxConstraints(
          minWidth: 150.0,
        ),
        decoration: BoxDecoration(
          color: Colors.lightBlue,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
