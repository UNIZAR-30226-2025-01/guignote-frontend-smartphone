import 'package:flutter/material.dart';


class PasswordRecoverScreen extends StatelessWidget
{
  const PasswordRecoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
      ),
      body: Center(
        child: const Text('Pantalla de recuperación de contraseña'),
      ),
    );
  }
}