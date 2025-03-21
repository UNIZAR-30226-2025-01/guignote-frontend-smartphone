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
import 'package:audioplayers/audioplayers.dart';

void main() async {
  // Necesario para las operaciones asíncronas.
  WidgetsFlutterBinding.ensureInitialized();
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
  final AudioPlayer _audioController = AudioPlayer();

  @override
  void initState() 
  {
    super.initState();

    _audioController.setReleaseMode(ReleaseMode.stop);

    WidgetsBinding.instance.addPostFrameCallback((_) async 
    {
      await _audioController.setSource(AssetSource('sounds/menu_jazz_lofi.mp3'));
      await _audioController.resume();
    });


  }

  @override
  void dispose() 
  {
    _audioController.dispose();
    super.dispose();
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
