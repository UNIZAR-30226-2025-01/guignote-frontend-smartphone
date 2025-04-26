import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  RankingScreenState createState() => RankingScreenState();
}

class RankingScreenState extends State<RankingScreen> {
  // 0: 1 vs 1, 1: 2 vs 2.
  int selectedMatchType = 0;
  // 0: Global, 1: Amigos.
  int selectedRankingType = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final containerHeight = size.height * 0.76;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          //Fondo principal con degradado radial.
          const Background(),

          // Caja negra central.
          Positioned(
            top: MediaQuery.of(context).padding.top + 25,
            left: 50,
            right: 50,
            bottom: kBottomNavigationBarHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                color: const Color(0xff171718),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: buildRankingContent(context),
                        ),
                      ),
                    );
                  },
                ),
              ),
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

  Widget buildRankingContent(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0XFF171718),
          borderRadius: BorderRadius.circular(15),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titulo del ranking.
            const Text('Rankings', style: AppTheme.titleTextStyle),

            // Filtros tipo de partida.
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Boton 1 vs 1
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedMatchType = 0;
                      });
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedMatchType == 0 ? Colors.blue : Colors.white,
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontFamily: 'poppins'),
                    ),

                    child: const Text('1 vs 1'),
                  ),
                ),

                const SizedBox(width: 20),

                // Boton 2 vs 2
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedMatchType = 1;
                      });
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedMatchType == 1 ? Colors.blue : Colors.white,
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontFamily: 'poppins'),
                    ),

                    child: const Text('2 vs 2'),
                  ),
                ),
              ],
            ),

            // Botones de filtros de Global y Amigos.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Boton Global.
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedRankingType = 0;
                      });
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedRankingType == 0 ? Colors.blue : Colors.white,
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontFamily: 'poppins'),
                    ),

                    child: const Text('Global'),
                  ),
                ),

                const SizedBox(width: 20),

                // Boton Amigos.
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedRankingType = 1;
                      });
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedRankingType == 1 ? Colors.blue : Colors.white,
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontFamily: 'poppins'),
                    ),

                    child: const Text('Amigos'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // LLamamos al FutureBuilder
            FutureBuilder(
              future: getRankingData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                    '${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'poppins',
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    'No hay datos de ranking disponibles.',
                    style: TextStyle(color: Colors.white),
                  );
                } else {
                  final ranking = snapshot.data!;

                  return Column(
                    children:
                        ranking.map((entry) {
                          final nombre = entry["nombre"] ?? "Desconocido";
                          final elo = entry["elo"] ?? "0";
                          return buildRankingEntry(nombre, elo);
                        }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Devuelve el Future con la lista de Map para el ranking.
  Future<List<Map<String, String>>> getRankingData() async {
    // 1 vs 1
    if (selectedMatchType == 0) {
      //Global.
      if (selectedRankingType == 0) {
        return get1vs1GlobalRanking();
      } else {
        return get1vs1FriendsRanking();
      }
    }
    // 2 vs 2
    else {
      if (selectedRankingType == 0) {
        return get2vs2GlobalRanking();
      } else {
        return get2vs2FriendsRanking();
      }
    }
  }

  // Función para crear la entrada de cada usuario en la tabla.
  Widget buildRankingEntry(String name, String elo) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nombre usuario.
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
              color: Colors.black,
            ),
          ),

          // Elo.
          Text(
            elo.toString(),
            style: const TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
