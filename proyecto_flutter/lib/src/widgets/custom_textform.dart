/// Clase que crea un campo de texto personalizado
/// 
/// Este widget extiende `StatelessWidget`, lo que significa que no mantiene
/// ningún estado mutable. El campo de texto se crea utilizando un `TextFormField` que
/// recibe varios parámetros para personalizar su apariencia y comportamiento.
/// 
/// Los parámetros obligatorios son:
/// - `hintText`: El texto que se muestra como pista en el campo de texto.
/// - `controller`: El controlador del campo de texto.
/// 
/// Los parámetros opcionales son:
/// - `prefixIcon`: El icono que se muestra antes del texto.
/// - `obscureText`: Un booleano que indica si el texto debe ocultarse.
/// - `validator`: Una función que valida el texto introducido.
/// - `keyboardType`: El tipo de teclado que se muestra al hacer foco en el campo de texto.
/// - `suffixIcon`: El icono que se muestra después del texto.
/// 
/// Ejemplo de uso:
/// ```dart
/// CustomTextForm
/// (
///  hintText: 'Introduce tu email',
///   prefixIcon: Icons.email,
///   controller: _emailController,
///   validator: validateEmail,
///  keyboardType: TextInputType.emailAddress,
/// )
/// ```
library;

import 'package:flutter/material.dart';

/// Un widget que proporciona un campo de texto personalizado.
class CustomTextForm extends StatelessWidget
{
  final String hintText; // Texto de pista
  final IconData? prefixIcon; // Icono antes del texto
  final bool obscureText; // Indica si el texto debe ocultarse
  final TextEditingController controller; // Controlador del campo de texto
  final FormFieldValidator<String>? validator; // Función de validación
  final TextInputType keyboardType; // Tipo de teclado
  final Widget? suffixIcon; // Icono después del texto


  const CustomTextForm
  (
    {
      super.key,
      required this.hintText,
      this.prefixIcon,
      required this.controller,
      this.obscureText = false,
      this.validator,
      this.keyboardType = TextInputType.text,
      this.suffixIcon,
    }
  );

  @override
  Widget build(BuildContext context)
  {
    return TextFormField
    (
      key: key,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration
      (
        errorMaxLines: 2,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.grey.shade400,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.black45) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder
        (
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none
        ),
      ),
    );
  }
}