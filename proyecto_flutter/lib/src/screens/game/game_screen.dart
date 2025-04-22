import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/game/game_card.dart';
import 'package:sota_caballo_rey/src/widgets/game/card_in_fan.dart';
import 'package:sota_caballo_rey/src/services/websocket_service.dart';
import 'dart:math' as math;

const String deckSelected = 'base'; // Baraja seleccionada por el jugador.

class GameScreen extends StatefulWidget {

  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isInitialized = false; // Bandera para evitar múltiples ejecuciones
  double _volume = 0.5;

  String? selectedCard; // null o la carta elegida.

  String triunfo = '';

  String rivalPlayedCard = '';
  String playerPlayedCard = '';
  List<String> playerHand = ['1Oros', '2Oros', '3Oros', '4Oros', '5Oros', '6Oros'];
  List<String> rivalHand = ['Back', 'Back', 'Back', 'Back', 'Back', 'Back'];
  int puntosJugador = 0;
  int puntosRival = 0;
  int turnos = 0;

  int? mazoRestante;
  List<dynamic>? misCartas;
  bool? faseArrastre;
  Map<String, dynamic>? cartaTriunfo;
  int? chatId;
  List<dynamic>? jugadores;


  // Separa los datos de los jugadores
  String nombreJugador = '';
  String nombreRival = '';
  String? jugador1Nombre;
  int? jugador1Equipo;
  int? jugador1NumCartas;
  String imagenJugadorUrl = '';

  String? jugador2Nombre;
  int? jugador2Equipo;
  int? jugador2NumCartas;
  String imagenRivalUrl = 'https://picsum.photos/seed/picsum/200/300';


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
      playerPlayedCard = card;
      playerHand.remove(card);
    });
  }

  void cambiarTriunfo() {
    setState(() {
      triunfo = '1Copas';
    });
  }

  // Método para escuchar mensajes del WebSocket
  void _listenToWebSocket(WebsocketService websocketService) {
    websocketService.incomingMessages.listen((message) {
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;

      print(type);
      print(data);
      /*
      if (type == 'player_action' && data != null) {
        // Maneja las acciones del jugador
        print('Acción del jugador: $data');
        // Aquí puedes actualizar el estado o realizar alguna acción
        setState(() {
          // Ejemplo: Actualizar puntos del jugador
          puntosJugador += data['puntos'] ?? 0;
        });
      }

      if (type == 'game_update' && data != null) {
        // Maneja las actualizaciones del juego
        print('Actualización del juego: $data');
        // Aquí puedes actualizar el estado o realizar alguna acción
        setState(() {
          // Ejemplo: Actualizar el turno
          turnos = data['turno'] ?? turnos;
        });
      }*/
    });
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
    final data = arguments?['data'] as Map<String, dynamic>?;
    final websocketService = arguments?['socket'] as WebsocketService?;

    // Extrae los campos del mapa "data"
    mazoRestante = data?['mazo_restante'];
    turnos = mazoRestante!; // Asigna el valor de mazoRestante a turnos
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
  

    faseArrastre = data?['fase_arrastre'];
    cartaTriunfo = data?['carta_triunfo'];
    chatId = data?['chat_id'];
    jugadores = data?['jugadores'];

    // Extrae detalles de la carta triunfo
    
    triunfo = (cartaTriunfo?['valor']?.toString() ?? '') + (cartaTriunfo?['palo']?.toString() ?? '');
    

    if (jugadores?.length != null && jugadores!.length >= 2) {
      final jugador1 = jugadores?[0] as Map<String, dynamic>;
      jugador1Nombre = jugador1['nombre'];
      jugador1Equipo = jugador1['equipo'];
      jugador1NumCartas = jugador1['num_cartas'];

      final jugador2 = jugadores?[1] as Map<String, dynamic>;
      jugador2Nombre = jugador2['nombre'];
      jugador2Equipo = jugador2['equipo'];
      jugador2NumCartas = jugador2['num_cartas'];
    }

  

    try {
      final stats = await getUserStatistics(); // Llama al método para obtener los datos
      if (stats != null) {
        setState(() {
          nombreJugador = stats['nombre'] ?? 'null';
          imagenJugadorUrl = stats["imagen"].toString();
        });
      }
    } catch (error) {
      print("Error al obtener estadísticas del usuario: $error");
    }

    if(nombreJugador == jugador1Nombre) {
      nombreRival = jugador2Nombre.toString();
    } else {
      nombreRival = jugador1Nombre.toString();
    }

    _listenToWebSocket(websocketService!); // Escucha los mensajes del WebSocket
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      fillArguments(); // Llama a la función solo la primera vez
      _isInitialized = true; // Marca como inicializado
    }
  }

  @override
  Widget build(BuildContext context) {


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

          
          // Carta jugada por el jugador
          playerPlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.0, 0.25),
                  child: GameCard(card: playerPlayedCard, deck: deckSelected, width: 75),
                )
              : const SizedBox.shrink(),

          
          // Carta jugada por el rival
          rivalPlayedCard.isNotEmpty
              ? Align(
                  alignment: const Alignment(0.0, -0.55),
                  child: GameCard(card: rivalPlayedCard, deck: deckSelected, width: 75),
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
            child: buildPlayerIcon(context, nombreJugador.toString(), imagenJugadorUrl),
          ),
          Align(
            alignment: const Alignment(-0.9, -0.68),
            child: buildPlayerIcon(context, nombreRival.toString(), imagenRivalUrl),
          ),
        ],
      ),
    );
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
          Text('$turnos', style: const TextStyle(color: Colors.white)),
          Text('Puntos:', style: const TextStyle(color: Colors.white)),
          Text('$puntosJugador', style: const TextStyle(color: Colors.white)),
          Text('Pts. rival:', style: const TextStyle(color: Colors.white)),
          Text('$puntosRival', style: const TextStyle(color: Colors.white)),
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
              backgroundColor: Colors.black,
              content: SizedBox(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ajustes',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Volumen',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Slider(
                      value: _volume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _volume = value;
                        });
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
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
