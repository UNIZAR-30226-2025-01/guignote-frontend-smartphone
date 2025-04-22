import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/game/game_card.dart';
import 'package:sota_caballo_rey/src/widgets/game/card_in_fan.dart';
import 'dart:math' as math;

class GameScreen extends StatefulWidget {
  final int partidaID;

  const GameScreen({super.key, required this.partidaID});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double _volume = 0.5;

  String playerName = 'Jugador 1';
  String playerIcon = 'assets/images/app_logo_white.png';
  String rivalName = 'Jugador 2';
  String rivalIcon = 'assets/images/app_logo_white.png';
  String? selectedCard; // null o la carta elegida.

  String triunfo = '1E';
  String rivalPlayedCard = '3C';
  String playerPlayedCard = '2E';
  List<String> playerHand = ['1O', '2O', '3O', '4O', '5O', '6O'];
  List<String> rivalHand = ['Back', 'Back', 'Back', 'Back', 'Back', 'Back'];
  int puntosJugador = 0;
  int puntosRival = 0;
  int turnos = 10;

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
      triunfo = '1C';
    });
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
              child: GameCard(card: triunfo, width: 75),
            ),
          ),
          // Carta del mazo
          Align(
            alignment: const Alignment(0.0, -0.15),
            child: GameCard(card: 'Back', width: 75),
          ),

          // Carta jugada por el jugador
          Align(
            alignment: const Alignment(0.0, 0.25),
            child: GameCard(card: playerPlayedCard, width: 75),
          ),
          // Carta jugada por el rival
          Align(
            alignment: const Alignment(0.0, -0.55),
            child: GameCard(card: rivalPlayedCard, width: 75),
          ),

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
            child: buildPlayerIcon(context, playerName, playerIcon),
          ),
          Align(
            alignment: const Alignment(-0.9, -0.68),
            child: buildPlayerIcon(context, rivalName, rivalIcon),
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
          Text('Turnos:', style: const TextStyle(color: Colors.white)),
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
              child: GameCard(card: cardImages[i], width: cardWidth),
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
            backgroundImage: AssetImage(imagePath),
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
