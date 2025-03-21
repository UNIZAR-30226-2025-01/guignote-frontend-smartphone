import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sota_caballo_rey/src/widgets/sound_settings.dart';


/// Clase que muestra un diálogo con los ajustes de la aplicación.
/// 
/// Parámetros:
/// - 'volume': Volumen actual.
/// - 'musicVolume': Volumen de la música actual.
/// - 'effectsVolume': Volumen de los efectos de sonido actual.
/// - 'onVolumeChanged': Función que se ejecuta cuando se cambia el volumen.
/// - 'onMusicVolumeChanged': Función que se ejecuta cuando se cambia el volumen de la música.
/// - 'onEffectsVolumeChanged': Función que se ejecuta cuando se cambia el volumen de los efectos de sonido.
/// 
/// 
/// Ejemplo de uso:
/// 
/// ```dart
/// SettingsDialog
/// (
///  volume: 0.5,
/// musicVolume: 0.5,
/// effectsVolume: 0.5,
/// onVolumeChanged: (double value) {},
/// onMusicVolumeChanged: (double value) {},
/// onEffectsVolumeChanged: (double value) {},
/// 
/// )
/// ```
///
class SettingsDialog extends StatefulWidget 
{
  final double volume; // Volumen actual.
  final double musicVolume; // Volumen de la música actual.
  final double effectsVolume; // Volumen de los efectos de sonido actual.
  final Function(double) onVolumeChanged; // Función que se ejecuta cuando se cambia el volumen.
  final Function(double) onMusicVolumeChanged; // Función que se ejecuta cuando se cambia el volumen de la música.
  final Function(double) onEffectsVolumeChanged; // Función que se ejecuta cuando se cambia el volumen de los efectos de sonido.

  /// Constructor que inicializa el widget con los valores proporcionados.
  /// 
  const SettingsDialog
  (
    {
      super.key, // Llave del widget.
      required this.volume, // Volumen actual.
      required this.musicVolume,  // Volumen de la música actual.
      required this.effectsVolume, // Volumen de los efectos de sonido actual.
      required this.onVolumeChanged, // Función que se ejecuta cuando se cambia el volumen.
      required this.onMusicVolumeChanged, // Función que se ejecuta cuando se cambia el volumen de la música.
      required this.onEffectsVolumeChanged,   // Función que se ejecuta cuando se cambia el volumen de los efectos de sonido.
    }
  );

  @override
  SettingsDialogState createState() => SettingsDialogState(); // Devuelve el estado del widget.
}

/// Clase que crea el estado del widget SettingsDialog.
///
/// Esta clase crea el estado del widget SettingsDialog y contiene la lógica del widget.
/// 
/// 
/// Ejemplo de uso:
/// 
/// ```dart
/// SettingsDialogState
/// (
/// volume: 0.5,
/// musicVolume: 0.5,
/// effectsVolume: 0.5,
/// onVolumeChanged: (double value) {},
/// onMusicVolumeChanged: (double value) {},
/// onEffectsVolumeChanged: (double value) {},
///
/// )
/// ```
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
                    return SoundSettingsDialog
                    (
                      volume: widget.volume,
                      musicVolume: widget.musicVolume,
                      effectsVolume: widget.effectsVolume,
                      onVolumeChanged: widget.onVolumeChanged,
                      onMusicVolumeChanged: widget.onMusicVolumeChanged,
                      onEffectsVolumeChanged: widget.onEffectsVolumeChanged,
                    );
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
                onChanged: (bool value) 
                {
                  setState(() 
                  {
                    _notifications = value;
                  });
                  
                  _saveNotifications(value);
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