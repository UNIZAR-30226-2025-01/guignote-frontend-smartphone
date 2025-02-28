import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget 
{
  const RegisterScreen({super.key});


    @override
    RegisterScreenState createState() => RegisterScreenState();

}

class RegisterScreenState extends State<RegisterScreen>
{
  bool _ocultarpasswd = true; // La opción típica de ocultar contraseña ******.
  bool _ocultarconfirmPasswd = true; // Lo mismo para la confirmación.

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwdController = TextEditingController();
  final TextEditingController _confirmPasswdController = TextEditingController();


  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      backgroundColor: Colors.transparent,
      body: SafeArea
      (
        child: Container
        (
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration
          (
            gradient: LinearGradient
            (
              colors: [Colors.blue.shade200, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center
          (
            child: Column
            (
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:  CrossAxisAlignment.start,
              children:
              [
                SizedBox(height:50),
                Text
                (
                  'Crear cuenta',
                  style: GoogleFonts.poppins
                  (
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Campos de entrada.
                _buildTextFieldLabel('Nombre de Usuario'),
                _buildTextField(_usernameController, Icons.person, 'Nombre'),

                const SizedBox(height: 16),

                // Campos de entrada.
                _buildTextFieldLabel('Correo electrónico'),
                _buildTextField(_emailController, Icons.email, 'example@gmail.com'),

                const SizedBox(height: 16),

                



               
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldLabel(String label)
  {
    return Padding
    (
      padding: const EdgeInsets.only
      (
        bottom: 5.0,
      ),
      child: Text
      (
        label,
        style: GoogleFonts.poppins(color: Colors.white),
      ),
    );
  }

  // Widget reutilizable para campos de texto
  Widget _buildTextField(TextEditingController controller, IconData icono, String hintText)
  {
    return TextField
    (
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration
      (
        prefixIcon: Icon(icono, color: Colors.blueAccent),
        hintText: hintText,
        filled: true,
        fillColor:  Colors.white,
        border: OutlineInputBorder
        (
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Wigdet reutilizable para contraseñas.
  Widget _buildPasswordField(TextEditingController controller, bool ocultarTexto, VoidCallback cambiarVisibilidad)
  {
    return TextField
    (
      controller: controller,
      obscureText: ocultarTexto,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration
      (
        prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
        suffixIcon: IconButton
        (
          icon: Icon(ocultarTexto ? Icons.visibility_off: Icons.visibility, color:  Colors.blueAccent),
          onPressed: cambiarVisibilidad,
        ),
        hintText: '*******',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),),
      ),
    );
  }
}