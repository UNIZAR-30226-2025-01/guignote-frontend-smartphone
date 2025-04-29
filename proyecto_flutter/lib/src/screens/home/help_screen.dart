import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart'; 
import 'package:sota_caballo_rey/src/themes/theme.dart';

class HelpScreen extends StatelessWidget 
{  
 
  const HelpScreen({super.key});

  Widget _buildSection(String title, Widget content)
  {
    return ExpansionTile
    (
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      expansionAnimationStyle: AnimationStyle
      (
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 300),
      ),
      backgroundColor: AppTheme.blackColor.withAlpha(50),
      leading: const Icon(Icons.help, color: Colors.white),
      trailing: const Icon(Icons.arrow_drop_down, color: Colors.white),
      
      children: 
      [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: content,
        ),
      ],
      
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Ayuda', style: AppTheme.titleTextStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true ,
      ),
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack
      (
        children: 
        [
          //Fondo principal con degradado radial.
          const Background(),

          // Ponemos las decoraciones de las esquinas.
          const CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),

          ListView
          (
            padding: const EdgeInsets.symmetric( horizontal: 16, vertical: 20),
            children: 
            [
              // Texto de introducción.
              const Padding
              (
                padding: EdgeInsets.symmetric(vertical: 70),
                child: Text
                (
                  'Bienvenido a la sección de ayuda. Aquí encontrarás toda la información necesaria para jugar al guiñote y usar la aplicación.', 
                  style: TextStyle(color:Colors.white, fontSize: 18, fontStyle: FontStyle.italic), 
                  textAlign: TextAlign.center
                ),
              ),

              _buildSection('Introducción al guiñote', Column
              (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                [
                  Text('El guiñote es un juego de cartas tradicional español que se juega con una baraja española de 40 cartas.', style: AppTheme.dialogBodyStyle),
                  const SizedBox(height: 10),
                  Image.asset('assets/images/Back.png', height: 150, fit: BoxFit.cover),
                ],
              )),

              _buildSection('Reglas básicas', Column
              (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                [
                  Text
                  (
                    //TODO añadir reglas básicas del guiñote.
                    '1. Se juega con una baraja española de cuarenta cartas, dividida en cuatro palos (oros, copas, espadas y bastos).\n'
                    '2. El objetivo es ganar el mayor número de puntos posible.\n'
                    '3. Las cartas tienen un valor diferente según su palo y número.\n',
                    style: AppTheme.dialogBodyStyle,
                    ),
                  const SizedBox(height: 10),


                ],
              )),

              _buildSection('Fases de la partida', Text('Fases de la partida', style: AppTheme.dialogBodyStyle)),

              _buildSection('Controles en la app', Column
              (
                children: 
                [
                  ListTile
                  (
                    leading: const Icon(Icons.touch_app, color: Colors.white),
                    title: const Text('Tocar para seleccionar', style: AppTheme.dialogBodyStyle),
                    subtitle: const Text('Toca una carta para seleccionarla.', style: AppTheme.dialogBodyStyle),
                  ),

                  ListTile
                  (
                    leading: const Icon(Icons.chat, color: Colors.white),
                    title: const Text('Deslizar para cambiar', style: AppTheme.dialogBodyStyle),
                    subtitle: const Text('Desliza una carta para cambiarla.', style: AppTheme.dialogBodyStyle),
                  ),
                ],
              )),
            ],
          ),

        ],
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 4),
    );
  }
}