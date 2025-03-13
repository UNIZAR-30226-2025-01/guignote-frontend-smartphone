import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart'; 

class HelpScreen extends StatelessWidget 
{  
 
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          //Fondo principal con degradado radial.
          const Background(),

            Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                'Ayuda de la Aplicación',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                'Aquí puedes encontrar información sobre cómo usar la aplicación y resolver problemas comunes.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                onPressed: () {
                  // Acción al presionar el botón
                },
                child: const Text('Más Información'),
                ),
              ],
              ),
            ),
            ),

          // Ponemos las decoraciones de las esquinas.
          const CornerDecoration(
            imageAsset: 'assets/images/gold_ornaments.png',
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 4),
    );
  }
}