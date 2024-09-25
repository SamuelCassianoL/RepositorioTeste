import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerExample(),
    );
  }
}

class ImagePickerExample extends StatefulWidget {
  const ImagePickerExample({super.key});

  @override
  State<ImagePickerExample> createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
  List<File> displayImages = [];
  final ImagePicker pickerObject = ImagePicker();



  Future<void> pickerImageFunction() async {
    final pickedImage =
        await pickerObject.pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;

    final imageSaved = await saveImageFunction(File(pickedImage.path));

    setState(() {
      displayImages.add(imageSaved);
    });
  }

  Future<File> saveImageFunction(File imagePickedParameter) async {
    final directory = await getApplicationDocumentsDirectory();
    final newPathImage =
        '${directory.path}/${imagePickedParameter.uri.pathSegments.last}';

    return imagePickedParameter.copy(newPathImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          displayImages.isEmpty
              ? Center(
                  child: Text('Nenhuma foto capturada'),
                )
              : Expanded(
                child: Center(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      ),
                      itemCount: displayImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(2),
                          child: Image.file(displayImages[index]),
                        );
                      },
                    ),
                  ),
              ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                pickerImageFunction();
              },
              child: Icon(Icons.camera),
            ),
          )
        ],
      ),
    );
  }
}
