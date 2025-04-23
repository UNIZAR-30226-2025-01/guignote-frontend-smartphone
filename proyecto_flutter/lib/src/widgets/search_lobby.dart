import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';

class SearchLobby extends StatelessWidget
{
  final String statusMessage;
  final List<Map<String, dynamic>> players;
  final VoidCallback onCancel;

  const SearchLobby({
    super.key,
    required this.statusMessage,
    required  this.onCancel,
    required this.players,
  });


  @override
  Widget build(BuildContext context)
  {
    return Stack
    (
      children: 
      [
        // Bloquea interacciones con el resto de la aplicación
        ModalBarrier
        (
          dismissible: false,
          color: Colors.black.withAlpha(20),
        ),

        Center
        (
          child: Container
          (
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration
            (
              color: AppTheme.blackColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: 
              [
                BoxShadow
                (
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            ),
            child: Column
            (
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: 
              [
                const Text('Buscando partida...', style: AppTheme.dialogTitleStyle),
                const SizedBox(height: 10),

                Text(statusMessage, style: AppTheme.dialogBodyStyle, textAlign: TextAlign.center,),
                const SizedBox(height: 20),
                const CircularProgressIndicator
                (
                  color: Colors.amber,
                ),
                const SizedBox(height: 20),

                // Lista de jugadores conectados
                if(players.isNotEmpty)...
                [
                  const Text('Jugadores conectados:', style: AppTheme.dialogBodyStyle, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  
                  for (var player in players)...
                  [
                    Text(player['nombre'] as String, style: AppTheme.dialogPlayerStyle, textAlign: TextAlign.center),
                    const SizedBox(height: 5),
                  ],
                ],

                ElevatedButton
                (
                  onPressed: onCancel, 
                  style: ElevatedButton.styleFrom
                  (
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancelar búsqueda', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}