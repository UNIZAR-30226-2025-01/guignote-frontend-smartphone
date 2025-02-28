import 'package:flutter/material.dart';
import 'package:prototipos_v2/screens/game_1vs1_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guiñote App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Puedes cambiarlo luego
      ),
      initialRoute: '/game1vs1',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/game1vs1': (context) => const Game1vs1Screen(),
      },
    );
  }
}
