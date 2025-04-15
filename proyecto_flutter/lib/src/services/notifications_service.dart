import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsService
{
  /// Instancia del servicio de notificaciones
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
    
  /// Inicializa el servicio de notificaciones
  
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_logo_white');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Pide permiso si es necesario
    await requestNotificationPermissionIfNeeded();
  }

  /// Pide permiso para mostrar notificaciones si es necesario en Android 13 o superior
  requestNotificationPermissionIfNeeded() async
  {
    if (Platform.isAndroid)
    {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      final isGranted = await androidImplementation?.areNotificationsEnabled();

      if (isGranted != true)
      {
        await androidImplementation?.requestNotificationsPermission();
      }
    }

  }

  /// Activa o desactiva las notificaciones
  Future<void> setNotificationsEnabled(bool enabled) async
  {
    if(enabled)
    {
      /// Activa las notificaciones
      const AndroidNotificationChannel channel = AndroidNotificationChannel
      (
        'channel_id',
        'channel_name',
        description: 'channel_description',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>() ?.createNotificationChannel(channel);
    }
    else
    {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  /// Método para mostrar una notificación.
  Future<void> showNotification(String title, String body) async
  {

    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications') ?? true;

    if (!notificationsEnabled) return; // Si las notificaciones están desactivadas, no se muestra la notificación.

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

}