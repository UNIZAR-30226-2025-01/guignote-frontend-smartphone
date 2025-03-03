// lib/widgets/background.dart

import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';

/// Un widget que proporciona un fondo con un gradiente radial.
///
/// Este widget extiende `StatelessWidget`, lo que significa que no mantiene
/// ningún estado mutable. El fondo se crea utilizando un `Container` que
/// ocupa todo el ancho y alto disponibles, y se le aplica una decoración
/// con un `BoxDecoration` que contiene un `RadialGradient`.
///
/// El gradiente radial utiliza dos colores definidos en `AppTheme`:
/// `primaryColor` y `secondaryColor`. El gradiente se centra en el centro
/// del contenedor y tiene un radio de 1.8, con paradas de color en 0.5 y 1.0.
///
/// Ejemplo de uso:
/// ```dart
/// Background()
/// ```
///
/// Este widget se puede utilizar como fondo de una pantalla o de cualquier
/// otro widget que necesite un fondo decorativo.
class Background extends StatelessWidget 
{  
  /// Crea una instancia de [Background].
  ///
  /// La clave opcional `key` se puede proporcionar para identificar este
  /// widget en el árbol de widgets.
  const Background({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Container
    (
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              center: Alignment.center,
              radius: 1.8,
              stops: [0.5, 1.0],
            ),
          ),
        );
  }
}