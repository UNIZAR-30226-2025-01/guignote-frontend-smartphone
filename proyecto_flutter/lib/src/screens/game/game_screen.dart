import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/game/game_card.dart';
import 'package:sota_caballo_rey/src/widgets/game/card_in_fan.dart';
import 'package:sota_caballo_rey/src/services/websocket_service.dart';
import 'package:sota_caballo_rey/routes.dart';
import 'dart:math' as math;
import 'dart:async';

const int SEGUNDOS_POR_TURNO = 15; // Segundos por turno
const String deckSelected = 'base'; // Baraja seleccionada por el jugador.

class GameScreen extends StatefulWidget {

  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isInitialized = false; // Bandera para evitar múltiples ejecuciones
  double _volume = 0.5;
  late Timer cuentaAtrasTurnoTimer;

  WebsocketService? _websocketService; // Servicio WebSocket para la conexión

  int numJugadores = 2; // Número de jugadores en la partida (2 o 4)

  int cartasPorRonda = 2; // Número de cartas que se juegan en una ronda (2 o 4)

  String? selectedCard; // null o la carta elegida.

  String triunfo = '';



  List<String> playerHand = ['1Oros', '2Oros', '3Oros', '4Oros', '5Oros', '6Oros'];
  List<String> rivalHand = ['Back', 'Back', 'Back', 'Back', 'Back', 'Back'];
  int cartasRestantes = 0;
  int segundosRestantesTurno = SEGUNDOS_POR_TURNO;
  bool mostrarSegundosRestantesTurno = false;

  int? mazoRestante;
  List<dynamic>? misCartas;
  bool? faseArrastre;
  Map<String, dynamic>? cartaTriunfo;
  int? chatId;
  List<dynamic>? jugadores;

  // id del jugador que le toca jugar
  String turnoJugador = '';




  // Datos de jugadores
  // el jugador 1 es el jugador propio
  String? jugador1Nombre;
  int? jugador1Id;
  int? jugador1Equipo;
  int? jugador1NumCartas;
  int jugador1Puntos = 0;
  String jugador1FotoUrl = '';
  String jugador1PlayedCard = '';

  // el jugador 2 es el compañero del jugador 1
  // (solo en 2vs2, en 1vs1 es el rival)
  String? jugador2Nombre;
  int? jugador2Id;
  int? jugador2Equipo;
  int? jugador2NumCartas;
  int jugador2Puntos = 0;
  String jugador2FotoUrl = '';
  String jugador2PlayedCard = '';

  // el jugador 3 es un rival solo en 2vs2
  String? jugador3Nombre;
  int? jugador3Id;
  int? jugador3Equipo;
  int? jugador3NumCartas;
  int jugador3Puntos = 0;
  String jugador3FotoUrl = '';
  String jugador3PlayedCard = '';

  // el jugador 4 es un rival solo en 2vs2
  String? jugador4Nombre;
  int? jugador4Id;
  int? jugador4Equipo;
  int? jugador4NumCartas;
  int jugador4Puntos = 0;
  String jugador4FotoUrl = '';
  String jugador4PlayedCard = '';


  void ordenarCartas(List<String> hand) {
    const valorPrioridad = {
      '1': 10,
      '3': 9,
      '12': 8,
      '10': 7,
      '11': 6,
      '7': 5,
      '6': 4,
      '5': 3,
      '4': 2,
      '2': 1,
    };

    hand.sort((a, b) {
      // Divide las cartas en valor y palo
      final cardA = parseCard(a)!; // Usa parseCard para obtener el valor y el palo
      final cardB = parseCard(b)!;

      // Compara primero por palo
      int paloComparison = cardA['palo']!.compareTo(cardB['palo']!);
      if (paloComparison != 0) {
        return paloComparison; // Si los palos son diferentes, ordena por palo
      }

      // Si los palos son iguales, compara por prioridad de valor
      int prioridadA = valorPrioridad[cardA['valor']!]!;
      int prioridadB = valorPrioridad[cardB['valor']!]!;
      return prioridadB.compareTo(prioridadA); // Ordena de mayor a menor prioridad
    });
  }

  Map<String, String>? parseCard(String card) {
    // Usa una expresión regular para separar el número y el palo
    final match = RegExp(r'^(\d+)([A-Za-z]+)$').firstMatch(card);

    if (match != null) {
      final numero = match.group(1)!; // Captura el número
      final palo = match.group(2)!;   // Captura el palo

      return {
        'palo': palo,
        'valor': numero,
      };
    } else {
      print('Formato de carta inválido: $card');
      return null; // Devuelve null si el formato es inválido
    }
  }

  void salirDeLaPartida() {
    cuentaAtrasTurnoTimer.cancel(); // Cancela el temporizador de cuenta atrás
    _websocketService?.disconnect(); // Cierra el WebSocket
    Navigator.pushReplacementNamed(context, AppRoutes.home); // Redirige a la pantalla de inicio
                      
  }

  void onCardTap(String card) {
    setState(() {
      if (selectedCard == card) {
        jugarCarta(card);
        selectedCard = null;
      } else {
        selectedCard = card;
      }
    });
  }

  void jugarCarta(String card) {
    setState(() {
      if(turnoJugador == jugador1Nombre) {
        if(jugador1PlayedCard.isEmpty) {
          final mapCard = parseCard(card);
          
          int valorCarta = int.parse(mapCard!['valor']!);

          final data = {
            'accion': 'jugar_carta',
              'carta': {
              'palo': mapCard['palo'],
              'valor': valorCarta,
            },
          };

          _websocketService?.send(data); // Envía la carta jugada al servidor

          //print('jugar_carta: $data');
        }
      } else {
        print('No es tu turno para jugar la carta: $card');
      }
      
    });
  }

  void cambiarTriunfo() {
    setState(() {
      //triunfo = '1Copas';
    });
  }
  
  void cuentaAtrasTurno(){
    cuentaAtrasTurnoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      
  
      // Ejemplo: Verifica si el turno ha cambiado
      if (turnoJugador != jugador1Nombre) {
        //print('Es el turno de $turnoJugador');
        setState(() {
          mostrarSegundosRestantesTurno = false;
          segundosRestantesTurno = SEGUNDOS_POR_TURNO;
        });
      } else {
        //print('Es tu turno');
        //print('Segundos restantes: $segundosRestantesTurno');
        setState(() {
          mostrarSegundosRestantesTurno = true;
          if(segundosRestantesTurno > 0) {
            segundosRestantesTurno--;
          }
        });
      }

  
    });
  }

  // Método para escuchar mensajes del WebSocket
  void _listenToWebSocket() {
    _websocketService?.incomingMessages.listen((message) {
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;

      print(type);
      print(data);
      
      if (type == 'turn_update' && data != null) {
        setState(() {
          turnoJugador = data['jugador']?['nombre'] ?? 'null'; // Nombre del jugador que le toca jugar
        });
      }

      /*
      {
        "type": "card_played",
        "data": {
          "jugador": {
            "nombre": "Usuario 1",
            "id": 1
          },
          "automatica": false,
          "carta": { "palo": "oros", "valor": 1 }
        }
      }
      */

      if (type == 'card_played' && data != null) {

        final jugadorid = data['jugador']?['id']; // id del jugador que ha jugado la carta
        final carta = data['carta']; // carta jugada por el jugador
        String cartaString = carta['valor'].toString() + carta['palo'].toString(); // carta jugada en formato string
        setState(() {
          if(jugadorid == jugador1Id){
            jugador1PlayedCard = cartaString; // carta jugada por el jugador
            playerHand.remove(cartaString); // elimina la carta del mazo del jugador
          }else if(jugadorid == jugador2Id){
            jugador2PlayedCard = cartaString; // carta jugada por el compañero
            if(numJugadores == 2) {
              rivalHand.remove('Back'); // elimina la carta del mazo del jugador
            }
          }else if(jugadorid == jugador3Id){
            jugador3PlayedCard = cartaString; // carta jugada por el rival
          }else if(jugadorid == jugador4Id){
            jugador4PlayedCard = cartaString; // carta jugada por el rival
          }

        });
      }

      /*
      {
        "type": "round_result",
        "data": {
          "ganador": {
            "nombre": "Usuario 1",
            "id": 1,
            "equipo": 1
          },
          "puntos_baza": 15,
          "puntos_equipo_1": 15,
          "puntos_equipo_2": 0
        }
      }
      */

      if (type == 'round_result' && data != null) {

        int puntosEquipo1 = (data['puntos_equipo_1'] as num).toInt(); // Convierte puntosGanados a int
        int puntosEquipo2 = (data['puntos_equipo_2'] as num).toInt(); // Convierte puntosGanados a int
        
        setState(() {
          if (cartasRestantes > 0) {
            cartasRestantes -= numJugadores; // Actualiza el número de cartas restantes
          }

          if (cartasRestantes <= 0) {
            faseArrastre = true; // Asegúrate de que no sea negativo
          }
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              jugador1PlayedCard = ''; // Reinicia la carta jugada por el jugador
              jugador2PlayedCard = ''; // Reinicia la carta jugada por el rival
              jugador3PlayedCard = ''; // Reinicia la carta jugada por el rival
              jugador4PlayedCard = ''; // Reinicia la carta jugada por el rival
            });
          });
          segundosRestantesTurno = SEGUNDOS_POR_TURNO; // Reinicia el temporizador de cuenta atrás
          mostrarSegundosRestantesTurno = false; // Oculta el temporizador de cuenta atrás
          // Actualiza los puntos de los jugadores
          if(jugador1Equipo == 1){
            jugador1Puntos = puntosEquipo1;
          }else{
            jugador1Puntos = puntosEquipo2;
          }

          if(jugador2Equipo == 1){
            jugador2Puntos = puntosEquipo1;
          }else{
            jugador2Puntos = puntosEquipo2;
          }

          if(jugador3Equipo == 1){
            jugador3Puntos = puntosEquipo1;
          }else{
            jugador3Puntos = puntosEquipo2;
          }

          if(jugador4Equipo == 1){
            jugador4Puntos = puntosEquipo1;
          }else{
            jugador4Puntos = puntosEquipo2;
          }
          
        });
      }

      /*
      {
        "type": "card_drawn",
        "data": {
          "carta": { "palo": "copas", "valor": 3 }
        }
      }
      */
      if (type == 'card_drawn' && data != null) {

        final carta = data['carta']; // carta jugada por el jugador
        String cartaString = carta['valor'].toString() + carta['palo'].toString(); // carta jugada en formato string
        
        setState(() {
          playerHand.add(cartaString); // añade la carta al mazo del jugador
          ordenarCartas(playerHand); // ordena las cartas de la mano del jugador
          if(numJugadores == 2) {
            rivalHand.add('Back'); // elimina la carta del mazo del jugador
          }
        });
      }

      /*
      {
        "type": "phase_update",
        "data": {
          "message": "La partida entra en fase de arrastre."
        }
      }
      */


      /*
      {
        "type": "player_left",
        "data": {
          "message": "Usuario 1 se ha desconectado.",
          "usuario": {
            "nombre": "Usuario 1",
            "id": 1
          },
          "capacidad": 4,
          "jugadores": 3
        }
      }
      */


      /*
      {
        "type": "end_game",
        "data": {
          "message": "Fin de la partida.",
          "ganador_equipo": 1,                           *0 si empate
          "puntos_equipo_1": 101,
          "puntos_equipo_2": 85
        }
      }
      */

      if (type == 'end_game' && data != null) {

        setState(() {
          cuentaAtrasTurnoTimer.cancel(); // Cancela el temporizador de cuenta atrás
          mostrarSegundosRestantesTurno = false;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('FIN DE LA PARTIDA'),
                content: Text('Tus puntos: $jugador1Puntos\nPuntos rival: ${numJugadores == 4 ? jugador3Puntos : jugador2Puntos}\nGanador: ${data['ganador_equipo'] == jugador1Equipo ? 'TU EQUIPO' : 'EQUIPO RIVAL'}'),
                actions: [
                    Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9, // Ocupa el 90% del ancho
                      child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Color rojo
                        padding: const EdgeInsets.symmetric(vertical: 15), // Altura del botón
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Bordes redondeados
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Cierra el diálogo
                        _websocketService?.disconnect(); // Cierra el WebSocket
                        Navigator.pushReplacementNamed(context, AppRoutes.home); // Redirige a la pantalla de inicio
                      },
                      child: const Text(
                        'SALIR',
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 18, // Tamaño de fuente más grande
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        });
      }
    });
  }

  void fillPlayerData2vs2(String miNombre) async{
    final jugador1 = jugadores?[0] as Map<String, dynamic>;
    final jugador2 = jugadores?[1] as Map<String, dynamic>;
    final jugador3 = jugadores?[2] as Map<String, dynamic>;
    final jugador4 = jugadores?[3] as Map<String, dynamic>;


    if (jugador1['nombre'] == miNombre) {
      
      jugador1Nombre = jugador1['nombre'];
      jugador1Id = jugador1['id'];
      jugador1Equipo = jugador1['equipo'];
      jugador1NumCartas = jugador1['num_cartas'];

      jugador2Nombre = jugador3['nombre'];
      jugador2Id = jugador3['id'];
      jugador2Equipo = jugador3['equipo'];
      jugador2NumCartas = jugador3['num_cartas'];

      jugador3Nombre = jugador4['nombre'];
      jugador3Id = jugador4['id'];
      jugador3Equipo = jugador4['equipo'];
      jugador3NumCartas = jugador4['num_cartas'];

      jugador4Nombre = jugador2['nombre'];
      jugador4Id = jugador2['id'];
      jugador4Equipo = jugador2['equipo'];
      jugador4NumCartas = jugador2['num_cartas'];

    } else if(jugador2['nombre'] == miNombre) {

      jugador1Nombre = jugador2['nombre'];
      jugador1Id = jugador2['id'];
      jugador1Equipo = jugador2['equipo'];
      jugador1NumCartas = jugador2['num_cartas'];

      jugador2Nombre = jugador4['nombre'];
      jugador2Id = jugador4['id'];
      jugador2Equipo = jugador4['equipo'];
      jugador2NumCartas = jugador4['num_cartas'];

      jugador3Nombre = jugador1['nombre'];
      jugador3Id = jugador1['id'];
      jugador3Equipo = jugador1['equipo'];
      jugador3NumCartas = jugador1['num_cartas'];

      jugador4Nombre = jugador3['nombre'];
      jugador4Id = jugador3['id'];
      jugador4Equipo = jugador3['equipo'];
      jugador4NumCartas = jugador3['num_cartas'];

    } else if(jugador3['nombre'] == miNombre) {

      jugador1Nombre = jugador3['nombre'];
      jugador1Id = jugador3['id'];
      jugador1Equipo = jugador3['equipo'];
      jugador1NumCartas = jugador3['num_cartas'];

      jugador2Nombre = jugador1['nombre'];
      jugador2Id = jugador1['id'];
      jugador2Equipo = jugador1['equipo'];
      jugador2NumCartas = jugador1['num_cartas'];

      jugador3Nombre = jugador2['nombre'];
      jugador3Id = jugador2['id'];
      jugador3Equipo = jugador2['equipo'];
      jugador3NumCartas = jugador2['num_cartas'];

      jugador4Nombre = jugador4['nombre'];
      jugador4Id = jugador4['id'];
      jugador4Equipo = jugador4['equipo'];
      jugador4NumCartas = jugador4['num_cartas'];

    } else if(jugador4['nombre'] == miNombre) {

      jugador1Nombre = jugador4['nombre'];
      jugador1Id = jugador4['id'];
      jugador1Equipo = jugador4['equipo'];
      jugador1NumCartas = jugador4['num_cartas'];

      jugador2Nombre = jugador2['nombre'];
      jugador2Id = jugador2['id'];
      jugador2Equipo = jugador2['equipo'];
      jugador2NumCartas = jugador2['num_cartas'];

      jugador3Nombre = jugador3['nombre'];
      jugador3Id = jugador3['id'];
      jugador3Equipo = jugador3['equipo'];
      jugador3NumCartas = jugador3['num_cartas'];

      jugador4Nombre = jugador1['nombre'];
      jugador4Id = jugador1['id'];
      jugador4Equipo = jugador1['equipo'];
      jugador4NumCartas = jugador1['num_cartas'];

    }
        

    final dataJugador1 = await getUserStatisticsWithID(jugador1Id!); // Llama al método para obtener los datos del jugador 1
    final dataJugador2 = await getUserStatisticsWithID(jugador2Id!); // Llama al método para obtener los datos del jugador 2
    final dataJugador3 = await getUserStatisticsWithID(jugador3Id!); // Llama al método para obtener los datos del jugador 3
    final dataJugador4 = await getUserStatisticsWithID(jugador4Id!); // Llama al método para obtener los datos del jugador 4

    jugador1FotoUrl = dataJugador1['imagen'] ?? ''; // Asigna la foto del jugador a jugador1
    jugador2FotoUrl = dataJugador2['imagen'] ?? ''; // Asigna la foto del jugador a jugador2
    jugador3FotoUrl = dataJugador3['imagen'] ?? ''; // Asigna la foto del jugador a jugador3
    jugador4FotoUrl = dataJugador4['imagen'] ?? ''; // Asigna la foto del jugador a jugador4
  }

  void fillPlayerData1vs1(String miNombre) async{
    final jugador1 = jugadores?[0] as Map<String, dynamic>;
    final jugador2 = jugadores?[1] as Map<String, dynamic>;

    if (jugadores?.length != null && jugadores!.length >= 2) {
      if (jugador1['nombre'] == miNombre) {
        
        jugador1Nombre = jugador1['nombre'];
        jugador1Id = jugador1['id'];
        jugador1Equipo = jugador1['equipo'];
        jugador1NumCartas = jugador1['num_cartas'];

        jugador2Nombre = jugador2['nombre'];
        jugador2Id = jugador2['id'];
        jugador2Equipo = jugador2['equipo'];
        jugador2NumCartas = jugador2['num_cartas'];

      }else{

        jugador1Nombre = jugador2['nombre'];
        jugador1Id = jugador2['id'];
        jugador1Equipo = jugador2['equipo'];
        jugador1NumCartas = jugador2['num_cartas'];

        jugador2Nombre = jugador1['nombre'];
        jugador2Id = jugador1['id'];
        jugador2Equipo = jugador1['equipo'];
        jugador2NumCartas = jugador1['num_cartas'];

      }
    }

    final dataJugador1 = await getUserStatisticsWithID(jugador1Id!); // Llama al método para obtener los datos del jugador 1
    final dataJugador2 = await getUserStatisticsWithID(jugador2Id!); // Llama al método para obtener los datos del jugador 2

    jugador1FotoUrl = dataJugador1['imagen'] ?? ''; // Asigna la foto del jugador a jugador1
    jugador2FotoUrl = dataJugador2['imagen'] ?? ''; // Asigna la foto del jugador a jugador2
  }


  Future<void> fillArguments() async {
    /*
    "data": {
      "mazo_restante": 27,                                       cartas que quedan en mazo central
      "mis_cartas": [ /* cartas asignadas al jugador */ ],       tu mano
      "fase_arrastre": false,                                    estás en arrastre?
      "carta_triunfo": { "palo": "oros", "valor": 7 },           carta triunfo
      "chat_id": <CHAT_ID>,                                      id del chat de la partida
      "jugadores": [                                             información jugadores
        {
          "id": 1,
          "nombre": "Usuario 1",
          "equipo": 1,
          "num_cartas": 6
        },
        {
          "id": 2,
          "nombre": "Usuario 2",
          "equipo": 2,
          "num_cartas": 6
        }
      ]
    }
    */

    // Obtén los argumentos pasados desde la pantalla anterior
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final data = arguments?['gameData'] as Map<String, dynamic>?;
    final firstTurn = arguments?['firstTurn'] as Map<String, dynamic>?;
    _websocketService = arguments?['socket'] as WebsocketService?;

    print(data);
    print(firstTurn);

    // extraer los datos del primer turno
    turnoJugador = firstTurn?['jugador']?['nombre'] ?? 'null'; // Nombre del jugador que le toca jugar
    print(turnoJugador);
    cuentaAtrasTurno(); // Llama a la función para iniciar el temporizador de cuenta atrás

    // Extrae los campos del mapa "data"
    mazoRestante = data?['mazo_restante'];
    cartasRestantes = mazoRestante!; // Asigna el valor de mazoRestante a cartasRestantes
    misCartas = data?['mis_cartas'];
    if (misCartas != null) {
      for (var carta in misCartas!) {
        if (carta.length >= 2) {
          String palo = carta['palo'].toString(); // Extrae el valor asociado a la clave 'palo'
          String valor = carta['valor'].toString(); // Segundo elemento de la sublista

          playerHand[misCartas!.indexOf(carta)] = valor + palo; // Asigna el primer elemento a la mano del jugador
        }
      }
    }

    ordenarCartas(playerHand); // Ordena las cartas de la mano del jugador

    faseArrastre = data?['fase_arrastre'];

    // Extrae detalles de la carta triunfo
    cartaTriunfo = data?['carta_triunfo'];
    triunfo = (cartaTriunfo?['valor']?.toString() ?? '') + (cartaTriunfo?['palo']?.toString() ?? '');
    
    
    chatId = data?['chat_id'];


    String miNombre = '';

    // extrae mis datos
    try {
      final stats = await getUserStatistics(); // Llama al método para obtener los datos
      miNombre = stats['nombre'] ?? 'null'; // Nombre del jugador
    } catch (error) {
      print("Error al obtener estadísticas del usuario: $error");
    }

    jugadores = data?['jugadores'];
    if (jugadores != null) {
      numJugadores = jugadores!.length; // Número de jugadores en la partida
    }

    

    print('Número de jugadores: $numJugadores');
    
    if(numJugadores == 4) {
      fillPlayerData2vs2(miNombre); // Llama a la función para llenar los datos del jugador 2vs2
    }else{
      fillPlayerData1vs1(miNombre); // Llama a la función para llenar los datos del jugador 1vs1
    }

    _listenToWebSocket(); // Escucha los mensajes del WebSocket
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      fillArguments(); // Llama a la función solo la primera vez
      _isInitialized = true; // Marca como inicializado
    }
  }

  Scaffold build1vs1(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo principal:
          const Background(),
          const CornerDecoration(
            imageAsset: 'assets/images/gold_ornaments.png',
          ),
          // Logo de la aplicación al fondo
          Align(
            alignment: const Alignment(0.0, -0.15),
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/app_logo_white.png',
                width: 100,
              ),
            ),
          ),

          if (faseArrastre == false) ...[
            // Carta triunfo
            Align(
              alignment: const Alignment(0.3, -0.11),
              child: RotatedBox(
              quarterTurns: 45,
              child: GameCard(card: triunfo, deck: deckSelected, width: 75),
              ),
            ),
            // Carta del mazo
            Align(
              alignment: const Alignment(0.0, -0.15),
              child: GameCard(card: 'Back', deck: deckSelected, width: 75),
            ),
          ],

          
          // Carta jugada por el jugador
          jugador1PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.0, 0.25),
                  child: GameCard(card: jugador1PlayedCard, deck: deckSelected, width: 75),
                )
              : const SizedBox.shrink(),

          
          // Carta jugada por el rival
          jugador2PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.0, -0.55),
                  child: GameCard(card: jugador2PlayedCard, deck: deckSelected, width: 75),
                )
              : const SizedBox.shrink(),

          // Añadimos mano del jugador
          Align(
            alignment: const Alignment(0.0, 0.77),
            child: buildPlayerHand(context, playerHand),
          ),

          // Añadimos mano del rival
          Align(
            alignment: const Alignment(1.1, -1.1),
            child: Transform.rotate(
              angle: 90.8,
              child: buildRivalHand(context, rivalHand),
            ),
          ),

          // Botones del juego
          Align(
            alignment: const Alignment(0.95, -0.55),
            child: buildSettingsButton(context),
          ),

          Align(
            alignment: const Alignment(0.95, -0.7),
            child: buildChatButton(context),
          ),

          Align(
            alignment: const Alignment(0.95, 0.38),
            child: buildGameButtons(context),
          ),

          // Información de la partida
          Align(
            alignment: const Alignment(-0.9, -0.15),
            child: buildInfoPartida(context),
          ),

          // Iconos de los jugadores
          Align(
            alignment: const Alignment(-0.9, 0.38),
            child: buildPlayerIcon(context, jugador1Nombre.toString(), jugador1FotoUrl),
          ),
          Align(
            alignment: const Alignment(-0.9, -0.68),
            child: buildPlayerIcon(context, jugador2Nombre.toString(), jugador2FotoUrl),
          ),

          // Mostrar segundos restantes del turno
          if (mostrarSegundosRestantesTurno)
            Align(
              alignment: const Alignment(0.0, 0.45),
              child: Text(
              '$segundosRestantesTurno',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                
              ),
              ),
            ),
        ],
      ),
    );
  }

  Scaffold build2vs2(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo principal:
          const Background(),
          const CornerDecoration(
            imageAsset: 'assets/images/gold_ornaments.png',
          ),
          // Logo de la aplicación al fondo
          Align(
            alignment: const Alignment(0.0, -0.15),
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/app_logo_white.png',
                width: 100,
              ),
            ),
          ),

          if (faseArrastre == false) ...[
            // Carta triunfo
            Align(
              alignment: const Alignment(0.0, -0.15),
              child: GameCard(card: triunfo, deck: deckSelected, width: 75),
            ),
          ],

          
          // Carta jugada por el jugador
          jugador1PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.0, 0.25),
                  child: GameCard(card: jugador1PlayedCard, deck: deckSelected, width: 75),
                )
              : const SizedBox.shrink(),

          
          // Carta jugada por el jugador
          jugador2PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.0, -0.55),
                  child: GameCard(card: jugador2PlayedCard, deck: deckSelected, width: 75),
                )
              : const SizedBox.shrink(),

          // Carta jugada por el rival 1
          jugador3PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(-0.55, -0.15),
                  child: GameCard(card: jugador3PlayedCard, deck: deckSelected, width: 75),
                )
              : const SizedBox.shrink(),
          
          // Carta jugada por el rival 3
          jugador4PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.55, -0.15),
                  child: GameCard(card: jugador4PlayedCard, deck: deckSelected, width: 75),
                )
              : const SizedBox.shrink(),

          // Añadimos mano del jugador
          Align(
            alignment: const Alignment(0.0, 0.77),
            child: buildPlayerHand(context, playerHand),
          ),


          // Botones del juego
          Align(
            alignment: const Alignment(0.80, -0.90),
            child: buildSettingsButton(context),
          ),

          Align(
            alignment: const Alignment(0.80, -0.75),
            child: buildChatButton(context),
          ),

          Align(
            alignment: const Alignment(0.95, 0.38),
            child: buildGameButtons(context),
          ),

          // Información de la partida
          Align(
            alignment: const Alignment(-0.80, -0.90),
            child: buildInfoPartida(context),
          ),

          // Iconos de los jugadores
          Align(
            alignment: const Alignment(-0.70, 0.38),
            child: buildPlayerIcon(context, jugador1Nombre.toString(), jugador1FotoUrl),
          ),
          Align(
            alignment: const Alignment(0.0, -0.90),
            child: buildPlayerIcon(context, jugador2Nombre.toString(), jugador2FotoUrl),
          ),
          Align(
            alignment: const Alignment(-0.9, -0.50),
            child: buildPlayerIcon(context, jugador3Nombre.toString(), jugador3FotoUrl),
          ),
          Align(
            alignment: const Alignment(0.9, -0.50),
            child: buildPlayerIcon(context, jugador4Nombre.toString(), jugador4FotoUrl),
          ),

          // Mostrar segundos restantes del turno
          if (mostrarSegundosRestantesTurno)
            Align(
              alignment: const Alignment(0.0, 0.45),
              child: Text(
              '$segundosRestantesTurno',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                
              ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (numJugadores == 4) {
      return build2vs2(context);
    } else {
      return build1vs1(context);
    }
  }

  buildInfoPartida(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Cartas:', style: const TextStyle(color: Colors.white)),
          Text('$cartasRestantes', style: const TextStyle(color: Colors.white)),
          Text('Puntos:', style: const TextStyle(color: Colors.white)),
          Text('$jugador1Puntos', style: const TextStyle(color: Colors.white)),
          Text('Pts. rival:', style: const TextStyle(color: Colors.white)),
          if (numJugadores == 4) ...[
            Text('$jugador3Puntos', style: const TextStyle(color: Colors.white)),
          ] else ...[
            Text('$jugador2Puntos', style: const TextStyle(color: Colors.white)),
          ]
        ],
      ),
    );
  }

  Widget buildPlayerHand(BuildContext context, List<String> listCards) {
    const cardWidth = 75.0;
    const cardHeight = 105.0;
    const fanAngleDeg = 45.0; // Ángulo del abanico.
    const overlapCorner = 20.0;
    final cardCount = listCards.length;

    // Abanico para una sola carta.
    if (cardCount == 1) {
      return SizedBox(
        width: cardWidth + 40,
        height: cardHeight + 40,
        child: Center(
          child: CardInFan(
            card: listCards[0],
            deck: deckSelected,
            width: cardWidth,
            angle: 0.0,
            dx: 0.0,
            selected: selectedCard == listCards[0],
            onTap: () => onCardTap(listCards[0]),
          ),
        ),
      );
    }

    // Abanico normal para 2 o mas cartas.
    final angleStep = cardCount > 1 ? fanAngleDeg / (cardCount - 1) : 0.0;
    final startAngle = -fanAngleDeg / 2;
    final separation = cardWidth - overlapCorner;

    return SizedBox(
      width: cardWidth + separation * (cardCount - 1) + 40,
      height: cardHeight + 40,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          for (var i = 0; i < cardCount; i++)
            CardInFan(
              card: listCards[i],
              deck: deckSelected,
              width: cardWidth,
              angle: (startAngle + angleStep * i) * (math.pi / 180),
              dx: separation * (i - (cardCount - 1) / 2),
              selected: selectedCard == listCards[i],
              onTap: () => onCardTap(listCards[i]),
            ),
        ],
      ),
    );
  }

  SizedBox buildRivalHand(BuildContext context, List<String> cardImages) {
    // Tamaño de las cartas
    const cardWidth = 75.0;
    const cardHeight = 105.0;
    // Distancia de solapamiento entre cartas
    const overlapDistance = 30.0;
    // Ángulo total de abanico
    const totalFanAngle = 45.0;

    if (cardImages.isEmpty) {
      return const SizedBox();
    }

    final cardCount = cardImages.length;
    final totalAngleRad = totalFanAngle * (3.14159265359 / 180.0);
    final angleStep = cardCount > 1 ? totalAngleRad / (cardCount - 1) : 0.0;
    final startAngle = -totalAngleRad / 2;
    return SizedBox(
      width: cardWidth + overlapDistance * (cardCount - 1) + 50,
      height: cardHeight + 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < cardCount; i++)
            Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..rotateZ(startAngle + angleStep * i)
                    ..translate(overlapDistance * i),
              child: GameCard(card: cardImages[i], deck: deckSelected, width: cardWidth),
            ),
        ],
      ),
    );
  }

  ElevatedButton buildSettingsButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('AJUSTES'),
                content: Text(''),
                actions: [
                    Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9, // Ocupa el 90% del ancho
                      child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Color rojo
                        padding: const EdgeInsets.symmetric(vertical: 15), // Altura del botón
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Bordes redondeados
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Cierra el diálogo
                        salirDeLaPartida(); // Cierra el WebSocket y redirige a la pantalla de inicio
                        },
                      child: const Text(
                        'SALIR',
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 18, // Tamaño de fuente más grande
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                      ),
                    ),
                  ),
                ],
              );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(), // Forma circular
        padding: EdgeInsets.all(15), // Espaciado interno aumentado
        backgroundColor: Colors.black, // Color de fondo del botón
      ),
      child: Icon(
        Icons.settings, // Icono de ajustes
        color: Colors.white, // Color del ícono
        size: 30, // Tamaño del ícono aumentado
      ),
    );
  }

  ElevatedButton buildChatButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Acción cuando se presiona el botón
      },
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(), // Forma circular
        padding: EdgeInsets.all(15), // Espaciado interno aumentado
        backgroundColor: Colors.black, // Color de fondo del botón
      ),
      child: Icon(
        Icons.chat, // Icono de ajustes
        color: Colors.white, // Color del ícono
        size: 30, // Tamaño del ícono aumentado
      ),
    );
  }

  Column buildGameButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: () {
              cambiarTriunfo();
            },
            child: const Text(
              'Cambiar 7',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: () {
              // Acción para el segundo botón
            },
            child: const Text('Cantar', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Column buildPlayerIcon(
    BuildContext context,
    String playerName,
    String imagePath,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
          ),
            child: CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(imagePath),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          playerName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(offset: Offset(-1.0, -1.0), color: Colors.black),
              Shadow(offset: Offset(1.0, -1.0), color: Colors.black),
              Shadow(offset: Offset(1.0, 1.0), color: Colors.black),
              Shadow(offset: Offset(-1.0, 1.0), color: Colors.black),
            ],
          ),
        ),
      ],
    );
  }
}
