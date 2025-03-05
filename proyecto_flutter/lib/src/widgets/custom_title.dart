// lib/widgets/custom_title.dart


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