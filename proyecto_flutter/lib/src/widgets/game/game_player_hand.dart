import 'package:flutter/material.dart';
import 'game_card.dart';

/// 
/// Widget personalizado que devuelve la mano del jugador.
/// 
/// 
/// Parámetros:
/// 
///   - 'listCards': Lista nombres de las cartas a utilizar
///
///

class GamePlayerHand extends StatelessWidget {
  final List<String> assetPaths;

  GamePlayerHand({
    super.key, 
    required List<String> listCards
  }) : assetPaths = listCards.map((card) => 'assets/images/cards/$card.png').toList();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0.0, 0.7), // Adjust the alignment to move it up
      child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: assetPaths.map((path) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cardPadding = 1 * 2; // Total horizontal padding for each card
        final cardWidth = (screenWidth / 6) - cardPadding;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 1), // Adjust the padding to make the space smaller
          child: GameCard(imageAsset: path, width: cardWidth),
        );
      }).toList(),
      ),
    );
  }
}
