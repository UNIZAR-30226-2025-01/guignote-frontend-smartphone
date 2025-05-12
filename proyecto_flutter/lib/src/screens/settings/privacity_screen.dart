import 'package:flutter/material.dart';


class PrivacityScreen extends StatelessWidget
{
  const PrivacityScreen({super.key});


  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      resizeToAvoidBottomInset: false,
      appBar: AppBar
      (
        title: const Text('Política de privacidad'),
      ),
      body: const Center
      (
        child: Text('Política de privacidad'),
      ),
    );
  }
}
