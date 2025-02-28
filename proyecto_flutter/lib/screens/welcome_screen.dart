import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget 
{
  const WelcomeScreen({super.key});

  
 @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      backgroundColor: Colors.transparent,
      body:SafeArea
      (
        child:Container
        (
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration
          (
            gradient: RadialGradient
            (
              colors: [Color(0XAA1F5A1F),Color(0XAA0A2A08)],
              center: Alignment.center,
              radius: 1.8,
              stops: [0.5, 1.0],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30), // Espaciado general
          
          child: Container
          (
            height: 30,
            decoration: BoxDecoration
            (
              color: Color(0XFF171718),
            ),
            child: Column
            ( 
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:
              [
                // Título APP
                Text
                (
                  'Sota, Caballo y Rey',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins
                  (
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                // Logo centrado con espacio superior.
                Image.asset
                (
                  'assets/app_logo_white.png', // Logo APP.
                  height: 100,
                  cacheWidth: 500,
                  
                ),
                const SizedBox(height: 30),
                // Botón para iniciar sesión.
                _buildButton(context, 'Iniciar Sesión', '/login'),
                const SizedBox(height: 20),

                // Botón para registrarse.
                _buildButton(context, 'Registrarse', '/register'),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // Para construir los botones de manera uniforme.
  Widget _buildButton(BuildContext contexto, String texto, String ruta)
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
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

          textStyle: GoogleFonts.poppins
          (
            fontSize: 18,
            fontWeight:  FontWeight.w600,
          ),
        ),
        onPressed: () => Navigator.pushNamed(contexto, ruta),
        child: Text(texto),
      ),
    );
  }
}