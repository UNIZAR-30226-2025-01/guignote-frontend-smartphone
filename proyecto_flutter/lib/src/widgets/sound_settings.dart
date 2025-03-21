
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:audioplayers/audioplayers.dart';

class SoundSettingsDialog extends StatefulWidget
{
  final double volume;
  final double musicVolume;
  final double effectsVolume;
  final Function(double) onVolumeChanged;
  final Function(double) onMusicVolumeChanged;
  final Function(double) onEffectsVolumeChanged;
  
  
  const SoundSettingsDialog
  (
    {
      super.key,
      required this.volume,
      required this.onVolumeChanged,
      required this.musicVolume,
      required this.onMusicVolumeChanged,
      required this.effectsVolume,
      required this.onEffectsVolumeChanged,
    }
  );

  @override
  SoundSettingsDialogState createState() => SoundSettingsDialogState();
}

class SoundSettingsDialogState extends State<SoundSettingsDialog>
{
  late double _currentVolume;
  late double _currentMusicVolume;
  late double _currentEffectsVolume;

  @override
  void initState() 
  {
    super.initState();
    _currentVolume = widget.volume;
    _currentEffectsVolume = widget.effectsVolume;
    _currentMusicVolume = widget.musicVolume;
  }

  Future<void> _saveVolume(double value) async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', value);
  }

  Future<void> _saveMusicVolume(double value) async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', value);
  }

  Future<void> _saveEffectsVolume(double value) async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('effectsVolume', value);
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
                widget.onVolumeChanged(value);
                _saveVolume(value);
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
                widget.onMusicVolumeChanged(value);
                _saveMusicVolume(value);
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
                widget.onEffectsVolumeChanged(value);
                _saveEffectsVolume(value);
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