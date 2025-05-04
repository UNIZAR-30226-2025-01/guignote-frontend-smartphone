import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/services/websocket_service.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/routes.dart';

class ListGamesScreen extends StatefulWidget {
  const ListGamesScreen({super.key});

  @override
  ListGamesScreenState createState() => ListGamesScreenState();
}

class ListGamesScreenState extends State<ListGamesScreen> {

  Map<String, dynamic>? salas;
  final WebsocketService websocketService = WebsocketService(); // instancia del servicio de WebSocket
  StreamSubscription<Map<String,dynamic>>? subscription; // suscripción al stream de mensajes entrantes
  Map<String, dynamic>? gameData; // datos del juego

  @override
  void initState() {
    super.initState();
    updateSalasDisponibles();
  }

  void updateSalasDisponibles() async {
    final _salas = await getSalasDisponibles();
    setState(() {
      salas = _salas;
    });
    
    print(salas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          //Fondo principal con degradado radial.
          const Background(),

          buildGameList(),

          // Ponemos las decoraciones de las esquinas.
          const CornerDecoration(
            imageAsset: 'assets/images/gold_ornaments.png',
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 3),
    );
  }

  Future<void> joinGame(int partidaID) async
  {

    try
    {
      // Conecta al socket pidiendo 2 jugadores
      await websocketService.connect(partidaID: partidaID);

      subscription?.cancel(); // Cancela la suscripción anterior si existe.
      subscription = null; // Restablece la suscripción.

      // Escucha los mensajes entrantes del socket
      subscription = websocketService.incomingMessages.listen
      (
        (message) 
        {
          final type = message['type'] as String?;
          final data = message['data'] as Map<String, dynamic>?;
          print(type); // Imprime el tipo de mensaje recibido.
          print(data); // Imprime los datos del mensaje recibido.

          if (type == 'player_joined' && data != null)
          {

            //if(Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
          }

          if (type == 'start_game' && data != null) 
          {
            // Cierra el overlay de carga
            if( Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
            setState(() {
              gameData = data; // Guarda los datos del juego.
            });
          }

          if (type == 'turn_update' && data != null) 
          {
            // Cierra el overlay de carga
            if( Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
            subscription?.cancel(); // Cancela la suscripción al socket en esta pantalla.

            // Navega a la pantalla de juego y pasamos los datos del juego , primer turno y socket
            Navigator.pushReplacementNamed(
              context, 
              AppRoutes.game, 
              arguments: {
                'gameData': gameData, // Datos del juego
                'firstTurn': data, // Primer turno del juego
                'socket': websocketService, // Socket del juego
              });
          }
        }
      );
    } catch (e)
    {
      if(Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
      setState(() {
        
      });

      ScaffoldMessenger.of(context).showSnackBar
      (
        const SnackBar
        (
          content: Text('Error al buscar partida'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget buildGameList() {

    // Opciones para los desplegables
    final List<String> filterOptions1 = ['Todos', 'Activas', 'Finalizadas'];
    final List<String> filterOptions2 = ['Por fecha', 'Por nombre'];

    // Variables para almacenar las selecciones de los desplegables
    String selectedFilter1 = filterOptions1[0];
    String selectedFilter2 = filterOptions2[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center the dropdowns horizontally
      children: [
        const SizedBox(height: 50), 
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the dropdowns horizontally
          children: [
            // Primer desplegable
            Container(
              decoration: BoxDecoration(
                color: Colors.black, // Set black background
                borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: selectedFilter1,
                dropdownColor: Colors.black, // Set dropdown menu background to black
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFilter1 = newValue!;
                  });
                },
                items: filterOptions1.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: Colors.white)), // Set text color to white
                  );
                }).toList(),
              ),
            ),

            const SizedBox(width: 16), // Add spacing between dropdowns

            // Segundo desplegable
            Container(
              decoration: BoxDecoration(
                color: Colors.black, // Set black background
                borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: selectedFilter2,
                dropdownColor: Colors.black, // Set dropdown menu background to black
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFilter2 = newValue!;
                  });
                },
                items: filterOptions2.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: Colors.white)), // Set text color to white
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        // Lista de partidas
        Expanded(
          child: ListView.builder(
            itemCount: salas?['salas']?.length ?? 0,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(salas?['salas']?[index]['nombre'] ?? 'Sala sin nombre'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((salas?['salas']?[index]['jugadores']?.length ?? 0) > 0) 
                      Text('Jugadores',
                      style: const TextStyle(decoration: TextDecoration.underline),
                      ),
                      Text('${(salas?['salas']?[index]['jugadores']?.length ?? 0) > 0 ? salas?['salas']?[index]['jugadores'][0] : '-'}'),
                      Text('${(salas?['salas']?[index]['jugadores']?.length ?? 0) > 1 ? salas?['salas']?[index]['jugadores'][1] : '-'}'),
                      if ((salas?['salas']?[index]['capacidad'] ?? 0) > 2) 
                      Text('${(salas?['salas']?[index]['jugadores']?.length ?? 0) > 2 ? salas?['salas']?[index]['jugadores'][2] : '-'}'),
                      if ((salas?['salas']?[index]['capacidad'] ?? 0) > 2)
                      Text('${(salas?['salas']?[index]['jugadores']?.length ?? 0) > 3 ? salas?['salas']?[index]['jugadores'][3] : '-'}'),
                    ],
                  ),
                  trailing: Text('Jugadores: ${salas?['salas']?[index]['num_jugadores'] ?? 0}/${salas?['salas']?[index]['capacidad'] ?? 0}'),
                  onTap: () {
                    // Acción al seleccionar una partida
                    joinGame(salas?['salas']?[index]['id'] ?? -1);
                    print('Seleccionaste ${salas?['salas']?[index]['nombre'] ?? 'Sala sin nombre'}');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
}



