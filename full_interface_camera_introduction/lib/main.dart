import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';



void main() async {
  // O método abaixo é responsável por garantir que o código nativo do dispositivo e o flutter esteja configurada
  // Evitando erros em operações complexas
  WidgetsFlutterBinding.ensureInitialized();
  // na variável camera, será aramazenado todas as câmeras disponíveis atravéz do método avaliabeCameras
  final cameras = await availableCameras();
  // a lisat de câmeras é passda para a classe myaap, é um parâmetro obrigatório
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  // a lista de câmeras, recebendo o parâmetro obrigatório da classe
  final List<CameraDescription> cameras;
  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Câmera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraApp(cameras: cameras),
    );
  }
}

class CameraApp extends StatefulWidget {
  // A lista anterior é repassada como argumento mais uma vez par a classe CameraApp
  final List<CameraDescription> cameras;
  const CameraApp({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  // a variável controller armazena o método responsável por todos os controllers da câmera
  CameraController? controller;
  // variável de status para a câmera usada
  bool isFrontCamera = false;
  // variável do tipo FlashMOde, um enum nativo de camera, nesse caso está armazenando o status de desligado
  FlashMode currentFlashMode = FlashMode.off;
  // Definição do zoom padrão, 1.0 indica que não há zoom
  double currentZoomLevel = 1.0;
  // Na linha abaixo é armazenado o caminho que o vídeo ou a foto final irá conter
  String? mediaPath;
  // variável de status para a gravação
  bool isRecording = false;
  // varível que inicia o padrão dos pontos de focos da gravação, em um plano x = 0.5 e y = 0.5, o canto superior esquerdo
  Offset focusPoint = Offset(0.5, 0.5);

  // O initState abaixo inicia a função init Camera, de forma que ao abrir o app, a função seja executada
  @override
  void initState() {
    super.initState();
    // o argumento passado para função queinicia a camera é set da câmera traseira
    initCamera(widget.cameras[0]);
  }

  // Função responsável por inincializar a câmera
  Future<void> initCamera(CameraDescription chooseCamera) async {
    // é criado o controller, um Objeto do tipo CameraController, que controlla as principais funções da câmera
    controller = CameraController(chooseCamera, ResolutionPreset.high,);
    try {
      //nesse trecho é ultilizado método initilizer, que inicializa o controller e seus respectivos métodos
      await controller?.initialize();
      // nesse trecho é feito um set state após o initializer
      setState(() {});
      print('Câmera inicializada com sucesso');
    } catch (e) {
      print('Erro ao inicializar a câmera: $e');
    }
  }

  // A função abaixo faz a troca das câmeras
  void switchCamera() async {
    try {
    //   Esse if pai, faz um averificação se o dispositivo possue mais de uma câmera para a troca
    //   pois no emulador só é possível acessa uma câmera, desse modo, evita futuros erros
    if (widget.cameras.length > 1){
      CameraDescription frontCamera = widget.cameras[1];
      CameraDescription backCamera = widget.cameras[0];

      // se a variável IsfronCamera for verdaderia
      // a função de inicio é reinicializada, porém com o parâmetro de câmera diferente
      if (isFrontCamera){
        initCamera(backCamera);
        setState(() {
          isFrontCamera = false;
        });
      } else{
        initCamera(frontCamera);
        setState(() {
          isFrontCamera = true;
        });
      }
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Atenção: troca de câmeras disponível para dispositivo físico.'),
            duration: Durations.extralong4,
          )
      );
    }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro desconhecido: $e'),
          duration: Durations.extralong4,
        )
      );
    }
  }


  // Controle do flash
  void toggleFlashMode() {
    setState(() {
      // a linha abaixo altera o estado flash por meio do if ternário

    },
    );
  }

  void zoomCamera(double value) {
    setState(() {
      currentZoomLevel = value;
      controller?.setZoomLevel(currentZoomLevel);
      print('Zoom alterado para: $currentZoomLevel');
    });
  }

  Future<void> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      print('Controller não inicializado');
      return;
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final XFile file = await controller!.takePicture();
      await file.saveTo(filePath);
      setState(() {
        mediaPath = filePath;
      });
      print('Foto salva em: $filePath');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GalleryPage(mediaPath: filePath)),
      );
    } catch (e) {
      print('Erro ao tirar a foto: $e');
    }
  }

  Future<void> startVideoRecording() async {
    if (controller == null || !controller!.value.isInitialized) {
      print('Controller não inicializado');
      return;
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await controller!.startVideoRecording();
      setState(() {
        isRecording = true;
      });
      print('Gravação de vídeo iniciada');
    } catch (e) {
      print('Erro ao iniciar gravação de vídeo: $e');
    }
  }

  Future<void> stopVideoRecording() async {
    if (controller == null || !controller!.value.isInitialized || !isRecording) {
      print('Gravação não iniciada ou controller não inicializado');
      return;
    }
    try {
      final file = await controller!.stopVideoRecording();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await file.saveTo(filePath);
      setState(() {
        mediaPath = filePath;
        isRecording = false;
      });
      print('Gravação de vídeo salva em: $filePath');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GalleryPage(mediaPath: filePath)),
      );
    } catch (e) {
      print('Erro ao parar gravação de vídeo: $e');
    }
  }

  void onTapFocusPoint(TapDownDetails details) {
    final offset = details.localPosition;
    setState(() {
      focusPoint = offset;
    });
    if (controller != null && controller!.value.isInitialized) {
      controller!.setFocusPoint(
        Offset(
          (focusPoint.dx / MediaQuery.of(context).size.width).clamp(0.0, 1.0),
          (focusPoint.dy / MediaQuery.of(context).size.height).clamp(0.0, 1.0),
        ),
      );
      print('Ponto de foco ajustado: $focusPoint');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    double maxZoomLevel = 5.0; // Valor fixo para demonstração, ajuste conforme necessário

    return Scaffold(
      appBar: AppBar(
        title: const Text('App de Câmera'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () {
              print('Botão da galeria clicado');
              if (mediaPath != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GalleryPage(mediaPath: mediaPath)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Nenhuma foto ou vídeo para mostrar')),
                );
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTapDown: onTapFocusPoint,
        child: Stack(
          children: [
            CameraPreview(controller!),
            Positioned(
              left: focusPoint.dx - 30,
              top: focusPoint.dy - 30,
              child: Icon(
                Icons.circle_outlined, // Mudado para um ícone disponível
                color: Colors.red,
                size: 60,
              ),
            ),
            Positioned(
              bottom: 80,
              left: 10,
              right: 10,
              child: Slider(
                value: currentZoomLevel,
                min: 1.0,
                max: maxZoomLevel,
                onChanged: (value) {
                  zoomCamera(value);
                },
                divisions: (maxZoomLevel - 1).toInt(),
                label: '${currentZoomLevel.toStringAsFixed(1)}x',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(isFrontCamera ? Icons.camera_front : Icons.camera_rear),
              onPressed: () {
                print('Botão de troca de câmera clicado');
                switchCamera();
              },
            ),
            IconButton(
              icon: Icon(currentFlashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on),
              onPressed: () {
                print('Botão de flash clicado');
                toggleFlashMode();
              },
            ),
            IconButton(
              icon: Icon(isRecording ? Icons.stop : Icons.videocam),
              onPressed: () {
                if (isRecording) {
                  print('Botão de parar gravação clicado');
                  stopVideoRecording();
                } else {
                  print('Botão de iniciar gravação clicado');
                  startVideoRecording();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: () {
                print('Botão de captura de foto clicado');
                takePicture();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryPage extends StatelessWidget {
  final String? mediaPath;
  const GalleryPage({Key? key, this.mediaPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeria')),
      body: Center(
        child: mediaPath != null
            ? (mediaPath!.endsWith('.jpg')
            ? Image.file(File(mediaPath!))
            : VideoPlayerScreen(mediaPath: mediaPath!))
            : const Text('Nenhuma imagem ou vídeo para exibir'),
      ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final String mediaPath;
  const VideoPlayerScreen({Key? key, required this.mediaPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reprodução de Vídeo')),
      body: Center(
        child: VideoPlayerWidget(mediaPath: mediaPath),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String mediaPath;
  const VideoPlayerWidget({Key? key, required this.mediaPath}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.mediaPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final rotationAngle = pi / 2; // Rotaciona o vídeo em 90 graus no sentido anti-horário

    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Transform.rotate(
        angle: rotationAngle,
        child: FittedBox(
          fit: BoxFit.cover, // Ajusta o vídeo para preencher a área disponível
          child: SizedBox(
            width: screenSize.height,
            height: screenSize.width,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
