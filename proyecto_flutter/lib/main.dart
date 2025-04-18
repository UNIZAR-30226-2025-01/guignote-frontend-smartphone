/// Proyecto: Sota, Caballo y Rey
/// Autores: Grupo Grace Hopper
///
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/config.dart';
import 'package:sota_caballo_rey/src/services/audio_service.dart';
import 'package:sota_caballo_rey/src/services/notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sota_caballo_rey/routes.dart';
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
      theme: ThemeData(colorScheme: ColorScheme.dark()),
      initialRoute: AppRoutes.loading,
      routes: AppRoutes.routes,
    );
  }
}
