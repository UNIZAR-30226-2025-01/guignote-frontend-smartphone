import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/services/audio_service.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';


/// Diálogo para los ajustes de sonido.
/// 
/// Se puede ajustar el volumen general, el volumen de la música y el volumen de los efectos.
/// 
/// Se guardan los ajustes en las preferencias del dispositivo.
/// 
class SoundSettingsDialog extends StatefulWidget
{

  const SoundSettingsDialog({super.key});

  /// Crea el estado del diálogo.
  /// 
  /// Devuelve [SoundSettingsDialogState].
  /// 
  /// Se ejecuta al crear el widget.
  /// 
  @override
  SoundSettingsDialogState createState() => SoundSettingsDialogState();
}

class SoundSettingsDialogState extends State<SoundSettingsDialog>
{
  late double _currentVolume;
  late double _currentMusicVolume;
  late double _currentEffectsVolume;

  final audio = AudioService(); // Instancia del servicio de audio.

  @override
  void initState() 
  {
    super.initState();
    _currentVolume = audio.generalVolume;
    _currentEffectsVolume = audio.effectsVolume;
    _currentMusicVolume = audio.musicVolume;
  }

  @override
  Widget build(BuildContext context)
  {
    return AlertDialog
    (
      backgroundColor: AppTheme.blackColor,
      content: SizedBox
      (
        height: 400,
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
            const Text('Ajustes de sonido', style: TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 20),
            
            const Text('Volumen General', style: TextStyle(color: Colors.white, fontSize: 18)),

            Slider
            (
              value: _currentVolume,
              onChanged: (double value) 
              {
                setState(() 
                {
                  _currentVolume = value;
                });
                audio.setGeneralVolume(value);
              },
              min: 0,
              max: 1,
              divisions: 10,
              activeColor: Colors.amber,
              inactiveColor: Colors.white,
            ),

            const Text('Volumen de Música', style: TextStyle(color: Colors.white, fontSize: 18)),
            Slider
            (
              value: _currentMusicVolume,
              onChanged: (double value) 
              {
                setState(() 
                {
                  _currentMusicVolume = value;
                });
                audio.setMusicVolume(value);
              },
              min: 0,
              max: 1,
              divisions: 10,
              activeColor: Colors.amber,
              inactiveColor: Colors.white,
            ),

            const Text('Volumen de Efectos', style: TextStyle(color: Colors.white, fontSize: 18)),
            Slider
            (
              value: _currentEffectsVolume,
              onChanged: (double value) 
              {
                setState(() 
                {
                  _currentEffectsVolume = value;
                });

                audio.setEffectsVolume(value);
              },
              min: 0,
              max: 1,
              divisions: 10,
              activeColor: Colors.amber,
              inactiveColor: Colors.white,
            ),

            const SizedBox(height: 20),
            ElevatedButton
            (
              style: ElevatedButton.styleFrom(backgroundColor:  Colors.amber),
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