import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/src/widgets/sound_settings.dart';


/// Clase que muestra un diálogo con los ajustes de la partida.
/// 
/// Esta clase permite al usuario ajustar el volumen de la música y los efectos de sonido,
/// así como salir de la partida.
class GameSettings extends StatefulWidget
{
  // Callback para salir de la partida.
  final VoidCallback exitGameCallback;

  // Callback para pausar la partida.
  final VoidCallback pauseGameCallback;

  // Callback para anular la pausa.
  final VoidCallback resumeGameCallback;

  // Indica si se ha solicitado una pausa.
  final bool pausaSolicitada;

  const GameSettings
  (
    {
      super.key,
      required this.exitGameCallback,
      required this.pauseGameCallback,
      required this.resumeGameCallback,
      required this.pausaSolicitada,
    }
  );

  @override
  State<GameSettings> createState() => _GameSettingsState();
}

class _GameSettingsState extends State<GameSettings>
{

  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    // Se devuelve un diálogo con los ajustes de la partida.
    return AlertDialog
    (
      backgroundColor: AppTheme.blackColor,
      content: SizedBox
      (
        height: 320,
        width: 200,
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
            const Text('Ajustes de la partida', style: AppTheme.dialogTitleStyle),
            const SizedBox(height: 20),

            // Opción para ajustar el volumen de la música y los efectos de sonido.
            // Al pulsar esta opción se abre el diálogo de ajustes de sonido.
            ListTile
            (
              leading: const Icon(Icons.volume_up, color: Colors.white),
              title: const Text('Ajustes de volumen', style: AppTheme.dialogBodyStyle),
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

                const SizedBox(height: 20);

              }
            ),

            // Opción para pausar la partida.
            // Al pulsar esta opción se llama al callback para pausar la partida.
            
            widget.pausaSolicitada
              ? ListTile(
                  leading: const Icon(Icons.play_arrow, color: Colors.white),
                  title: const Text('Anular pausa', style: AppTheme.dialogBodyStyle),
                  tileColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onTap: () {
                    widget.resumeGameCallback();
                    Navigator.of(context).pop();
                  },
                )
              : ListTile(
                  leading: const Icon(Icons.pause, color: Colors.white),
                  title: const Text('Pausar partida', style: AppTheme.dialogBodyStyle),
                  tileColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onTap: () {
                    widget.pauseGameCallback();
                    Navigator.of(context).pop();
                  },
                ),

            const SizedBox(height: 10),

            // Opción para abandonar la partida.
            // Al pulsar esta opción se llama al callback para salir de la partida.
            ListTile
            (
              leading: const Icon(Icons.exit_to_app, color: Colors.white),
              title: const Text('Salir de la partida', style: AppTheme.dialogBodyStyle),
              tileColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onTap: ()
              {
                widget.exitGameCallback();
              }
            ),

            const SizedBox(height: 20),

            // Botón para cerrar el diálogo de ajustes.
            ElevatedButton
            (
              style: ElevatedButton.styleFrom
              (
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
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