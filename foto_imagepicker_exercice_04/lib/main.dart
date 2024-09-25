import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: SampleImagePicker(),
    );
  }
}

class SampleImagePicker extends StatefulWidget {
  const SampleImagePicker({super.key});

  @override
  State<SampleImagePicker> createState() => _SampleImagePickerState();
}

class _SampleImagePickerState extends State<SampleImagePicker> {
  File? displayImage;

  final ImagePicker pickerObject = ImagePicker();

  Future<void> pickerImageFunction() async {
    final imagePicked =
        await pickerObject.pickImage(source: ImageSource.camera);
    if (imagePicked == null) return;

    final imageSaved = await saveImageFunction(imagePicked.path);
    setState(() {
      displayImage = imageSaved;
    });
  }

  Future<File> saveImageFunction(String imagePickedParameter) async {
    final directory = await getApplicationDocumentsDirectory();
    final nameImage = basename(imagePickedParameter);
    final newPathImage = '${directory.path}/$nameImage';

    return File(imagePickedParameter).copy(newPathImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                  radius: 100,
                  backgroundColor: displayImage == null ? Colors.grey : null,
                  backgroundImage:
                      displayImage != null ? FileImage(displayImage!) : null,
                  child: displayImage == null
                      ? Container(
                          width: 200,
                          height: 200,
                          child: Icon(Icons.people,
                              size: 100
                          ),
                        )
                      : null),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: pickerImageFunction,
                  child: Icon(Icons.camera),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
