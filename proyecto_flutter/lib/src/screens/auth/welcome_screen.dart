import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';


///
/// Pantalla de bienvenida.
/// 
/// Permite al usuario iniciar sesión o registrarse.
/// 
/// * Rutas de navegación:
///  * **Inicio de sesión**: '/login'
/// * **Registro**: '/register'
/// 
/// * *Parámetros*:
///  * **key**: Llave para identificar el widget.
///
class WelcomeScreen extends StatelessWidget 
{
  // Constructor
  const WelcomeScreen({super.key});

 ///
 /// Construye el contenido de la pantalla.
 /// 
 /// * *context*: Contexto de la aplicación.
 /// 
 /// Devuelve un widget de tipo Scaffold.
 /// 
 @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      backgroundColor: Colors.transparent, // Fondo transparente
      body:Stack // Apilamos los widgets uno encima del otro
      (
        children: 
        [
          // Fondo principal:
          Background(),
                   
          Center // Centramos el contenido
          (
            child: Container // Contenedor principal
            (
              padding: const EdgeInsets.all(20), // Espaciado interno
              decoration: BoxDecoration // Decoración del contenedor
              (
                color: AppTheme.blackColor, // Color negro del tema.
                borderRadius:  BorderRadius.circular(15), 
              ),
              child: Column 
              ( 
                mainAxisSize: MainAxisSize.min, // Para que ocupe solo lo necesario
                mainAxisAlignment: MainAxisAlignment.center, // Para centrar el contenido.
                crossAxisAlignment: CrossAxisAlignment.center, // Para centrar el contenido.
                children:
                [
                  // Título APP
                  CustomTitle(title: 'Sota, Caballo y Rey'),

                  const SizedBox(height: 30), // Espaciado

                  // Logo centrado con espacio superior.
                  Image.asset
                  (
                    'assets/images/app_logo_white.png', // Logo APP.
                    height: 100,
                    cacheWidth: 500,
                    key: Key('logo-image'), // llave de la imagen.
                    
                  ),
                  const SizedBox(height: 30), // Espaciado
                  // Botón para iniciar sesión.
                  CustomButton
                  (
                    key: Key('login-button'), // Llave del botón.
                    // Texto del botón.
                    buttonText: 'Iniciar Sesión',
                    onPressedAction: () => Navigator.pushNamed(context, '/login'), // Navegación a la pantalla de inicio de sesión.
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 20), // Espaciado

                  // Botón para registrarse.
                  CustomButton
                  (
                    key: Key('register-button'), // Llave del botón.
                    // Texto del botón.
                    buttonText: 'Crear Cuenta',
                    onPressedAction: () => Navigator.pushNamed(context, '/register'), // Navegación a la pantalla de registro.
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