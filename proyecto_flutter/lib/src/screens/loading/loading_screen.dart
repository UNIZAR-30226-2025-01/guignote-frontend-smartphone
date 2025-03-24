import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

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
            _controller.play();

            _controller.addListener(() {
              if (_controller.value.isInitialized &&
                  !_controller.value.isPlaying &&
                  _controller.value.position >= _controller.value.duration) {
                Navigator.pushReplacementNamed(context, '/welcome');
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
    _controller.dispose();
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
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
