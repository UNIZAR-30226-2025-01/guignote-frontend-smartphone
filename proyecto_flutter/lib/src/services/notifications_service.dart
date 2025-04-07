import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService
{
  /// Instancia del servicio de notificaciones
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
    
  /// Inicializa el servicio de notificaciones
  
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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