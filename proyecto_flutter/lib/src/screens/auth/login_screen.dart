import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/services/storage_service.dart';
import 'package:sota_caballo_rey/src/models/user.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Clave global para el formulario.
  final _usrController = TextEditingController(); // Controlador para el campo de usuario.
  final _passwdController = TextEditingController(); // Controlador para el campo de contraseña
  bool _rememberMe = false; // Estado Para la opción de recuerdame.
  bool _hidePasswd = true; // Estado Para ocultar/mostrar la contraseña.

  Future<String?> loginAndValidate(String id, String password) async {
    try {
      // Llama a la función de login de la API para autenticar al usuario con las credenciales introducidas.
      String? token = await login(id, password);

      if (token != null) {
        // Si el token no es nulo, el inicio de sesión fue exitoso.
        // Guarda el token en el almacenamiento seguro.
        await StorageService.saveToken(token);

        // Creamos una instancia del modelo User con los datos del usuario.
        // TODO: Habría que obtener los datos del usuario de la API, de momento se queda así.
        //final user = User(username: id, email: '', password: password, token: token);

        // Devolvemos el token
        return token;
      } else {
        // En caso de no recibir un token, el inicio de sesión falló
        return null;
      }
    } catch (e) {
      // Capturamos la excepción que devuelve el servicio API.
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo principal con degradado gradial:
          Background(),
          
          // Cuadro negro con todas las opciones dentro.
          buildLoginForm(context),

          // Por último añadimos las decoraciones de las esquinas
          CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),    
        ],
      ),
    );
  }

  Center buildLoginForm(BuildContext context) {
    return Center(
          child: Container(
            padding: const EdgeInsets.all(20), // Espaciado interno
            decoration: BoxDecoration(
              color: Color(0XFF171718),
              borderRadius:  BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Para que ocupe solo lo necesario
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título APP
                CustomTitle(title:  'Iniciar Sesión'),

                const SizedBox(height: 35),

                // Campo rellenable para el nombre de usuario.
                usernameField(),

                const SizedBox(height: 16),

                // Campo rellenable para la contraseña
                passwordField(),

                const SizedBox(height: 10),

                // Opción de recordar contraseña y recuperar contraseña.
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Opción de recuperar contraseña
                    TextButton(
                      onPressed: () {
                        // ! BACKEND AQUÍ
                      },
                      child: Text(
                        'Recuperar contraseña',
                        style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey),
                      )
                    ),
                    Checkbox(
                      value: _rememberMe,
                      activeColor: Colors.amber,
                      onChanged: (bool? value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    
                    Text(
                      'Recuerdame',
                      style: TextStyle(color: Colors.white),
                    ),
                  ]
                ),

                const SizedBox(height: 30),
                // Botón para iniciar sesión.
                CustomButton(
                  buttonText: 'Iniciar Sesión',
                  onPressedAction: () async
                  {
                    if(_formKey.currentState!.validate())
                    {
                      String? token = await loginAndValidate(_usrController.text, _passwdController.text);
                      if(token != null)
                      {
                        // Si el inicio de sesión es exitoso, redirige a la pantalla de bienvenida.
                        Navigator.pushNamed(context,'/');
                      }
                      else
                      {
                        
                      }
                    }
                  },
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 20),

                // Botón para registrarse.
                CustomButton(
                  buttonText: 'Volver',
                  onPressedAction: () => Navigator.pushNamed(context, '/'),
                  color: Colors.grey.shade400,
                ),
                
                const SizedBox(height: 15),

                // La opción de ir a crear cuenta nueva.
                TextButton(
                  onPressed: () => Navigator.pushNamed(context,'/register'),
                  
                  child: Text(
                    '¿Aún no tienes cuenta? Crear una cuenta',
                    style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey),
                  )
                ),
              ],
            ),
          ),
        );
  }

  SizedBox passwordField() {
    return SizedBox(
      width: 300,
      child: TextFormField(
        key: const Key('passwordField'),
        controller: _passwdController,
        obscureText: _hidePasswd,
        decoration: InputDecoration(
          hintText: 'Contraseña',
          hintStyle: TextStyle(color: Colors.black45),
          prefixIcon: Icon(Icons.lock, color: Colors.black),
          filled: true,
          fillColor: Colors.grey.shade400,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _hidePasswd ? Icons.visibility_off : Icons.visibility,
              color: Colors.black45,
            ),
            onPressed: () {
              setState(() {
                _hidePasswd = !_hidePasswd; // Cambia el estado de mostrar y ocultar contraseña.  
              });
            },
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Ingrese su contraseña' : null,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  SizedBox usernameField() {
    return SizedBox(
      width: 300,
      child: TextFormField(
        key: const Key('usernameField'),
        controller: _usrController,
        decoration: InputDecoration(
          hintText: 'Usuario',
          hintStyle: TextStyle(color: Colors.black45),
          prefixIcon: Icon(Icons.person, color: Colors.black),
          filled: true,
          fillColor: Colors.grey.shade400,
          border: OutlineInputBorder
          (
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),

        validator: (value) =>  value == null || value.isEmpty ? 'Ingrese su nombre de usuario' : null,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}