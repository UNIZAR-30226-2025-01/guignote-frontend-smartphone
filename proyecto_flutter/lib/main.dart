/// Proyecto: Sota, Caballo y Rey
/// Autores: Grupo Grace Hopper
/// Fecha de última modificación: 06/03/2025.
/// 
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/screens/auth/friends_screen.dart';
import 'package:sota_caballo_rey/src/screens/auth/profile_screen.dart';
import 'src/screens/auth/welcome_screen.dart';
import 'src/screens/auth/login_screen.dart';
import 'src/screens/auth/register_screen.dart';
import 'package:sota_caballo_rey/config.dart';

void main() async {
  // Necesario para las operaciones asíncronas.
  WidgetsFlutterBinding.ensureInitialized();
  await Config.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      debugShowCheckedModeBanner: !kReleaseMode,
      title: 'Sota, Caballo Y Rey',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(), 
      ),
      initialRoute: '/',
      routes: 
      {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/amigos': (context) => const FriendsScreen(),
        '/profile' : (context) => const ProfileScreen(),
      },
    );
  }
}
