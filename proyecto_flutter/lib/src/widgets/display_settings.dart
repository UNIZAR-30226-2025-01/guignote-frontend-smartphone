import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_dialog.dart';

class DisplaySettings extends StatefulWidget 
{
  final double volume;
  final double musicVolume;
  final double effectsVolume;
  final Function(double) onVolumeChanged;
  final Function(double) onMusicVolumeChanged;
  final Function(double) onEffectsVolumeChanged;

  const DisplaySettings
  (
    {
      super.key,
      required this.volume,
      required this.musicVolume,
      required this.effectsVolume,
      required this.onVolumeChanged,
      required this.onMusicVolumeChanged,
      required this.onEffectsVolumeChanged,
    }
  );

  @override 
  DisplaySettingsState createState() => DisplaySettingsState();
}

class DisplaySettingsState extends State<DisplaySettings> 
{
  late double _currentVolume;
  late double _currentMusicVolume;
  late double _currentEffectsVolume;

  @override
  void initState() 
  {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async 
  {
    final prefs = await SharedPreferences.getInstance();
    setState(() 
    {
      _currentVolume = prefs.getDouble('volume') ?? widget.volume;
      _currentMusicVolume = prefs.getDouble('musicVolume') ?? widget.musicVolume;
      _currentEffectsVolume = prefs.getDouble('effectsVolume') ?? widget.effectsVolume;
    });
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
    return IconButton
    (
      icon: const Icon(Icons.settings, color: Colors.white),
      onPressed: () 
      {
        showDialog
        (
          context: context,
          builder: (BuildContext context) 
          {
            return SettingsDialog(
              volume: _currentVolume,
              musicVolume: _currentMusicVolume,
              effectsVolume: _currentEffectsVolume,
              onVolumeChanged: (double value) 
              {
                setState(() 
                {
                  _currentVolume = value;
                });
                _saveVolume(value);
                widget.onVolumeChanged(value);
              },
              
              onMusicVolumeChanged: (double value)
              {
                setState(() 
                {
                  _currentMusicVolume = value;
                });

                _saveMusicVolume(value);
                widget.onMusicVolumeChanged(value);
              },

              onEffectsVolumeChanged: (double value) 
              {
                setState(() {
                  _currentEffectsVolume = value;
                });

                _saveEffectsVolume(value);
                widget.onEffectsVolumeChanged(value);
              },
            );
          },
        );
      },
    );
  }
}