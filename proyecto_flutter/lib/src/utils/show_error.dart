import 'package:flutter/material.dart';

/// Muestra un SnackBar con un mensaje de error.
/// 
/// Parámetros:
/// - `context`: El contexto de la aplicación.
/// - `message`: El mensaje de error a mostrar.

void showError(BuildContext context, String message)
{
  ScaffoldMessenger.of(context).showSnackBar
  (
    SnackBar
    (
      content: Row
      (
        children: 
        [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 10),

          Expanded
          (
            child: Text
            (
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),  
        ],
      ),

      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      
      duration: const Duration(seconds: 4),
    ),
  );
}