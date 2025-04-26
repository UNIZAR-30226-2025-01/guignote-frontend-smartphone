import 'package:flutter/material.dart';

class DataPolicyScreen extends StatelessWidget
{
  const DataPolicyScreen({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      resizeToAvoidBottomInset: false,
      appBar: AppBar
      (
        title: const Text('Política de datos'),
      ),
      body: const Center
      (
        child: Text('Política de datos'),
      ),
    );
  }
}