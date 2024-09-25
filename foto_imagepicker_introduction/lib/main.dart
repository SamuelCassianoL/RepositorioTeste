import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageCaptureScreen(),
    );
  }
}

class ImageCaptureScreen extends StatefulWidget {
  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File? _image;

  // Instânciando ImagePicker para ultilizar seus métodos
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // variável final,
    // do tipo XFile?, nesse caso uma classe de image_picker que representa um arquivo capturado, da câmera ou galeria
    // por meio do método pickImage será capturado a image
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      // Salva a imagem em um diretório público acessível
      await _saveImage(File(pickedImage.path));
    }
  }

  // Função para salvar o arquivo capturado, com um argumento do tipo File "image"
  Future<void> _saveImage(File image) async {
    // variável  directory do tipo Directory?, sendo o construtor Directory('/storage/emulated/0/Pictures')
    //  Dessa forma, directory contém o caminho específico do armazenamento
    Directory? directory = Directory('/storage/emulated/0/Pictures');

    // !: indica o oposto do boleano
    // se não existir o caminho do diretório, o mesmo é criado
    if (!await directory.exists()) {
      // o método create irá criar todos os diretórios se necessário
      directory.create(recursive: true);
    }

    // path.basename: irá retornar apenas o nome do arquivo
    String imageName = path.basename(image.path);
    // processo de adição da imagem para o diretório:
    // directory.path + imageName = /storage/emulated/0/Pictures/nomeDaImage
    String newPath = path.join(directory.path, imageName);
    // A linha a baixo irá copiar o argumento image, para "newPath"
    File newImage = await image.copy(newPath);

    setState(() {
      _image = newImage;
    });

    print('Imagem salva em: ${newImage.path}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imagem salva em: ${newImage.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capturar e Salvar Imagem'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? Image.file(_image!)
                : Text('Nenhuma imagem capturada.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Capturar Imagem'),
            ),
          ],
        ),
      ),
    );
  }
}
