import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: PickerImage(),
    );
  }
}

class PickerImage extends StatefulWidget {
  const PickerImage({super.key});

  @override
  State<PickerImage> createState() => PickerImageState();
}


class PickerImageState extends State<PickerImage> {


  File? _image;

  final ImagePicker _picker = ImagePicker();



  Future<void> _pickerImage() async{

    final XFile? imagePicked = await _picker.pickImage(source: ImageSource.camera);

    if(imagePicked != null){
      await _saveImage(File(imagePicked.path));
    }
  }

  Future<void> _saveImage(File image) async{

    Directory? directory = Directory('/storage/emulated/0/Pictures');

    if (!await directory.exists()) {
      try {
        await directory.create(recursive: true);
        print('Diretório criado com sucesso.');
      } catch (e) {
        print('Erro ao criar diretório: $e');
        return;
      }
    } else {
      print('Diretório já existe.');
    }

    String imageName = path.basename(image.path);
    String newPathImage = path.join(directory.path, imageName);
    File addImage = await image.copy(newPathImage);

    setState(() {
      _image = addImage;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('salvo em: $newPathImage'))
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercice_01_ImagePicker'),
      ),
      body: Center(
        child: _image == null ?
        ElevatedButton(
            onPressed: () {
              _pickerImage();
            },
            child: Text('Capturar image'),
        ) : 
        Container(
          height: MediaQuery.of(context).size.height * 1/3,
          width: double.infinity,
          child: Image.file(_image!,
            fit: BoxFit.cover,
          ),
        ),
      )
    );
  }
}
