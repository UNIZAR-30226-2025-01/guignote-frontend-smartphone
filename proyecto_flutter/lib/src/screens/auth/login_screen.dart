import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';
import 'package:sota_caballo_rey/src/utils/show_error.dart';
import 'package:sota_caballo_rey/src/services/exceptions.dart';
import 'package:sota_caballo_rey/src/widgets/custom_textform.dart';

/// Pantalla de inicio de sesión.
///
/// Esta pantalla permite al usuario iniciar sesión proporcionando su nombre de usuario y contraseña.
/// También incluye opciones para recordar al usuario y recuperar la contraseña.
/// 
class LoginScreen extends StatefulWidget 
{
  // Constructor de la clase.
  const LoginScreen({super.key});

  // Crea el estado de la pantalla de inicio de sesión.
  @override
  LoginScreenState createState() => LoginScreenState();
}

/// Estado de la pantalla de inicio de sesión.
/// 
/// Este estado contiene la lógica de la pantalla de inicio de sesión.
/// Incluye la validación de los campos de usuario y contraseña, así como la lógica para iniciar sesión.
/// 
class LoginScreenState extends State<LoginScreen> 
{
  //final _formKey = GlobalKey<FormState>(); // Clave global para el formulario.
  final _usrController = TextEditingController(); // Controlador para el campo de usuario.
  final _passwdController = TextEditingController(); // Controlador para el campo de contraseña.
  bool _rememberMe = false; // Estado para la opción de recordar al usuario.
  bool _hidePasswd = true; // Estado para ocultar/mostrar la contraseña.

  /// Inicia sesión y valida las credenciales del usuario.
  ///
  /// Parámetros:
  /// - `id`: El nombre de usuario.
  /// - `password`: La contraseña.
  ///
  /// 
  void loginAndValidate(String id, String password) async 
  {
    try 
    {
      // Muestra un indicador de carga antes de la petición
      showDialog
      (
        context: context, // Contexto de la aplicación
        barrierDismissible: false, // No se puede cerrar con el botón de atrás
        builder: (context) => const Center(child: CircularProgressIndicator()), // Indicador de carga
      );

      // Llama a la función de login en un hilo separado
      await Future.delayed(Duration.zero, () async 
      {
        await login(id, password);
      });

      // Si la pantalla no está montada, no se puede navegar
      if (!mounted) return;

      Navigator.pop(context); // Cierra el indicador de carga

      Navigator.pushNamed(context, '/home'); // Navega a la pantalla de inicio.
    } catch (e) 
    {
      // Si hay un error, cierra el indicador de carga y muestra un mensaje de error.
      Navigator.pop(context); 
        
      if(e is ApiException)
      {
        // Muestra un mensaje de error si la petición falla.
        showError(context, e.message);
      }
      else
      {
        // Muestra un mensaje de error si hay un error desconocido.
        showError(context, 'Error desconocido');
      }
    }
  }

  /// Construye la pantalla de inicio de sesión.
  /// 
  /// Parámetros:
  /// - `context`: El contexto de la aplicación.
  /// 
  /// Devuelve:
  /// - Un widget `Scaffold` que contiene la pantalla de inicio de sesión.
  ///   
  @override
  Widget build(BuildContext context)
   {
    return Scaffold
    (
      backgroundColor: Colors.transparent, // Fondo transparente.
      body: Stack
      (
        children: [
          // Fondo principal con degradado radial.
          const Background(),
          
          // Cuadro negro con todas las opciones dentro.
          buildLoginForm(context),

          // Por último añadimos las decoraciones de las esquinas.
          const CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),    
        ],
      ),
    );
  }

  /// Construye el formulario de inicio de sesión.
  ///
  /// Parámetros:
  /// - `context`: El contexto de la aplicación.
  ///
  /// Devuelve:
  /// - Un widget `Center` que contiene el formulario de inicio de sesión.
  Center buildLoginForm(BuildContext context) 
  {
    return Center
    (
      child: Container
      (
        padding: const EdgeInsets.all(20), // Espaciado interno.
        
        decoration: BoxDecoration
        (
          color:  AppTheme.blackColor,
          borderRadius: BorderRadius.circular(15),
        ),
       
        child: Column
        (
          mainAxisSize: MainAxisSize.min, // Para que ocupe solo lo necesario.
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: 
          [
            // Título de la pantalla.
            const CustomTitle(title: 'Iniciar Sesión'),

            const SizedBox(height: 35), // Espaciado.

            // Campo rellenable para el nombre de usuario.
            usernameField(),

            const SizedBox(height: 16), // Espaciado.

            // Campo rellenable para la contraseña.
            passwordField(),

            const SizedBox(height: 10), // Espaciado.

            // Opción de recordar contraseña y recuperar contraseña.
            Row
            (
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: 
              [
                // Opción de recuperar contraseña.
                TextButton
                (
                  onPressed: ()
                  {
                    // TODO: Implementar recuperación de contraseña.
                  },
                  child: const Text
                  (
                    'Recuperar contraseña',
                    style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey),
                  ),
                ),
                
                Checkbox
                (
                  // Opción de recordar contraseña.
                  value: _rememberMe,
                  activeColor: Colors.amber,
                  onChanged: (bool? value) 
                  {
                    setState(() 
                    {
                      // Cambia el estado de recordar contraseña.
                      _rememberMe = value!;
                    });
                  },
                ),
                
                const Text
                (
                  'Recuerdame',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 30), // Espaciado.

            // Botón para iniciar sesión.
            CustomButton
            (
              key: const Key('loginButton'),  // Clave del botón.
              buttonText: 'Iniciar Sesión', // Texto del botón.
             
              onPressedAction: () async 
              {
                // Valida el formulario.
                loginAndValidate(_usrController.text, _passwdController.text);            
              },
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20), // Espaciado.

            // Botón para Volver.
            CustomButton
            (
              key: const Key('backButton'), // Clave del botón
              buttonText: 'Volver', // Texto del botón
              onPressedAction: () => Navigator.pushNamed(context, '/'), // Navega a la pantalla de bienvenida.
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 15), // Espaciado.

            // La opción de ir a crear cuenta nueva.
            TextButton
            (
              key: const Key('registerButton'), // Clave del botón
              onPressed: () => Navigator.pushNamed(context, '/register'), // Navega a la pantalla de registro.
              child: const Text
              (
                // Texto del botón.
                '¿Aún no tienes cuenta? Crear una cuenta',
                style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el campo de texto para la contraseña.
  ///
  /// Devuelve:
  /// - Un widget `SizedBox` que contiene el campo de texto para la contraseña.
  SizedBox passwordField() 
  {
    // Devuelve un campo de texto personalizado.
    return SizedBox
    (
      width: 300, // Ancho del campo de texto.

      child:CustomTextForm 
      (
        key: const Key('passwordField'), // Clave del campo de texto.
        hintText: 'Contraseña', // Texto de ayuda.
        prefixIcon: Icons.lock, // Icono del prefijo.
        controller: _passwdController, // Controlador del campo de texto.
        obscureText: _hidePasswd, // Oculta la contraseña.
        validator: (value) => value == null || value.isEmpty ? 'Ingrese su contraseña' : null,
        keyboardType: TextInputType.visiblePassword, // Tipo de teclado.
        suffixIcon: IconButton // Icono de sufijo.
        (
          icon: Icon
          (
            // Icono de visibilidad de la contraseña. Depende de si está oculta o no.
            _hidePasswd ? Icons.visibility_off : Icons.visibility,
            color: Colors.black45,
          ),
          onPressed: () 
          {
            setState(() 
            {
              _hidePasswd = !_hidePasswd; // Cambia el estado de mostrar y ocultar contraseña.
            });
          },
        ),
      ),
  
    );
  }

  /// Construye el campo de texto para el nombre de usuario.
  ///
  /// Devuelve:
  /// - Un widget `SizedBox` que contiene el campo de texto para el nombre de usuario.
  SizedBox usernameField() 
  {
    return SizedBox
    (
      width: 300, // Ancho del campo de texto.
      child:CustomTextForm
      (
        key: const Key('usernameField'), // Clave del campo de texto.
        hintText: 'Usuario', // Texto de ayuda.
        prefixIcon: Icons.person, // Icono del prefijo.
        controller: _usrController, // Controlador del campo de texto.
        validator: (value) => value == null || value.isEmpty ? 'Ingrese su nombre de usuario' : null,
        keyboardType: TextInputType.text,
      ),
    );
  }
}