import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/data/ranks.dart';

/// Widget que muestra una barra vertical de ELO con etiquetas posicionadas proporcionalmente.
class RankProgressBar extends StatelessWidget {
  final int currentElo;
  const RankProgressBar({super.key, required this.currentElo});

  @override
  Widget build(BuildContext context) {
    final double maxElo = ranks.last.minElo.toDouble();
    final double percent = (currentElo / maxElo).clamp(0.0, 1.0);

    return LayoutBuilder(builder: (ctx, cons) {
      final double barHeight = cons.maxHeight;
      const double barWidth = 12.0;
      const double iconSize = 32.0;
      const double gap = 8.0;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Barra de fondo
          Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(barWidth / 2),
            ),
          ),

          // Relleno hasta el ELO
          Positioned(
            bottom: 0,
            child: Container(
              width: barWidth,
              height: barHeight * percent,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(barWidth / 2),
              ),
            ),
          ),

          // Flecha indicando la posición
          Positioned(
            bottom: barHeight * percent - iconSize / 2,
            left: -iconSize - gap,
            child: Icon(
              Icons.arrow_right,
              color: Colors.white,
              size: iconSize,
            ),
          ),

          // Etiquetas posicionadas según su umbral de minElo
          for (var rank in ranks)
            Positioned(
              bottom: barHeight * (rank.minElo / maxElo) - iconSize / 2,
              left: - gap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icono circular del rango
                  ClipOval(
                    child: Image.asset(
                      rank.iconAsset,
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Nombre y umbral
                  SizedBox(
                    width: 100,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rank.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${rank.minElo} ELO',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  )
                ],
              ),
            ),
        ],
      );
    });
  }
}
