// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

/// Widget personalizado que crea un botón con una acción personalizada.
/// Recibe el texto del botón, el color y la acción que debe ejecutar
/// cuando se presiona el botón.
///
/// Parámetros:
///   - 'buttonText': Texto que irá dentro del botón.
///   - 'onPressedAction': Acción que ejecutará el botón al ser presionado.
///   - color: Color de fondo del botón.
/// 
/// Ejemplo de uso:
/// 
/// ```dart
/// CustomButton
/// (
///  buttonText: 'Iniciar sesión',
/// onPressedAction: () => Navigator.pushNamed(context, '/login'),
/// color: Colors.blue,
/// )
/// ```
/// 

class CustomButton extends StatelessWidget
{

  final String buttonText;
  final VoidCallback onPressedAction;
  final Color color;

  const CustomButton
  ({
    required this.buttonText, 
    required this.onPressedAction,
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
        onPressed: onPressedAction,
        child: Text(buttonText),
      ),
    );
  }
}