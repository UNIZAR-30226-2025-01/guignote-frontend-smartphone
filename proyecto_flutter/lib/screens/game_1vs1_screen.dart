import 'package:flutter/material.dart';

class Game1vs1Screen extends StatefulWidget {
  const Game1vs1Screen({super.key});

  @override
  Game1vs1ScreenState createState() => Game1vs1ScreenState();
}

class Game1vs1ScreenState extends State<Game1vs1Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Opacity(
          opacity: 0.5, // 50% de transparencia
          child: Image.asset(
            'assets/logo2.png', // Ruta de la imagen
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
