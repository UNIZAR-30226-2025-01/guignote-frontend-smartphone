import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/widgets/custom_button.dart';
import 'package:http/http.dart' as http; // Para conectar con backend.
import 'dart:convert'; // Para convertir JSON a Map.

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
  final _passwdController = TextEditingController(); // Controlador para el campo de contraseña
  bool _rememberMe = false; // Estado Para la opción de recuerdame.
  bool _hidePasswd = true; // Estado Para ocultar/mostrar la contraseña.


  void _validateAndLogin()
  {
    if(_formKey.currentState!.validate())
    {
      // Muestra un mensaje temporal indicando el inicio de sesión.
      ScaffoldMessenger.of(context).showSnackBar
      (
        const SnackBar(content: Text('Iniciando sesión')),
      );
    }
  }
  
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
          // Fondo principal con degradado gradial:
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
          
          // Cuadro negro con todas las opciones dentro.
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
                    'Iniciar Sesión',
                    textAlign: TextAlign.center,
                    style: TextStyle
                    (
                      fontFamily: 'tituloApp',
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Campo rellenable para el nombre de usuario.
                  SizedBox
                  (
                    width: 300,
                    child: TextFormField
                    (
                      key: const Key('usernameField'),
                      controller: _usrController,
                      decoration: InputDecoration
                      (
                        hintText: 'Usuario',
                        hintStyle: TextStyle(color: Colors.black45),
                        prefixIcon: Icon(Icons.person, color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey.shade400,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        )
                      ),

                      validator: (value) =>  value == null || value.isEmpty ? 'Ingrese su nombre de usuario' : null,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo rellenable para la contraseña
                  SizedBox
                  (
                    width: 300,
                    child: TextFormField
                    (
                      key: const Key('passwordField'),
                      controller: _passwdController,
                      obscureText: _hidePasswd,
                      decoration: InputDecoration
                      (
                        hintText: 'Contraseña',
                        hintStyle: TextStyle(color: Colors.black45),
                        prefixIcon: Icon(Icons.lock, color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey.shade400,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
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
                      validator: (value) => value == null || value.isEmpty ? 'Ingrese su contraseña' : null,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Opción de recordar contraseña y recuperar contraseña.
                  Row
                  (
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: 
                    [
                      // Opción de recuperar contraseña
                      TextButton
                      (
                        onPressed: ()
                        {
                          // ! BACKEND AQUÍ
                        },
                        child: Text
                        (
                          'Recuperar contraseña',
                          style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey),
                        )
                      ),
                      Checkbox
                      (
                        value: _rememberMe,
                        activeColor: Colors.amber,
                        onChanged: (bool? value)
                        {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                      ),
                      
                      Text
                      ( 
                        'Recuerdame',
                        style: TextStyle(color: Colors.white),
                      ),
                    ]
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
                    buttonText: 'Volver',
                    buttonRoute: '/',
                    color: Colors.grey.shade400,
                  ),
                  
                  const SizedBox(height: 15),

                  // La opción de ir a crear cuenta nueva.
                  TextButton
                  (
                    onPressed: () => Navigator.pushNamed(context,'/register'),
                    
                    child: Text
                    (
                      '¿Aún no tienes cuenta? Crear una cuenta',
                      style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey),
                    )
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