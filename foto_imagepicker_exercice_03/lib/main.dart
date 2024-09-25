import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePicture(),
    );
  }
}

class HomePicture extends StatefulWidget {
  const HomePicture({super.key});

  @override
  State<HomePicture> createState() => _HomePictureState();
}

class _HomePictureState extends State<HomePicture> {
  File? Picture;

  ImagePicker picker = ImagePicker();

  Future<void> PickerImage() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if( photo != null){
      SavePhoto(File(photo.path));
    }
  }

  Future<void> SavePhoto(File image) async {
    Directory directory = Directory('/storage/emulated/0/Pictures');

    String nameImage = path.basename(image.path);
    String newDirectoryImage = path.join(directory.path, nameImage);

    File finalPhoto = await image.copy(newDirectoryImage);

    setState(() {
      Picture = finalPhoto;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('exercice_03_image_picker'),
      ),
      body: Center(
        child: Column(
          children: [
            Picture == null
                ? Text('Nenhuma foto capturada')
                : Image.file(Picture!),
            ElevatedButton(
              onPressed: PickerImage,
              child: Text('Tirar Foto'),
            )
          ],
        ),
      ),
    );
  }
}
