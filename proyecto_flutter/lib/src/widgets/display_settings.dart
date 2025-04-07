import 'package:flutter/material.dart';
import 'settings_dialog.dart';

class DisplaySettings extends StatefulWidget 
{
  final Function(double) onVolumeChanged;
  final Function(double) onMusicVolumeChanged;
  final Function(double) onEffectsVolumeChanged;

  const DisplaySettings
  (
    {
      super.key,
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


  @override
  void initState() 
  {
    super.initState();
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
            return const SettingsDialog();

          },
        );
      },
    );
  }
}