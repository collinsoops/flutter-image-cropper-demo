import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/app_helper.dart';
import 'package:image/app_text_style.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _picker = ImagePicker();
  File? fileImage;

  _getImageFrom({required ImageSource source}) async {
    final _pickedImage = await _picker.pickImage(source: source);
    if (_pickedImage != null) {
      var image = File(_pickedImage.path.toString());
      final _sizeInKbBefore = image.lengthSync() / 1024;
      print('Size Before Compress $_sizeInKbBefore kb');
      var _compressedImage = await AppHelper.compress(image: image);
      final _sizeInKbAfter = _compressedImage.lengthSync() / 1024;
      print('Size After Compress $_sizeInKbAfter kb');
      var _croppedImage = await AppHelper.cropImage(_compressedImage);
      if (_croppedImage == null) {
        return;
      }
      setState(() {
        fileImage = _croppedImage as File?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Crop Demo"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (fileImage != null)
            Container(
              height: 350,
              width: 300,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Colors.grey,
                  image: DecorationImage(
                    image: FileImage(fileImage!),
                    fit: BoxFit.cover,
                  )),
            )
          else
            Container(
              height: 350,
              width: 350,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.grey[300],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Image will be shown here",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 20),
                  ),
                ],
              ),
            ),
          const SizedBox(
            height: 50,
          ),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  _openChangeImageBottomSheet();
                },
                child: const Text('Upload Image')),
          ),
        ],
      ),
    );
  }

  _openChangeImageBottomSheet() {
    return showCupertinoModalPopup(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(
              'Change Image',
              textAlign: TextAlign.center,
              style: AppTextStyles.regular(fontSize: 19),
            ),
            actions: <Widget>[
              _buildCupertinoActionSheetAction(
                icon: Icons.camera_alt,
                title: 'Take Photo',
                voidCallback: () {
                  Navigator.pop(context);
                  _getImageFrom(source: ImageSource.camera);
                },
              ),
              _buildCupertinoActionSheetAction(
                icon: Icons.image,
                title: 'Gallery',
                voidCallback: () {
                  Navigator.pop(context);
                  _getImageFrom(source: ImageSource.gallery);
                },
              ),
              _buildCupertinoActionSheetAction(
                title: 'Cancel',
                color: Colors.red,
                voidCallback: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  _buildCupertinoActionSheetAction({
    IconData? icon,
    required String title,
    required VoidCallback voidCallback,
    Color? color,
  }) {
    return CupertinoActionSheetAction(
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              color: color ?? const Color(0xFF2564AF),
            ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.regular(
                fontSize: 17,
                color: color ?? const Color(0xFF2564AF),
              ),
            ),
          ),
          if (icon != null)
            const SizedBox(
              width: 25,
            ),
        ],
      ),
      onPressed: voidCallback,
    );
  }
}
