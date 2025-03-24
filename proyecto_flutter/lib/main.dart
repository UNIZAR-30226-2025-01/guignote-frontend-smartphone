/// Proyecto: Sota, Caballo y Rey
/// Autores: Grupo Grace Hopper
/// Fecha de última modificación: 06/03/2025.
///
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/screens/friends/friends_screen.dart';
import 'package:sota_caballo_rey/src/screens/home/help_screen.dart';
import 'package:sota_caballo_rey/src/screens/user/profile_screen.dart';
import 'src/screens/auth/welcome_screen.dart';
import 'src/screens/auth/login_screen.dart';
import 'src/screens/auth/register_screen.dart';
import 'package:sota_caballo_rey/config.dart';
import 'package:sota_caballo_rey/src/screens/home/home_screen.dart';
import 'src/screens/game/game_screen.dart';
import 'package:sota_caballo_rey/src/screens/home/ranking_screen.dart';
import 'package:sota_caballo_rey/src/screens/loading/loading_screen.dart';

void main() async {
  // Necesario para las operaciones asíncronas.
  WidgetsFlutterBinding.ensureInitialized();
  await Config.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: !kReleaseMode,
      title: 'Sota, Caballo Y Rey',
      theme: ThemeData(colorScheme: ColorScheme.dark()),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => const LoadingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/game': (context) => const GameScreen(partidaID: 1),
        '/amigos': (context) => const FriendsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomeScreen(),
        '/help': (context) => const HelpScreen(),
        '/ranking': (context) => const RankingScreen(),
      },
    );
  }
}
