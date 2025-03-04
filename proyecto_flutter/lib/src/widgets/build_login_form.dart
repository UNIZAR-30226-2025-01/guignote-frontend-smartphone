// lib/src/widgets/build_login_form.dart

import 'package:sota_caballo_rey/src/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';

class LoginForm extends StatelessWidget
{
  final GlobalKey<FormState> formKey;
  final TextEditingController usrController;
  final TextEditingController passwdController;
  final bool rememberMe;
  final Function(bool) onRememberMeChanged;
  final Function(String, String) onLoginPressed;


  const LoginForm
  (
    {
      super.key,
      required this.formKey,
      required this.usrController,
      required this.passwdController,
      required this.rememberMe,
      required this.onLoginPressed,
      required this.onRememberMeChanged,
    }
  );

  @override
  Widget build(BuildContext context)
  {
    return Container
    (
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration
      (
        color: AppTheme.blackColor,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column
      (
        mainAxisSize: MainAxisSize.min, // Tamaño principal mínimo
        crossAxisAlignment: CrossAxisAlignment.center, // Alineación cruzada al centro
        mainAxisAlignment: MainAxisAlignment.center, // Alineación principal al centro  

        children:
        [
          CustomTitle(title: 'Iniciar Sesión'),
          
          const SizedBox(height: 35),

          // Campo rellenable para el nombre de usuario.
          SizedBox
          (
            width: 300,
            child: TextFormField
            (
              key: const Key('usernameField'),
              controller: usrController,
              decoration: InputDecoration
              (
                hintText: 'Usuario',
                hintStyle: TextStyle(color: Colors.black45),
                prefixIcon: Icon(Icons.person, color: Colors.black45),
                filled: true,
                fillColor: Colors.grey.shade400,
                border: OutlineInputBorder
                (
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Ingrese su nombre de usuario' : null,
              style: TextStyle(color: Colors.black),
            ),
          ),

          const SizedBox(height: 16),

          // Campo rellenable para la contraseña.
          SizedBox
          (),

          const SizedBox(height: 10),
        ] 
      ),

    
    );
  }
}