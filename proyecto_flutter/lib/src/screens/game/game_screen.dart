import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/src/widgets/game/game_card.dart';
import 'package:sota_caballo_rey/src/widgets/game/card_in_fan.dart';
import 'package:sota_caballo_rey/src/services/websocket_service.dart';
import 'package:sota_caballo_rey/routes.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:sota_caballo_rey/src/screens/game/gamechat_modal.dart';
import 'package:sota_caballo_rey/src/screens/game/game_settings.dart';
import 'package:sota_caballo_rey/src/data/tapete_sets.dart';



String deckSelected1 = 'base';
String deckSelected2 = 'base';
String deckSelected3 = 'base';
String deckSelected4 = 'base';
String tapeteSelected = 'assets/images/tapetes/tapete1.png'; // Tapete por defecto.

class GameScreen extends StatefulWidget {

  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver{
  bool _isInitialized = false; // Bandera para evitar múltiples ejecuciones
  int segundosPorTurno = 15; // Segundos por turno
  late Timer cuentaAtrasTurnoTimer;

  WebsocketService? websocketService; // Servicio WebSocket para la conexión

  int numJugadores = 2; // Número de jugadores en la partida (2 o 4)

  int cartasPorRonda = 2; // Número de cartas que se juegan en una ronda (2 o 4)

  String? selectedCard; // null o la carta elegida.

  String triunfo = '';



  List<String> playerHand = [];
  List<String> rivalHand = ['Back', 'Back', 'Back', 'Back', 'Back', 'Back'];
  int cartasRestantes = 0;
  int segundosRestantesTurno = 15; // Segundos restantes para el turno
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
  bool jugador1SolicitaPausa = false;

  // el jugador 2 es el compañero del jugador 1
  // (solo en 2vs2, en 1vs1 es el rival)
  String? jugador2Nombre;
  int? jugador2Id;
  int? jugador2Equipo;
  int? jugador2NumCartas;
  int jugador2Puntos = 0;
  String jugador2FotoUrl = '';
  String jugador2PlayedCard = '';
  bool jugador2SolicitaPausa = false;

  // el jugador 3 es un rival solo en 2vs2
  String? jugador3Nombre;
  int? jugador3Id;
  int? jugador3Equipo;
  int? jugador3NumCartas;
  int jugador3Puntos = 0;
  String jugador3FotoUrl = '';
  String jugador3PlayedCard = '';
  bool jugador3SolicitaPausa = false;

  // el jugador 4 es un rival solo en 2vs2
  String? jugador4Nombre;
  int? jugador4Id;
  int? jugador4Equipo;
  int? jugador4NumCartas;
  int jugador4Puntos = 0;
  String jugador4FotoUrl = '';
  String jugador4PlayedCard = '';
  bool jugador4SolicitaPausa = false;


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

  String? cardToString(Map<String, dynamic>? card) {
    if(card == null) {
      return null;
    }
    // Convierte el mapa de la carta a una cadena
    if (card['valor'] == null || card['palo'] == null) {
      return null;
    }
    return '${card['valor']}${card['palo']}';
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
      debugPrint('Formato de carta inválido: $card');
      return null; // Devuelve null si el formato es inválido
    }
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
          mensaje,
          style: const TextStyle(color: Colors.white),
          ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }

  void salirDeLaPartida() {
    cuentaAtrasTurnoTimer.cancel(); // Cancela el temporizador de cuenta atrás
    websocketService?.disconnect(); // Cierra el WebSocket
    Navigator.pushReplacementNamed(context, AppRoutes.home); // Redirige a la pantalla de inicio
                      
  }

  void onCardTap(String card) {
    setState(() {
      if (selectedCard == card) {
        jugarCarta(card);
        selectedCard = null;
      } else {
        String card1 = selectedCard ?? '';
        String card2 = card;
        if (card1.isNotEmpty && card2.isNotEmpty) {
          // Intercambia las cartas seleccionadas
          int index1 = playerHand.indexOf(card1);
          int index2 = playerHand.indexOf(card2);

          // Verifica que ambos valores existan en la lista
          if (index1 != -1 && index2 != -1) {
            // Intercambia los elementos
            final temp = playerHand[index1];
            playerHand[index1] = playerHand[index2];
            playerHand[index2] = temp;
          }
          selectedCard = null; // Reinicia la selección de cartas
        }else{
          // Selecciona la carta
          selectedCard = card;
        } 
        

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

          if (websocketService!.isConnected()) {
            websocketService?.send(data); // Envía la carta jugada al servidor
          } else {
            print('No hay conexión WebSocket activa');
          }

          //print('jugar_carta: $data');
        }
      } else {
        print('No es tu turno para jugar la carta: $card');
        mostrarMensaje('No es tu turno para jugar la carta: $card');
      }
      
    });
  }

  void anularPausarPartida(){
    setState(() {
      //Mandamos el mensaje al servidor para intentar cambiar el triunfo
      final data = {
        'accion': 'anular_pausa',
      };

      if (websocketService!.isConnected()) {
        websocketService?.send(data); // Envía la carta jugada al servidor
      } else {
        print('No hay conexión WebSocket activa');
      }

    });
  }

  void pausarPartida(){
    setState(() {
      //Mandamos el mensaje al servidor para intentar cambiar el triunfo
      final data = {
        'accion': 'pausa',
      };

      if (websocketService!.isConnected()) {
        websocketService?.send(data); // Envía la carta jugada al servidor
      } else {
        print('No hay conexión WebSocket activa');
      }

    });
  }

  void accionCantar() {
    setState(() {

      final data = {
        'accion': 'cantar',
      };

      if (websocketService!.isConnected()) {
        websocketService?.send(data); // Envía la carta jugada al servidor
      } else {
        print('No hay conexión WebSocket activa');
      }
      
    });
  }

  void cambiarTriunfo() {
    setState(() {
      //Mandamos el mensaje al servidor para intentar cambiar el triunfo
      final data = {
        'accion': 'cambiar_siete',
      };

      if (websocketService!.isConnected()) {
        websocketService?.send(data); // Envía la carta jugada al servidor
      } else {
        print('No hay conexión WebSocket activa');
      }

    });
  }
  
  void cuentaAtrasTurno(){
    cuentaAtrasTurnoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      
  
      // Ejemplo: Verifica si el turno ha cambiado
      if (turnoJugador != jugador1Nombre) {
        //print('Es el turno de $turnoJugador');
        setState(() {
          mostrarSegundosRestantesTurno = false;
          segundosRestantesTurno = segundosPorTurno; // Reinicia el temporizador de cuenta atrás
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
    websocketService?.incomingMessages.listen((message) {
      
      print(message); // Imprime el mensaje recibido en la consola

      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;
      
            
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
          segundosRestantesTurno = segundosPorTurno; // Reinicia el temporizador de cuenta atrás
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
          if(numJugadores == 2) {
            rivalHand.add('Back'); // elimina la carta del mazo del jugador
          }
        });
      }

      /*
      {
        "type": "cambio_siete",
        "data": {
          "jugador": {
            "nombre": "Usuario 1",
            "id": 1,
            "equipo": 1
          },
          "carta_robada": {"palo": "Oros", valor: 1} // Carta de triunfo. La que cambias por el 7
        }
      }
      */

      if (type == 'cambio_siete' && data != null) {
        
        final jugadorNombre = data['jugador']?['nombre']; // nombre del jugador que ha jugado la carta
        final jugadorid = data['jugador']?['id']; // id del jugador que ha jugado la carta
        final carta = data['carta_robada']; // carta jugada por el jugador
        String cartaString = carta['valor'].toString() + carta['palo'].toString(); // carta jugada en formato string
        String sieteTriunfo = '7' + carta['palo'].toString(); // carta jugada en formato string

        

        setState(() {
          triunfo = sieteTriunfo; // Actualiza la carta de triunfo
          if(jugadorid == jugador1Id){
            if(playerHand.contains(sieteTriunfo)) {
              playerHand.remove(sieteTriunfo); // elimina el 7 del mazo del jugador
              playerHand.add(cartaString); // añade la carta al mazo del jugador
            }
          }
          String mensaje = '${jugadorNombre} ha cambiado el 7'; // Mensaje de canto
          mostrarMensaje(mensaje); // Muestra el mensaje en la pantalla
        });
      }

      /*
      {
        "type": "canto",
        "data": {
          "jugador": {
            "nombre": "Usuario 1",
            "id": 1,
            "equipo": 1
          },
          "cantos": ["20 (Oros)", "40 (triunfo)"],  // Lista de cantos realizados
          "puntos": 60,                             // Puntos totales sumados
          "puntos_equipo_1": 60,                    // Puntos actuales equipo 1
          "puntos_equipo_2": 0                      // Puntos actuales equipo 2
        }
      }
      */
      if (type == 'canto' && data != null) {

        final jugadorNombre = data['jugador']?['nombre']; // id del jugador que ha jugado la carta
        final cantos = data['cantos']; // carta jugada por el jugador
        final puntosEquipo1 = data['puntos_equipo_1']; // puntos del equipo 1
        final puntosEquipo2 = data['puntos_equipo_2']; // puntos del equipo 2
        

        setState(() {
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

          String mensaje;

          if(faseArrastre == false) {
            mensaje = 'Canto de $jugadorNombre: ${cantos.join(', ')}'; // Mensaje de canto
          }else{
            mensaje = 'Canto de $jugadorNombre'; // Mensaje de canto
          }
          
          mostrarMensaje(mensaje);
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
        "type": "pause",
        "data": {
          "jugador": {
            "id": 1,
            "nombre": "Usuario 1",
            "equipo": 1
          },
          "num_solicitudes_pausa": 1
        }
      }
      */
      if (type == 'pause' && data != null) {
        setState(() {
          String jugadorNombre = data['jugador']?['nombre'] ?? 'null'; // Nombre del jugador que ha jugado la carta
          int jugadorId = data['jugador']?['id']; // id del jugador que ha jugado la carta
          //int numSolicitudesPausa = data['num_solicitudes_pausa'] ?? 0; // Número de solicitudes de pausa
          
          if(jugadorId == jugador1Id){
            jugador1SolicitaPausa = true; // El jugador 1 ha solicitado una pausa
          }else if(jugadorId == jugador2Id){
            jugador2SolicitaPausa = true; // El jugador 2 ha solicitado una pausa
          }else if(jugadorId == jugador3Id){
            jugador3SolicitaPausa = true; // El jugador 3 ha solicitado una pausa
          }else if(jugadorId == jugador4Id){
            jugador4SolicitaPausa = true; // El jugador 4 ha solicitado una pausa
          }
          
          String mensaje = '$jugadorNombre ha solicitado una pausa'; // Mensaje de pausa
          mostrarMensaje(mensaje); // Muestra el mensaje en la pantalla
        });
      }

      /*
      {
        "type": "all_pause",
        "data": {
          "message": "La partida ha sido pausada por acuerdo de todos los jugadores."
        }
      }
      */

      if (type == 'all_pause' && data != null) {
        setState(() {
          String mensaje = "Se ha pausado la partida"; // Mensaje de pausa
          mostrarMensaje(mensaje); // Muestra el mensaje en la pantalla
          salirDeLaPartida(); // Salir de la partida
        });
      }

      /*
      {
        "type": "resume",
        "data": {
          "jugador": {
            "id": 1,
            "nombre": "Usuario 1",
            "equipo": 1
          },
          "num_solicitudes_pausa": 0
        }
      }
      */

      if (type == 'resume' && data != null) {
        setState(() {
          String jugadorNombre = data['jugador']?['nombre'] ?? 'null'; // Nombre del jugador que ha jugado la carta
          int jugadorId = data['jugador']?['id']; // id del jugador que ha jugado la carta
          //int numSolicitudesPausa = data['num_solicitudes_pausa'] ?? 0; // Número de solicitudes de pausa
          
          if(jugadorId == jugador1Id){
            jugador1SolicitaPausa = false; // El jugador 1 ha solicitado una pausa
          }else if(jugadorId == jugador2Id){
            jugador2SolicitaPausa = false; // El jugador 2 ha solicitado una pausa
          }else if(jugadorId == jugador3Id){
            jugador3SolicitaPausa = false; // El jugador 3 ha solicitado una pausa
          }else if(jugadorId == jugador4Id){
            jugador4SolicitaPausa = false; // El jugador 4 ha solicitado una pausa
          }
          
          String mensaje = '$jugadorNombre ha cancelado la pausa'; // Mensaje de pausa
          mostrarMensaje(mensaje); // Muestra el mensaje en la pantalla
        });
      }

      
      /*
      { "type": "start_game",
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
      
      if (type == 'start_game' && data != null) {
        setState(() {
          cartasRestantes = data['mazo_restante'];

          playerHand = []; // Inicializa la mano del jugador

          misCartas = data['mis_cartas'];
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

          if(numJugadores == 2) {
            rivalHand = ['Back', 'Back', 'Back', 'Back', 'Back', 'Back']; // Inicializa la mano del rival
          }
          
          faseArrastre = data['fase_arrastre'];

          // Extrae detalles de la carta triunfo
          cartaTriunfo = data['carta_triunfo'];
          triunfo = (cartaTriunfo?['valor']?.toString() ?? '') + (cartaTriunfo?['palo']?.toString() ?? '');
          
          segundosPorTurno = data['tiempo_turno'] ?? 15; // Segundos por turno
          segundosRestantesTurno = segundosPorTurno; // Reinicia el temporizador de cuenta atrás
        });
      }

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
                        websocketService?.disconnect(); // Cierra el WebSocket
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

      if (type == 'error' && data != null) {
        setState(() {
          String mensaje = data['message'] ?? 'Error desconocido'; // Mensaje de error
          mostrarMensaje(mensaje); // Muestra el mensaje en la pantalla
        });
      }

    });
  }

  void fillPlayerData2vs2(String miNombre, int puntosEquipo1, int puntosEquipo2) async{
    final jugador1 = jugadores?[0] as Map<String, dynamic>;
    final jugador2 = jugadores?[1] as Map<String, dynamic>;
    final jugador3 = jugadores?[2] as Map<String, dynamic>;
    final jugador4 = jugadores?[3] as Map<String, dynamic>;

    print(cardToString(jugador1['carta_jugada']) ?? '');
    print(cardToString(jugador2['carta_jugada']) ?? '');
    print(cardToString(jugador3['carta_jugada']) ?? '');
    print(cardToString(jugador4['carta_jugada']) ?? '');


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

      jugador1PlayedCard = cardToString(jugador1['carta_jugada']) ?? '';
      jugador2PlayedCard = cardToString(jugador3['carta_jugada']) ?? '';
      jugador3PlayedCard = cardToString(jugador4['carta_jugada']) ?? '';
      jugador4PlayedCard = cardToString(jugador2['carta_jugada']) ?? '';
      

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

      jugador1PlayedCard = cardToString(jugador2['carta_jugada']) ?? '';
      jugador2PlayedCard = cardToString(jugador4['carta_jugada']) ?? '';
      jugador3PlayedCard = cardToString(jugador1['carta_jugada']) ?? '';
      jugador4PlayedCard = cardToString(jugador3['carta_jugada']) ?? '';

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

      jugador1PlayedCard = cardToString(jugador3['carta_jugada']) ?? '';
      jugador2PlayedCard = cardToString(jugador1['carta_jugada']) ?? '';
      jugador3PlayedCard = cardToString(jugador2['carta_jugada']) ?? '';
      jugador4PlayedCard = cardToString(jugador4['carta_jugada']) ?? '';

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

      jugador1PlayedCard = cardToString(jugador4['carta_jugada']) ?? '';
      jugador2PlayedCard = cardToString(jugador2['carta_jugada']) ?? '';
      jugador3PlayedCard = cardToString(jugador3['carta_jugada']) ?? '';
      jugador4PlayedCard = cardToString(jugador1['carta_jugada']) ?? '';

    }


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
        

    final dataJugador1 = await getUserStatisticsWithID(jugador1Id!); // Llama al método para obtener los datos del jugador 1
    final dataJugador2 = await getUserStatisticsWithID(jugador2Id!); // Llama al método para obtener los datos del jugador 2
    final dataJugador3 = await getUserStatisticsWithID(jugador3Id!); // Llama al método para obtener los datos del jugador 3
    final dataJugador4 = await getUserStatisticsWithID(jugador4Id!); // Llama al método para obtener los datos del jugador 4

    jugador1FotoUrl = dataJugador1['imagen'] ?? ''; // Asigna la foto del jugador a jugador1
    jugador2FotoUrl = dataJugador2['imagen'] ?? ''; // Asigna la foto del jugador a jugador2
    jugador3FotoUrl = dataJugador3['imagen'] ?? ''; // Asigna la foto del jugador a jugador3
    jugador4FotoUrl = dataJugador4['imagen'] ?? ''; // Asigna la foto del jugador a jugador4
  }

  void fillPlayerData1vs1(String miNombre, int puntosEquipo1, int puntosEquipo2) async{
    final jugador1 = jugadores?[0] as Map<String, dynamic>;
    final jugador2 = jugadores?[1] as Map<String, dynamic>;

    print(jugador1['carta_jugada']);
    print(jugador2['carta_jugada']);

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
        
        jugador1PlayedCard = cardToString(jugador1['carta_jugada']) ?? '';
        jugador2PlayedCard = cardToString(jugador2['carta_jugada']) ?? '';

      }else{

        jugador1Nombre = jugador2['nombre'];
        jugador1Id = jugador2['id'];
        jugador1Equipo = jugador2['equipo'];
        jugador1NumCartas = jugador2['num_cartas'];

        jugador2Nombre = jugador1['nombre'];
        jugador2Id = jugador1['id'];
        jugador2Equipo = jugador1['equipo'];
        jugador2NumCartas = jugador1['num_cartas'];

        jugador1PlayedCard = cardToString(jugador2['carta_jugada']) ?? '';
        jugador2PlayedCard = cardToString(jugador1['carta_jugada']) ?? '';

      }
    }

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

    final dataJugador1 = await getUserStatisticsWithID(jugador1Id!); // Llama al método para obtener los datos del jugador 1
    final dataJugador2 = await getUserStatisticsWithID(jugador2Id!); // Llama al método para obtener los datos del jugador 2

    jugador1FotoUrl = dataJugador1['imagen'] ?? ''; // Asigna la foto del jugador a jugador1
    jugador2FotoUrl = dataJugador2['imagen'] ?? ''; // Asigna la foto del jugador a jugador2
  }


  Future<void> fillArguments() async {
    /*
      {jugadores: [{id: 11, nombre: Adriana, equipo: 1, num_cartas: 6, carta_jugada: null},
       {id: 7, nombre: Marcelo, equipo: 2, num_cartas: 6, carta_jugada: null}],
        mazo_restante: 24, fase_arrastre: false, 
        mis_cartas: [{palo: Copas, valor: 7}, {palo: Bastos, valor: 10}, {palo: Bastos, valor: 1}, {palo: Espadas, valor: 5}, {palo: Bastos, valor: 11}, {palo: Espadas, valor: 4}], 
        carta_triunfo: {palo: Oros, valor: 7}, 
        chat_id: 2, 
        tiempo_turno: 30, 
        puntos_equipo_1: 2, puntos_equipo_2: 11, 
        pausados: 0}
    */

    // Obtén los argumentos pasados desde la pantalla anterior
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final data = arguments?['gameData'] as Map<String, dynamic>?;
    final firstTurn = arguments?['firstTurn'] as Map<String, dynamic>?;
    websocketService = arguments?['socket'] as WebsocketService?;

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
    playerHand = []; // Inicializa la mano del jugador
    if (misCartas != null) {
      for (var carta in misCartas!) {
        if (carta.length >= 2) {
          String palo = carta['palo'].toString(); // Extrae el valor asociado a la clave 'palo'
          String valor = carta['valor'].toString(); // Segundo elemento de la sublista

        playerHand.add(valor + palo); // Asigna el primer elemento a la mano del jugador
        }
      }
    }

    ordenarCartas(playerHand); // Ordena las cartas de la mano del jugador

    faseArrastre = data?['fase_arrastre'];

    // Extrae detalles de la carta triunfo
    cartaTriunfo = data?['carta_triunfo'];
    triunfo = (cartaTriunfo?['valor']?.toString() ?? '') + (cartaTriunfo?['palo']?.toString() ?? '');
    
    
    chatId = data?['chat_id'];

    segundosPorTurno = data?['tiempo_turno'] ?? 15; // Segundos por turno
    segundosRestantesTurno = segundosPorTurno; // Reinicia el temporizador de cuenta atrás

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
      fillPlayerData2vs2(miNombre, data?['puntos_equipo_1'] ?? 0, data?['puntos_equipo_2'] ?? 0); // Llama a la función para llenar los datos del jugador 2vs2
    }else{
      fillPlayerData1vs1(miNombre, data?['puntos_equipo_1'] ?? 0, data?['puntos_equipo_2'] ?? 0); // Llama a la función para llenar los datos del jugador 1vs1
    }

    _listenToWebSocket(); // Escucha los mensajes del WebSocket
    await _loadDecks();
    await _loadTapete();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      fillArguments(); // Llama a la función solo la primera vez
      _isInitialized = true; // Marca como inicializado
    }
  }

  Future<void> _loadDecks () async
  {
    try {
      // Jugador 1
      final eq1 = await getEquippedItems(jugador1Id!);
      final skin1 = (eq1['equipped_skin'] as Map<String, dynamic>?)?['id'] as int?;

      // Jugador 2
      final eq2 = await getEquippedItems(jugador2Id!);
      final skin2 = (eq2['equipped_skin'] as Map<String, dynamic>?)?['id'] as int?;

      // Jugador 3
      int skin3 = 1;
      if (jugador3Id != null)
      {
        final eq3 = await getEquippedItems(jugador3Id!);
        skin3 = (eq3['equipped_skin'] as Map<String, dynamic>?)?['id'] as int? ?? 1;
      }

      // Jugador 4
      int skin4 = 1;
      if (jugador4Id != null)
      {
        final eq4 = await getEquippedItems(jugador4Id!);
        skin4 = (eq4['equipped_skin'] as Map<String, dynamic>?)?['id'] as int? ?? 1;
      }

      setState (() {
        deckSelected1 = (skin1 == 1) ? 'base' : (skin1 == 2) ? 'poker' : (skin1 == 3) ? 'paint' : 'base';
        deckSelected2 = (skin2 == 1) ? 'base' : (skin2 == 2) ? 'poker' : (skin2 == 3) ? 'paint' : 'base';
        deckSelected3 = (skin3 == 1) ? 'base' : (skin3 == 2) ? 'poker' : (skin3 == 3) ? 'paint' : 'base';
        deckSelected4 = (skin4 == 1) ? 'base' : (skin4 == 2) ? 'poker' : (skin4 == 3) ? 'paint' : 'base';
      });
    } catch (e) {
      debugPrint('Error cargando skins: $e');
    }
  }

  Future<void> _loadTapete() async
  {
    final eq = await getEquippedItems(jugador1Id!);
    final tapId = (eq['equipped_tapete'] as Map<String,dynamic>?)?['id'] as int? ?? 1;
    final set = tapeteSets.firstWhere((t) => t.id == tapId, orElse: () => tapeteSets[0]);
    setState(() => tapeteSelected = set.assetPath);
  }

  Scaffold build1vs1(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo principal:
          Positioned.fill(
            child: Image.asset(tapeteSelected, fit: BoxFit.fill, alignment: Alignment.center,), 
          ),

          if (faseArrastre == false) ...[
            // Carta triunfo
            Align(
              alignment: const Alignment(0.3, -0.11),
              child: RotatedBox(
              quarterTurns: 45,
              child: GameCard(card: triunfo, deck: deckSelected1, width: 75),
              ),
            ),
            // Carta del mazo
            Align(
              alignment: const Alignment(0.0, -0.15),
              child: GameCard(card: 'Back', deck: deckSelected1, width: 75),
            ),
          ],

          
          // Carta jugada por el jugador
          jugador1PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.0, 0.25),
                  child: GameCard(card: jugador1PlayedCard, deck: deckSelected1, width: 75),
                )
              : const SizedBox.shrink(),

          
          // Carta jugada por el rival
          jugador2PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.0, -0.55),
                  child: GameCard(card: jugador2PlayedCard, deck: deckSelected2, width: 75),
                )
              : const SizedBox.shrink(),

          // Añadimos mano del jugador
          Align(
            alignment: const Alignment(0.0, 0.77),
            child: buildPlayerHand(context, playerHand, deckSelected1),
          ),

          // Añadimos mano del rival
          Align(
            alignment: const Alignment(1.1, -1.1),
            child: Transform.rotate(
              angle: 90.8,
              child: buildRivalHand(context, rivalHand, deckSelected2),
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
            child: buildPlayerIcon(context, jugador1Nombre.toString(), jugador1FotoUrl, jugador1SolicitaPausa),
          ),
          Align(
            alignment: const Alignment(-0.9, -0.68),
            child: buildPlayerIcon(context, jugador2Nombre.toString(), jugador2FotoUrl, jugador2SolicitaPausa),
          ),

          // Mostrar segundos restantes del turno
          if (mostrarSegundosRestantesTurno)
            Align(
              alignment: const Alignment(0.0, 0.45),
              
              child: Container
              (
                width: 80,
                height: 80,
                
                decoration: BoxDecoration
                (
                  shape: BoxShape.circle,
                  color: AppTheme.blackColor.withAlpha(100),
                  boxShadow: 
                  [
                    BoxShadow
                    (
                      color: Colors.black.withAlpha(150),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack
                (
                  alignment: Alignment.center,
                  children: 
                  [
                    SizedBox
                    (
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator
                      (
                        value: (segundosRestantesTurno / segundosPorTurno),
                        strokeWidth: 8,
                        backgroundColor: AppTheme.blackColor.withAlpha(100),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                    Text.rich
                    (
                      TextSpan
                      (
                        children: 
                        [
                          TextSpan
                          (
                            text: 'Tu turno\n',
                            style: TextStyle
                            (
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          TextSpan
                          (
                            text: '${segundosRestantesTurno}s',
                            style: const TextStyle
                            (
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Scaffold build2vs2(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo principal:
          Positioned.fill(
            child: Image.asset(tapeteSelected, fit: BoxFit.fill, alignment: Alignment.center,), 
          ),

          if (faseArrastre == false) ...[
            // Carta triunfo
            Align(
              alignment: const Alignment(0.0, -0.15),
              child: GameCard(card: triunfo, deck: deckSelected1, width: 75),
            ),
          ],

          
          // Carta jugada por el jugador
          jugador1PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.0, 0.25),
                  child: GameCard(card: jugador1PlayedCard, deck: deckSelected1, width: 75),
                )
              : const SizedBox.shrink(),

          
          // Carta jugada por el jugador
          jugador2PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.0, -0.55),
                  child: GameCard(card: jugador2PlayedCard, deck: deckSelected2, width: 75),
                )
              : const SizedBox.shrink(),

          // Carta jugada por el rival 1
          jugador3PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(-0.55, -0.15),
                  child: GameCard(card: jugador3PlayedCard, deck: deckSelected3, width: 75),
                )
              : const SizedBox.shrink(),
          
          // Carta jugada por el rival 3
          jugador4PlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.55, -0.15),
                  child: GameCard(card: jugador4PlayedCard, deck: deckSelected4, width: 75),
                )
              : const SizedBox.shrink(),

          // Añadimos mano del jugador
          Align(
            alignment: const Alignment(0.0, 0.77),
            child: buildPlayerHand(context, playerHand, deckSelected1),
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
            child: buildPlayerIcon(context, jugador1Nombre.toString(), jugador1FotoUrl, jugador1SolicitaPausa),
          ),
          Align(
            alignment: const Alignment(0.0, -0.90),
            child: buildPlayerIcon(context, jugador2Nombre.toString(), jugador2FotoUrl, jugador2SolicitaPausa),
          ),
          Align(
            alignment: const Alignment(-0.9, -0.50),
            child: buildPlayerIcon(context, jugador3Nombre.toString(), jugador3FotoUrl, jugador3SolicitaPausa),
          ),
          Align(
            alignment: const Alignment(0.9, -0.50),
            child: buildPlayerIcon(context, jugador4Nombre.toString(), jugador4FotoUrl, jugador4SolicitaPausa),
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
  void dispose()
  {
    WidgetsBinding.instance.removeObserver(this);
    cuentaAtrasTurnoTimer.cancel(); // Cancela el temporizador de cuenta atrás
    websocketService?.disconnect(); // Cierra el WebSocket
    super.dispose(); // Libera los recursos del estado.
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // La app ya no está en primer plano: 
      cuentaAtrasTurnoTimer.cancel(); // Cancela el temporizador de cuenta atrás
      websocketService?.disconnect(); // Cierra el WebSocket
    } else if (state == AppLifecycleState.resumed) {
      // La app vuelve a primer plano:
      Navigator.pushReplacementNamed(context, AppRoutes.home); // Redirige a la pantalla de inicio
    }
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

  Widget buildPlayerHand(BuildContext context, List<String> listCards, String deck) {
    const cardWidth = 75.0;
    const cardHeight = 105.0;
    const fanAngleDeg = 45.0; // Ángulo del abanico.
    const overlapCorner = 20.0;
    final cardCount = listCards.length;

    if (cardCount == 0) {
      return const SizedBox(); // Si no hay cartas, no se muestra nada.
    }

    // Abanico para una sola carta.
    if (cardCount == 1) {
      return SizedBox(
        width: cardWidth + 40,
        height: cardHeight + 40,
        child: Center(
          child: CardInFan(
            card: listCards[0],
            deck: deck,
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
              deck: deck,
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

  SizedBox buildRivalHand(BuildContext context, List<String> cardImages, String deck) {
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
              child: GameCard(card: cardImages[i], deck: deck, width: cardWidth),
            ),
        ],
      ),
    );
  }

  ElevatedButton buildSettingsButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () 
      {
        showDialog
        (
          context: context,
          builder: (BuildContext context)
          {
            return GameSettings(exitGameCallback: salirDeLaPartida, pauseGameCallback: pausarPartida, resumeGameCallback: anularPausarPartida,pausaSolicitada: jugador1SolicitaPausa);
          }
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
      onPressed: () 
      {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // Permite que el modal se ajuste al teclado
          backgroundColor: Colors.transparent,
          builder: (_) => SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Ajusta el espacio según el teclado
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8, // Máximo 80% de la altura de la pantalla
                maxWidth: MediaQuery.of(context).size.width * 0.9,  // Máximo 90% del ancho de la pantalla
              ),
              decoration: BoxDecoration(
                color: Colors.white, // Fondo del modal
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20), // Bordes redondeados en la parte superior
                ),
              ),
              child: GameChatModal(
                chatId: chatId!,
                jugadorId: jugador1Id!,
                jugadores: jugadores,
              ),
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(), // Forma circular
        padding: EdgeInsets.all(15), // Espaciado interno aumentado
        backgroundColor: Colors.black, // Color de fondo del botón
      ),
      child: Icon(
        Icons.chat, // Icono de ajustes
        color: Colors.white, // Color del icono
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
              accionCantar();
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
    bool mostrarIconoPausa,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: imagePath != ''
                    ? NetworkImage(imagePath)
                    : const AssetImage('assets/images/default_profile.png') as ImageProvider,
              ),
            ),
            if (mostrarIconoPausa)
              Positioned(
                bottom: 0,
                right: 0,
                child: 
                Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
          ],
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
