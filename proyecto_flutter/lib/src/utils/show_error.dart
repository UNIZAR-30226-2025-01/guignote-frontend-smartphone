import 'package:flutter/material.dart';

/// Muestra un SnackBar con un mensaje de error.
/// 
/// Parámetros:
/// - `context`: El contexto de la aplicación.
/// - `message`: El mensaje de error a mostrar.
/// 
/// Ejemplo de uso:
/// 
/// ```dart
/// showError(context, 'Error al iniciar sesión');
/// ```
///

void showError(BuildContext context, String message)
{
  // Muestra un SnackBar con el mensaje de error.
  ScaffoldMessenger.of(context).showSnackBar
  (
    SnackBar
    (
      content: Row
      (
        children: 
        [
          const Icon(Icons.error_outline, color: Colors.white), // Icono de error.
          const SizedBox(width: 10), // Espaciado

          Expanded
          (
            child: Text
            (
              message, // Mensaje de error.
              style: const TextStyle(color: Colors.white),
            ),
          ),  
        ],
      ),

      backgroundColor: Colors.red, // Color de fondo rojo.
      behavior: SnackBarBehavior.floating, // Comportamiento flotante.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Bordes redondeados.
      
      duration: const Duration(seconds: 4), // Duración de 4 segundos.
    ),
  );
}