import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget 
{
  const WelcomeScreen({super.key});

  @override
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
            gradient: LinearGradient
            (
              colors: [Colors.blue.shade200, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30), // Espaciado general
          child: Column
          (
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:
            [
              // Logo centrado con espacio superior.
              Image.asset
              (
                'assets/logo2.png', // Logo APP.
                height: 120,
                cacheWidth: 500,
              ),
              const SizedBox(height: 40), // Espacio entre logo y título.

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
              const SizedBox(height: 10),

              // Subtítulo 
              Text
              (
                'El Guiñote de siempre, pero mejor que nunca.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins
                (
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 50), // Espacio antes de los botones.

              // Botón para iniciar sesión.
              _buildButton(context, 'Iniciar Sesión', '/login'),
              const SizedBox(height: 20),

              // Botón para registrarse.
              _buildButton(context, 'Registrarse', '/register'),
            ],
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
      width: double.infinity, // Que ocupe todo el ancho disponible.
      child: ElevatedButton
      (
        style: ElevatedButton.styleFrom
        (
          foregroundColor:  Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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