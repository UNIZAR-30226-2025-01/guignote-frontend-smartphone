/// Esta es la biblioteca que define los temas de la aplicación, incluyendo colores,
/// estilos de texto y demás propiedades visuales que conviene estandarizar. De esta 
/// forma se asegura una interfaz consistente.
/// 
/// Contiene:
///   - Colores principales y secundarios.
///   - Estilos de texto para títulos y botones.
///   - Propiedades para fondos y botones.
/// 
library;

import 'package:flutter/material.dart';

class AppTheme
{
  static const Color primaryColor = Color(0xFF1F5A1F); // Verde inicial del gradiente.
  static const Color secondaryColor = Color(0xFF0A2A08); // Verde final del gradiente.
  static const Color blackColor = Color(0xFF171718); // Gris oscuro para las cosas en negro.

  // Estilo de texto para los títulos
  static const TextStyle titleTextStyle = TextStyle
  (
    fontSize: 32,
    color: Colors.white,
    fontFamily: 'tituloApp',
  );

  static const Color buttonBackgroundColor = Color(0xFFB0BEC5); // Gris claro para los botones.
  static const Color buttonTextColor = Colors.black; // Negro para el texto de los botones.

  static const TextStyle buttonStyle = TextStyle
  (
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'poppins',
  );
}