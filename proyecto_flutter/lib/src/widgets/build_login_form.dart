// lib/src/widgets/build_login_form.dart


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

    
    );
  }
}