

import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';

class BuildGameModeCard extends StatelessWidget
{
  final String title;
  final String assetPath;
  final String description;

  const BuildGameModeCard
  (
    {
      super.key,
      required this.title,
      required this.assetPath,
      required this.description,
    }
  );


  @override
  Widget build(BuildContext context)
  {
    return _buildGameModeCard(title, assetPath, description);
  }
}



Widget _buildGameModeCard(String title, String assetPath, String description)
  {
    return Padding
    (
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack
      (
        children: 
        [
          Container
          (
            decoration: BoxDecoration
            (
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage
              (
                image: AssetImage(assetPath),
                opacity: 0.95,
                scale: 0.95,
              ),
            ),
          ),

          Padding
          (
            padding: const EdgeInsets.all(2.0),
            child: Column
            (
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: 
              [
                Text
                (
                  title, 
                  style: const TextStyle
                  (
                    color: Colors.white, 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    shadows: 
                    [
                      Shadow
                      (
                        offset: Offset(2, 2),
                        blurRadius: 3.0,
                        color: AppTheme.blackColor,
                      )
                    ],
                  )
                ),
                const SizedBox(height: 8),
                Text
                (
                  description,
                  style: TextStyle
                  (
                    fontSize: 16,
                    color: Colors.white70,
                    shadows:
                    [
                      Shadow
                      (
                        offset: Offset(1, 1),
                        blurRadius: 2.0,
                        color: AppTheme.blackColor,
                      ),
                    ]

                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
