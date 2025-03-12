import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/game/game_card.dart';
import 'package:sota_caballo_rey/src/widgets/game/game_player_hand.dart';

class GameScreen extends StatelessWidget {

  const GameScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      backgroundColor: Colors.transparent,
      body:Stack
      (
        children:
        [
          // Fondo principal:
          Background(),
                   
          // Añadimos las cartas del juego
          
          GamePlayerHand(listCards: ['2Oros', '3Oros', '4Oros', '5Oros', '6Oros', '7Oros']),

          // Por último añadimos las decoraciones de las esquinas
          CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),    
        ],
      ),
    );
  }
}