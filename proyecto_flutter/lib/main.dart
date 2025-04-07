/// Proyecto: Sota, Caballo y Rey
/// Autores: Grupo Grace Hopper
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
import 'package:sota_caballo_rey/src/screens/settings/account_info_screen.dart';
import 'package:sota_caballo_rey/src/services/audio_service.dart';
import 'package:sota_caballo_rey/src/services/notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Necesario para las operaciones asíncronas.
  WidgetsFlutterBinding.ensureInitialized();
  await AudioService().init();
  await NotificationsService().init(); // Inicializa el servicio de notificaciones.
  await Config.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget 
{
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp>
{
  @override
  void initState() 
  {
    super.initState();

   
    WidgetsBinding.instance.addPostFrameCallback((_) async 
    {
      await AudioService().playMenuMusic(); // Música de fondo del menú.
      final prefs = await SharedPreferences.getInstance(); // Obtiene las preferencias compartidas.
      final notificationsEnabled = prefs.getBool('notifications') ?? true; // Obtiene las notificaciones.
      await NotificationsService().setNotificationsEnabled(notificationsEnabled); // Activa o desactiva las notificaciones.
    });

  }

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
        '/game': (context) => const GameScreen(partidaID: 1,),
        '/amigos': (context) => const FriendsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomeScreen(),
        '/help': (context) => const HelpScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/account_info': (context) => const AccountInfoScreen(),
        'security': (context) => const AccountInfoScreen(),
      },
    );
  }
}
