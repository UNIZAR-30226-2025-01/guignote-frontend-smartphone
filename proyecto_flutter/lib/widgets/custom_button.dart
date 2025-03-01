// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

/// Widget personalizado que crea un botón de navegación con los parámetros deseados.
/// Debe recibir el texto que se desea dentro del botón, el color del botón y la ruta
/// de navegación.
/// El propósito es facilitar el añadir botones mediante la reutilización
/// del código y asegurando que se mantenga un diseño constante en la aplicación.
/// 
/// Parámetros:
/// 
///   - 'buttonText': Texto que irá dentro del botón.
///   - 'buttonRoute': Ruta a la que navegará el botón.
///   - color: Color del fondo del botón.

class CustomButton extends StatelessWidget
{

  final String buttonText;
  final String buttonRoute;
  final Color color;

  const CustomButton
  ({
    required this.buttonText, 
    required this.buttonRoute,
    required this.color, 
    super.key,
  });

  @override
  Widget build(BuildContext context)
  {
    return SizedBox
    (
      width: 250, // Que ocupe todo el ancho disponible.
      child: ElevatedButton
      (
        style: ElevatedButton.styleFrom
        (
          foregroundColor:  Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

          textStyle: GoogleFonts.poppins
          (
            fontSize: 18,
            fontWeight:  FontWeight.w600,
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, buttonRoute),
        child: Text(buttonText),
      ),
    );
  }
}