import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';
import 'package:sota_caballo_rey/src/utils/show_error.dart';
import 'package:sota_caballo_rey/src/services/exceptions.dart';
import 'package:sota_caballo_rey/src/widgets/custom_textform.dart';
import 'package:sota_caballo_rey/routes.dart';
import 'package:sota_caballo_rey/src/utils/validator.dart';

/// Pantalla de Crear cuenta.
///
/// Esta pantalla permite al usuario crear una cuenta proporcionando su nombre de usuario, correo y contraseña.

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> 
{
  final _formKey = GlobalKey<FormState>(); // Clave global para el formulario.
  final _usrController =
      TextEditingController(); // Controlador para el campo de usuario.
  final _emailController =
      TextEditingController(); // Controlador para el campo de correo.
  final _passwdController =
      TextEditingController(); // Controlador para el campo de contraseña.
  final _confirmpasswdController =
      TextEditingController(); // Controlador para el campo de confirmar contraseña.
  bool _hidePasswd = true; // Estado para ocultar/mostrar la contraseña.
  bool _hideConfirmPasswd =
      true; // Estado para ocultar/mostrar la confirmación de la contraseña.

  /// Crea y valida la cuenta del usuario.
  ///
  /// Parámetros:
  /// - `username`: El nombre de usuario.
  /// - `email`: El correo del usuario.
  /// - `password`: La contraseña.
  /// - `confirmPassword`: La confirmación de la contraseña.
  ///
  void createAndValidate(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      // Muestra un indicador de carga antes de la petición
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Llama a la función de login en un hilo separado
      await Future.delayed(Duration.zero, () async {
        await register(username, email, password, confirmPassword);
      });

      if (!mounted) return;

      Navigator.pop(context); // Cierra el indicador de carga

      Navigator.pushNamed(context, AppRoutes.home);
    } catch (e) {
      Navigator.pop(context);

      if (e is ApiException) {
        showError(context, e.message);
      } else {
        showError(context, 'Error desconocido');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo principal con degradado radial.
          const Background(),

          // Cuadro negro con todas las opciones dentro.
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  buildRegisterForm(context),
                ],
              ),
            ),
          ),
          // Por último añadimos las decoraciones de las esquinas.
          const CornerDecoration(
            imageAsset: 'assets/images/gold_ornaments.png',
          ),
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
  Center buildRegisterForm(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20), // Espaciado interno.

        decoration: BoxDecoration(
          color: const Color(0XFF171718),
          borderRadius: BorderRadius.circular(15),
        ),

        child: Form
        (
          key: _formKey, // Clave del formulario.
          child: Column
          (
            mainAxisSize: MainAxisSize.min, // Para que ocupe solo lo necesario.
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título de la pantalla.
              const CustomTitle(title: 'Crear cuenta'),
          
              const SizedBox(height: 35),
          
              // Campo rellenable para el nombre de usuario.
              usernameField(),
          
              const SizedBox(height: 16),
          
              // Campo rellenable para el correo.
              emailField(),
          
              const SizedBox(height: 16),
          
              // Campo rellenable para la contraseña.
              passwordField(),
          
              const SizedBox(height: 16),
          
              // Campo rellenable para confirmar la contraseña.
              confirmPasswordField(),
          
              const SizedBox(height: 30),
          
              // Botón para Crear cuenta.
              CustomButton(
                key: const Key('registerButton'),
                buttonText: 'Crear cuenta',
          
                onPressedAction: () async 
                {
                  if(_formKey.currentState?.validate() == false) return;
                  createAndValidate(
                    _usrController.text,
                    _emailController.text,
                    _passwdController.text,
                    _confirmpasswdController.text,
                  );
                },
                color: Colors.grey.shade400,
              ),
          
              const SizedBox(height: 20),
          
              // Botón para volver.
              CustomButton(
                buttonText: 'Volver',
                onPressedAction: () => Navigator.pushNamed(context, AppRoutes.welcome),
                color: Colors.grey.shade400,
              ),
          
              const SizedBox(height: 15),
          
              // La opción de ir a iniciar sesión.
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                child: const Text(
                  '¿Ya tienes cuenta? Inicia sesión',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el campo de texto para la contraseña.
  ///
  /// Retorna:
  /// - Un widget `SizedBox` que contiene el campo de texto para la contraseña.
  SizedBox passwordField() {
    return SizedBox(
      width: 300,

      child: CustomTextForm(
        key: const Key('passwordField'),
        hintText: 'Contraseña',
        prefixIcon: Icons.lock,
        controller: _passwdController,
        obscureText: _hidePasswd,
        validator: (value) => validatePassword(value ?? ''),
        keyboardType: TextInputType.visiblePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _hidePasswd ? Icons.visibility_off : Icons.visibility,
            color: Colors.black45,
          ),
          onPressed: () {
            setState(() {
              _hidePasswd =
                  !_hidePasswd; // Cambia el estado de mostrar y ocultar contraseña.
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
  SizedBox usernameField() {
    return SizedBox(
      width: 300,
      child: CustomTextForm(
        key: const Key('usernameField'),
        hintText: 'Usuario',
        prefixIcon: Icons.person,
        controller: _usrController,
        validator: (value) => validateUsername(value ?? ''),
        keyboardType: TextInputType.text,
      ),
    );
  }

  SizedBox emailField() {
    return SizedBox(
      width: 300,
      child: CustomTextForm(
        key: const Key('emailField'),
        hintText: 'Correo Electrónico',
        prefixIcon: Icons.email,
        controller: _emailController,
        validator: (value) => validateEmail(value ?? ''),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  SizedBox confirmPasswordField() {
    return SizedBox(
      width: 300,
      child: CustomTextForm(
        key: const Key('confirmPasswordField'),
        hintText: 'Confirmar Contraseña',
        prefixIcon: Icons.lock,
        controller: _confirmpasswdController,
        obscureText: _hideConfirmPasswd,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Confirme su contraseña';
          }
          if (value != _passwdController.text) {
            return 'Las contraseñas no coinciden';
          }
          return null;
        },
        keyboardType: TextInputType.visiblePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _hideConfirmPasswd ? Icons.visibility_off : Icons.visibility,
            color: Colors.black45,
          ),
          onPressed: () {
            setState(() {
              _hideConfirmPasswd =
                  !_hideConfirmPasswd; // Cambia el estado de mostrar y ocultar contraseña.
            });
          },
        ),
      ),
    );
  }
}
