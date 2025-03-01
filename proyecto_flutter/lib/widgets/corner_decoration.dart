// corner_decoration.dart

import 'package:flutter/material.dart';

/// Widget personalizado que añade decoraciones en las esquinas de una pantalla.
/// Para ello el widget debe recibir una imagen para añadir como decoración.
/// 
/// El propósito es facilitar la decoración de las esquinas mediante la reutilización
/// del código y asegurando que se mantenga un diseño constante en la aplicación.
/// 
/// Parámetros:
/// 
///   - 'imageAsset': Ruta de la imagen a utilizar para las decoraciones.
///   - 'imageWidth': Ancho de la imagen a utilizar. Opcional, tendrá un valor predefinido.


class CornerDecoration extends StatelessWidget
{
  final String imageAsset; // Ruta de la imagen.
  final double imageWidth; // Ancho de la imagen.


  // Constructor que inicializa el widget con los valores proporcionados.
  const CornerDecoration
  (
    {
      super.key,
      required this.imageAsset,
      this.imageWidth = 100,
    }
  );

  @override
  Widget build(BuildContext context)
  {
    // Devuelve el widget Stack que contiene las imágenes en las esquinas
    return Stack
    (
      children: 
      [
        Positioned(top:0, left:0, child: Image.asset(imageAsset, width: imageWidth,)),
        Positioned(top:0, right: 0, child: Transform.flip
          (
          flipX: true,
          child: Image.asset(imageAsset, width: imageWidth),
        )),
        Positioned(bottom:0, left: 0, child: Transform.flip
        (
          flipY: true,
          child: Image.asset(imageAsset, width: imageWidth),
        )),
        Positioned(bottom:0, right: 0, child: Transform.flip
        (
          flipY: true,
          flipX: true,
          child: Image.asset(imageAsset, width: imageWidth),
        )),      
      ],
    );
  }
}