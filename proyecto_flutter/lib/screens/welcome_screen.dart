import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/widgets/custom_button.dart';

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
                  CustomButton
                  (
                    buttonText: 'Iniciar Sesión',
                    buttonRoute: '/login',
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 20),

                  // Botón para registrarse.
                  CustomButton
                  (
                    buttonText: 'Crear Cuenta',
                    buttonRoute: '/register',
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),

          // Por último añadimos las decoraciones de las esquinas
          CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),    
        ],
      ),
    );
  }
}