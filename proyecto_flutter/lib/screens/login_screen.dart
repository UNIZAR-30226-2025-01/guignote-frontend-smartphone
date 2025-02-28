import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget 
{
  const LoginScreen({super.key});


    @override
    LoginScreenState createState() => LoginScreenState();

}

class LoginScreenState extends State<LoginScreen>
{
  bool recuerdame = false; // Para la opción de guardar los datos de inicio de sesión.
  bool _ocultarpasswd = true; // La opción típica de ocultar contraseña ******.

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwdController = TextEditingController();

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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:  CrossAxisAlignment.start,
              children:
              [
                Text
                (
                  'Bienvenido de vuelta!',
                  style: GoogleFonts.poppins
                  (
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Nombre de usuario.
                Text
                (
                  'Nombre de usuario',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                TextField
                (
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration
                  (
                    prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                    hintText: 'nombre',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder
                    (
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Contraseña
                Text
                (
                  'Contraseña',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                TextField
                (
                  controller: _passwdController,
                  obscureText: _ocultarpasswd,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration
                  (
                    prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                    suffixIcon: IconButton
                    (
                      icon: Icon
                      (
                        _ocultarpasswd ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blueAccent,
                      ),
                      onPressed: ()
                      {
                        setState(() 
                        {
                          _ocultarpasswd = !_ocultarpasswd;  
                        });
                      },
                    ),
                    hintText: 'hola123',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder
                    (
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Casilla para recordar credenciales y opción de recuperar contraseña.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: recuerdame,
                          onChanged: (value) {
                            setState(() {
                              recuerdame = value!;
                            });
                          },
                        ),
                        Text(
                          'Recuérdame',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {}, // Estético por ahora
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Botón de Iniciar Sesión
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {}, // Acción futura
                    child: Text(
                      'Iniciar Sesión',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Ir a la pantalla de registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta?',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Regístrate aquí',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}