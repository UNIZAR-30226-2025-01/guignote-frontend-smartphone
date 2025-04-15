import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sota_caballo_rey/src/widgets/sound_settings.dart';
import 'package:sota_caballo_rey/src/services/notifications_service.dart';


/// Clase que muestra un diálogo con los ajustes de la aplicación.
/// 
/// Esta clase permite al usuario ajustar el volumen de la música y los efectos de sonido,
/// así como acceder a la información de la cuenta y a la configuración de seguridad y privacidad.
/// 
class SettingsDialog extends StatefulWidget 
{

  const SettingsDialog({super.key});

  @override
  SettingsDialogState createState() => SettingsDialogState(); // Devuelve el estado del widget.
}

/// Clase que crea el estado del widget SettingsDialog.
///
/// Esta clase crea el estado del widget SettingsDialog y contiene la lógica del widget.
/// 
class SettingsDialogState extends State<SettingsDialog> 
{
  bool _notifications = true; // Notificaciones.

  /// Inicializa el estado del widget.
  ///
  /// Este método inicializa el estado del widget y carga los ajustes de las notificaciones.
  /// 
  @override
  void initState() 
  {
    super.initState(); // Inicializa el estado del widget.
    _loadSettings(); // Carga los ajustes.
  }

  /// Carga los ajustes de las notificaciones.
  /// 
  /// 
  /// Ejemplo de uso:
  /// 
  /// ```dart
  /// _loadSettings();
  /// ```
  ///  
  Future<void> _loadSettings() async 
  {
    // Obtiene las preferencias compartidas.
    final prefs = await SharedPreferences.getInstance(); 
    setState(() 
    {
      // Obtiene las notificaciones.
      _notifications = prefs.getBool('notifications') ?? true;
    });
  }

  /// Guarda las notificaciones.
  ///
  /// Parámetros:
  /// - 'value': Valor de las notificaciones.
  /// 
  /// 
  /// Ejemplo de uso:
  /// 
  /// ```dart
  /// _saveNotifications(value);
  /// ```
  /// 
  Future<void> _saveNotifications(bool value) async 
  {
    // Obtiene las preferencias compartidas.
    final prefs = await SharedPreferences.getInstance();
    // Guarda las notificaciones.
    await prefs.setBool('notifications', value);

    await NotificationsService().setNotificationsEnabled(value);
  }

  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog
    (
      backgroundColor: AppTheme.blackColor,
      content: SizedBox
      (
        height: 500,
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
            const Text
            (
              'Ajustes',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 20),
            ListTile
            (
              leading: const Icon(Icons.volume_up, color: Colors.white),
              title: const Text('Ajustes de volumen', style: TextStyle(color: Colors.white)),
              onTap: () 
              {
                Navigator.of(context).pop();
                showDialog
                (
                  context: context,
                  builder: (BuildContext context) 
                  {
                    return const SoundSettingsDialog();
                  },
                );
              },
            ),
            ListTile
            (
              leading: const Icon(Icons.account_circle, color: Colors.white),
              title: const Text('Información de la cuenta', style: TextStyle(color: Colors.white)),
              onTap: () 
              {
                Navigator.pushNamed(context, '/account_info');
              },
            ),
            ListTile
            (
              leading: const Icon(Icons.notifications, color: Colors.white),
              title: const Text('Notificaciones', style: TextStyle(color: Colors.white)),
              
              trailing: Switch
              (
                value: _notifications,
                onChanged: (bool value) async 
                {
                  setState(() 
                  {
                    _notifications = value;
                  });

                  // Activa o desactiva las notificaciones.
                  await NotificationsService().setNotificationsEnabled(value);
                  
                  await _saveNotifications(value);

                },

                activeColor: Colors.amber,
                inactiveThumbColor: Colors.grey,
              ),
            ),
            ListTile
            (
              leading: const Icon(Icons.security, color: Colors.white),
              title: const Text('Seguridad y privacidad', style: TextStyle(color: Colors.white)),
              onTap: () 
              {
                Navigator.pushNamed(context, '/security');
              },
            ),
            const SizedBox(height: 20),
            
            ElevatedButton
            (
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () 
              {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar', style: TextStyle(color: AppTheme.blackColor)),
            ),
          ],
        ),
      ),
    );
  }
}