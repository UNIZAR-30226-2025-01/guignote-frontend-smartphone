import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';

class DisplaySettings extends StatefulWidget 
{

  final double volume;
  final Function(double) onVolumeChanged;

  const DisplaySettings
  (
    {
      super.key,
      required this.volume,
      required this.onVolumeChanged
    }
  );

  @override 
  DisplaySettingsState createState() => DisplaySettingsState();
}

class DisplaySettingsState extends State<DisplaySettings>
{

  late double _currentVolume;

  @override
  void initState() 
  {
    super.initState();
    _currentVolume = widget.volume;
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
            return SettingsDialog
            (
              volume: _currentVolume,
              onVolumeChanged: (double value)
              {
                setState(() 
                {
                  _currentVolume = value;
                });
                widget.onVolumeChanged(value);
              },
            );
          },
        );
      },
    );
  }            
}

class SettingsDialog extends StatelessWidget
{
  final double volume;
  final Function(double) onVolumeChanged;

  const SettingsDialog
  (
    {
      super.key,
      required this.volume,
      required this.onVolumeChanged
    }
  );

  @override
  Widget build(BuildContext context)
  {
    return AlertDialog
    (
      backgroundColor: AppTheme.blackColor,
      content: SizedBox
      (
        height: 400,
        child:Column
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
              title: const Text('Ajustes de sonido', style: TextStyle(color: Colors.white)),
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
                      volume: volume,
                      onVolumeChanged: onVolumeChanged,
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
                //TODO IMPLEMENTAR NAVEGACIÓN A LA INFORMACIÓN DE LA CUENTA
              },
            ),

            ListTile
            (
              leading: const Icon(Icons.notifications, color: Colors.white),
              title: const Text('Notificaciones', style: TextStyle(color: Colors.white)),
              trailing: Switch
              (
                value: true,
                onChanged: (bool value) 
                {
                  //TODO IMPLEMENTAR CAMBIO DE NOTIFICACIONES
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
                //TODO IMPLEMENTAR NAVEGACIÓN A SEGURIDAD Y PRIVACIDAD
              },
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

class SoundSettingsDialog extends StatelessWidget
{
  final double volume;
  final Function(double) onVolumeChanged;

  const SoundSettingsDialog
  (
    {
      super.key,
      required this.volume,
      required this.onVolumeChanged
    }
  );

  @override
  Widget build(BuildContext context)
  {
    return AlertDialog
    (
      backgroundColor: AppTheme.blackColor,
      content: SizedBox
      (
        height: 200,
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
            const Text('Ajustes de sonido', style: TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 20),
            
            const Text('Volumen', style: TextStyle(color: Colors.white, fontSize: 18)),

            Slider
            (
              value: volume,
              onChanged: onVolumeChanged,
              min: 0,
              max: 1,
              divisions: 10,
              label: volume.toStringAsFixed(1),
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

