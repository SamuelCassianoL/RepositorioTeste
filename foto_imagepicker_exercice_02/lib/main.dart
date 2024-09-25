import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PageCamera(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class PageCamera extends StatefulWidget {
  const PageCamera({super.key});

  @override
  State<PageCamera> createState() => _PageCameraState();
}

class _PageCameraState extends State<PageCamera> {
  File? pepinoDeNovo;

  ImagePicker imagePicker = ImagePicker();

  Future<void> PickerImage() async {
    final XFile? imagePicked =
        await imagePicker.pickImage(source: ImageSource.camera);

    if (imagePicked != null) {
      saveImage(File(imagePicked.path));
    }
  }

  Future<void> saveImage(File image) async {
    Directory? directory = Directory('/storage/emulated/0/Pictures');



    String imageName = path.basename(image.path);
    print('Olha o valor samuel ${image.path}');
    String imagePath = path.join(directory.path, imageName);

    File finalImage = await image.copy(imagePath);

    setState(() {
      pepinoDeNovo = finalImage;
    });

    print('Olha o valor samuel ${image}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercice_02_imagepicker'),
      ),
      body: Center(
        child: Column(
          children:  [
            pepinoDeNovo != null ?
                Image.file(pepinoDeNovo!) :
                Text('nenhuma image capturada'),

            ElevatedButton(onPressed: PickerImage, child: Text('Tirar Foto'))
          ],
        ),
      ),
    );
  }
}
