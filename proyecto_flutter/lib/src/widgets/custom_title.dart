// lib/widgets/custom_title.dart

/// Widget personalizado que crea un título personalizado.
/// 
/// Parámetros:
///  - 'title': Título a mostrar.
/// 
/// Ejemplo de uso:
/// 
/// ```dart
/// CustomTitle(title: 'Título de la aplicación')
/// ```
/// 
library;

import 'package:flutter/material.dart';

class CustomTitle extends StatelessWidget
{

  final String title; // Título a mostrar.

  // Constructor que inicializa el widget con los valores proporcionados.
  const CustomTitle
  (
    {
      super.key,
      required this.title,
    }
  );

  @override
  Widget build(BuildContext context)
  {
    // Devuelve el widget Text con el título personalizado.
    return Text
    (
      title,
      textAlign: TextAlign.center,
      style: TextStyle
      (
        fontFamily: 'tituloApp',
        fontSize: 32,
        color: Colors.white,
        
      ),
    );
  }

}