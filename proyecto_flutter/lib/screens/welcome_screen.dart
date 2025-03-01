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
      body:Stack
      (
        children:
        [
          // Fondo principal:
          Container
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
          ),
          
          Center
          (
            child: Container
            (
              padding: const EdgeInsets.all(20), // Espaciado interno
              decoration: BoxDecoration
              (
                color: Color(0XFF171718),
                borderRadius:  BorderRadius.circular(15),
              ),
              child: Column
              ( 
                mainAxisSize: MainAxisSize.min, // Para que ocupe solo lo necesario
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                [
                  // Título APP
                  Text
                  (
                    'SOTA, CABALLO Y REY',
                    textAlign: TextAlign.center,
                    style: TextStyle
                    (
                      fontFamily: 'tituloApp',
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Logo centrado con espacio superior.
                  Image.asset
                  (
                    'assets/images/app_logo_white.png', // Logo APP.
                    height: 100,
                    cacheWidth: 500,
                    key: Key('logo-image'),
                    
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

          // Por último añadimos las decoraciones de las esquinas
          Positioned(top:0, left:0, child: Image.asset('assets/images/gold_ornaments.png', width: 100)),
          Positioned(top:0, right: 0, child: Transform.flip
          (
            flipX: true,
            child: Image.asset('assets/images/gold_ornaments.png', width: 100),
          )),
          Positioned(bottom:0, left: 0, child: Transform.flip
          (
            flipY: true,
            child: Image.asset('assets/images/gold_ornaments.png', width: 100),
          )),
          Positioned(bottom:0, right: 0, child: Transform.flip
          (
            flipY: true,
            flipX: true,
            child: Image.asset('assets/images/gold_ornaments.png', width: 100),
          )),          
        ],
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
          backgroundColor: Colors.grey.shade400,
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