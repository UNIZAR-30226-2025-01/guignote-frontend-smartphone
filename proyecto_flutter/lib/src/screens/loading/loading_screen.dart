import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sota_caballo_rey/routes.dart';
import 'package:sota_caballo_rey/tests_config.dart' as tests_config;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    // Verificamos si estamos en modo de prueba.
    if (tests_config.isTestEnvironment) {
      // Si estamos en modo de prueba, redirigimos a la pantalla de bienvenida inmediatamente.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      });
      return;
    }    

    // Cargamos el video desde assets.
    _controller = VideoPlayerController.asset(
        'assets/images/Sota_Caballo_y_Rey_Mobile_Video.mp4',
      )
      ..initialize()
          .then((_) {
            setState(() {
              _isVideoInitialized = true;
            });

            // Inicia la reproducción.
            _controller!.play();
            
            debugPrint("Video inicializado: ${_controller!.value.isInitialized}");
            debugPrint("Video en reproducción: ${_controller!.value.isPlaying}");

            // Fallback, si el video no termina en 5 segundos, redirige a la pantalla de bienvenida.
            Timer(const Duration(seconds: 5), () {
              if (_controller!.value.isInitialized &&
                  !_controller!.value.isPlaying) {
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              }
            });

            _controller!.addListener(() {
              if (_controller!.value.isInitialized &&
                  !_controller!.value.isPlaying &&
                  _controller!.value.position >= _controller!.value.duration) {
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              }
            });
          })
          .catchError((error) {
            debugPrint('Error al inicializar el video: $error');
          });
  }

  @override
  void dispose() {
    // Liberamos el controlador cuando termina.
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Muestra gif.
        child:
            _isVideoInitialized
                ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
