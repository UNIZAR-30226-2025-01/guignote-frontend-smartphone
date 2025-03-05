import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';

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
          Background(),
                   
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
                  CustomTitle(title: 'Sota, Caballo y Rey'),

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
                    onPressedAction: () => Navigator.pushNamed(context, '/login'),
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 20),

                  // Botón para registrarse.
                  CustomButton
                  (
                    buttonText: 'Crear Cuenta',
                    onPressedAction: () => Navigator.pushNamed(context, '/register'),
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