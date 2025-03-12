

import 'package:flutter/material.dart';


/// 
/// Widget personalizado que devuelve una carta de juego.
/// 
/// El proposito es facilitar la creacion de cartas asegurando que 
/// semantenga un diseño constante en la aplicación.
/// 
/// Parámetros:
/// 
///   - 'imageAsset': Ruta de la imagen de la carta a utilizar
///
///
class GameCard extends StatelessWidget
{
  final String imageAsset; // Ruta de la imagen.
  final double width; // Ancho de la carta.


  // Constructor que inicializa el widget con los valores proporcionados.
  const GameCard
    (
      {
        super.key,
        required String card,
        required this.width,
      }
    ) : imageAsset = 'assets/images/cards/$card.png';

  @override
  Widget build(BuildContext context)
  {
    // Devuelve el widget Card
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.asset(
          imageAsset,
          fit: BoxFit.cover,
          width: width, 
        ),
      ),
    );
  }
}