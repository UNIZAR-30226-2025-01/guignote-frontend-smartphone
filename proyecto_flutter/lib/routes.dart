import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/screens/friends/friends_screen.dart';
import 'package:sota_caballo_rey/src/screens/game/list_games_screen.dart';
import 'package:sota_caballo_rey/src/screens/home/help_screen.dart';
import 'package:sota_caballo_rey/src/screens/user/profile_screen.dart';
import 'src/screens/auth/welcome_screen.dart';
import 'src/screens/auth/login_screen.dart';
import 'src/screens/auth/register_screen.dart';
import 'package:sota_caballo_rey/src/screens/home/home_screen.dart';
import 'src/screens/game/game_screen.dart';
import 'package:sota_caballo_rey/src/screens/home/ranking_screen.dart';
import 'package:sota_caballo_rey/src/screens/loading/loading_screen.dart';
import 'package:sota_caballo_rey/src/screens/settings/security_screen.dart';
import 'package:sota_caballo_rey/src/screens/settings/change_password_screen.dart';
import 'package:sota_caballo_rey/src/screens/settings/data_policy_screen.dart';
import 'package:sota_caballo_rey/src/screens/settings/privacity_screen.dart';
import 'package:sota_caballo_rey/src/screens/auth/password_recover_screen.dart';


/// Clase que define las rutas de la aplicación.
/// Contine las constantes de las rutas y un diccionario que asocia cada ruta a su respectiva pantalla.
/// 
/// Cada ruta es una cadena que representa la ruta de la pantalla en la aplicación.
/// Las pantallas son widgets que se muestran al navegar a la ruta correspondiente.
/// 
class AppRoutes
{
  static const String loading = '/loading'; // Pantalla de carga
  static const String welcome = '/welcome'; // Pantalla de bienvenida
  static const String login = '/login'; // Pantalla de inicio de sesión
  static const String passwordRecover = '/passwordRecover'; // Pantalla de recuperación de contraseña
  static const String register = '/register'; // Pantalla de registro
  static const String game = '/game'; // Pantalla de juego
  static const String amigos = '/amigos'; // Pantalla de amigos
  static const String profile = '/profile'; // Pantalla de perfil
  static const String home = '/home'; // Pantalla de inicio
  static const String help = '/help'; // Pantalla de ayuda
  static const String ranking = '/ranking'; // Pantalla de clasificación
  static const String security = '/security'; // Pantalla de seguridad
  static const String changePassword = '/changePassword'; // Pantalla de cambio de contraseña
  static const String dataPolicy = '/dataPolicy'; // Pantalla de política de datos
  static const String privacity = '/privacity'; // Pantalla de privacidad
  static const String listGames = '/listGames'; // Pantalla de lista de juegos


  /// Diccionario que asocia cada ruta a su respectiva pantalla.
  /// Cada entrada del diccionario es una clave-valor donde la clave es la ruta y el valor es un constructor de widget.
  static Map<String, WidgetBuilder> routes =
  {
    loading: (context) => const LoadingScreen(), // Pantalla de carga
    welcome: (context) => const WelcomeScreen(), // Pantalla de bienvenida
    login: (context) => const LoginScreen(), // Pantalla de inicio de sesión
    passwordRecover: (context) => const PasswordRecoverScreen(), // Pantalla de recuperación de contraseña
    register: (context) => const RegisterScreen(), // Pantalla de registro
    game: (context) => const GameScreen(), // Pantalla de juego
    amigos: (context) => const FriendsScreen(), // Pantalla de amigos
    profile: (context) => const ProfileScreen(), // Pantalla de perfil
    home: (context) => const HomeScreen(), // Pantalla de inicio
    help: (context) => const HelpScreen(), // Pantalla de ayuda
    ranking: (context) => const RankingScreen(), // Pantalla de clasificación
    security: (context) => const SecurityScreen(), // Pantalla de seguridad
    changePassword: (context) => const ChangePasswordScreen(), // Pantalla de cambio de contraseña
    dataPolicy: (context) => const DataPolicyScreen(), // Pantalla de política de datos
    privacity: (context) => const PrivacityScreen(), // Pantalla de privacidad
    listGames: (context) => const ListGamesScreen(), // Pantalla de lista de juegos
  };
}


