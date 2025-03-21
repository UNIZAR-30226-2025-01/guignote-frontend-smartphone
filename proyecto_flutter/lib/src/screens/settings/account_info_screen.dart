///
///
///
///
library;

import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/models/user.dart';

class AccountInfoScreen extends StatelessWidget
{

  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      backgroundColor: Colors.transparent, // fondo transparente

      body: Stack
      (
        children: 
        [
          Background(), // fondo principal
          CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),    


          Center
          (
            child: Padding
            (
              padding: const EdgeInsets.only(top: 50.0),
              child: Column
              (
                mainAxisAlignment: MainAxisAlignment.start,
                children:
                [
                  CircleAvatar
                  (
                    radius: 50,
                    backgroundImage: const AssetImage('assets/images/default_profile.png'),
              
                  ),

                  const SizedBox(height: 20),
                  const Text
                  (
                    'Nombre de usuario',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
     
    
    );
  }
}