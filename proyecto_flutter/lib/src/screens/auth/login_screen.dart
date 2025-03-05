import 'package:flutter/material.dart';
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
class LoginScreen extends StatefulWidget 
{
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> 
{
  final _formKey = GlobalKey<FormState>(); // Clave global para el formulario.
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Llama a la función de login en un hilo separado
      await Future.delayed(Duration.zero, () async 
      {
        await login(id, password);
      });

      if (!mounted) return;

      Navigator.pop(context); // Cierra el indicador de carga

      Navigator.pushNamed(context, '/');
    } catch (e) 
    {
      Navigator.pop(context); 
        
      if(e is ApiException)
      {
        showError(context, e.message);
      }
      else
      {
        showError(context, 'Error desconocido');
      }
    }
  }

  @override
  Widget build(BuildContext context)
   {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
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
  /// Retorna:
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
          color: const Color(0XFF171718),
          borderRadius: BorderRadius.circular(15),
        ),
       
        child: Column
        (
          mainAxisSize: MainAxisSize.min, // Para que ocupe solo lo necesario.
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: 
          [
            // Título APP.
            const CustomTitle(title: 'Iniciar Sesión'),

            const SizedBox(height: 35),

            // Campo rellenable para el nombre de usuario.
            usernameField(),

            const SizedBox(height: 16),

            // Campo rellenable para la contraseña.
            passwordField(),

            const SizedBox(height: 10),

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
                  value: _rememberMe,
                  activeColor: Colors.amber,
                  onChanged: (bool? value) 
                  {
                    setState(() 
                    {
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

            const SizedBox(height: 30),

            // Botón para iniciar sesión.
            CustomButton
            (
              key: const Key('loginButton'),  
              buttonText: 'Iniciar Sesión',
             
              onPressedAction: () async 
              {
                loginAndValidate(_usrController.text, _passwdController.text);            
              },
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            // Botón para registrarse.
            CustomButton
            (
              buttonText: 'Volver',
              onPressedAction: () => Navigator.pushNamed(context, '/'),
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 15),

            // La opción de ir a crear cuenta nueva.
            TextButton
            (
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text(
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
  /// Retorna:
  /// - Un widget `SizedBox` que contiene el campo de texto para la contraseña.
  SizedBox passwordField() 
  {
    return SizedBox
    (
      width: 300,

      child:CustomTextForm
      (
        key: const Key('passwordField'),
        hintText: 'Contraseña',
        prefixIcon: Icons.lock,
        controller: _passwdController,
        obscureText: _hidePasswd,
        validator: (value) => value == null || value.isEmpty ? 'Ingrese su contraseña' : null,
        keyboardType: TextInputType.visiblePassword,
        suffixIcon: IconButton
        (
          icon: Icon
          (
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
  /// Retorna:
  /// - Un widget `SizedBox` que contiene el campo de texto para el nombre de usuario.
  SizedBox usernameField() 
  {
    return SizedBox
    (
      width: 300,
      child:CustomTextForm
      (
        key: const Key('usernameField'),
        hintText: 'Usuario',
        prefixIcon: Icons.person,
        controller: _usrController,
        validator: (value) => value == null || value.isEmpty ? 'Ingrese su nombre de usuario' : null,
        keyboardType: TextInputType.text,
      ),
    );
  }
}