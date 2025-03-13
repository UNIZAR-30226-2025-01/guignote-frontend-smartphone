import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart'; 

class RankingScreen extends StatelessWidget 
{  
 
  const RankingScreen({super.key});

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

            Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Column(
              children: [
              Text(
                'Ranking',
                style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              for (int i = 1; i <= 10; i++)
                Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text(
                    'Player $i',
                    style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    ),
                  ),
                  Text(
                    '${100 - i * 5} pts',
                    style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    ),
                  ),
                  ],
                ),
                ),
              ],
            ),
            ),

          // Ponemos las decoraciones de las esquinas.
          const CornerDecoration(
            imageAsset: 'assets/images/gold_ornaments.png',
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 3),
    );
  }
}