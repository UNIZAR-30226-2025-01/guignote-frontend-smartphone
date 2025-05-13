import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/widgets/ranks/rank_progress_bar.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';

class RankScreen extends StatefulWidget
{
  const RankScreen({super.key});

  @override
  RankScreenState createState() => RankScreenState();
}

class RankScreenState extends State<RankScreen> {
  late Future<int> _eloFuture;

  @override
  void initState()
  {
    super.initState();
    _eloFuture = getUserStatistics().then((stats) => stats['elo'] as int);  
  }

  @override
  Widget build(BuildContext context)
  {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 35.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xff171718)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          const Background(),
          const CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),

        // Contenedor negro central.
        Positioned(
          top: topPadding + 60,
          left: 50,
          right: 50,
          bottom: kBottomNavigationBarHeight + 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              color: const Color(0xff171718),
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<int>(
                future: _eloFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                  {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError)
                  {
                    return Center (
                      child: Text(
                        'Error cargando tu ELO',
                        style: TextStyle(color: Colors.redAccent, fontSize: 16),
                      ),
                    );
                  }
                  final elo = snap.data!;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Progresión de rango',
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'poppins'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        //ELO actual.
                        Text(
                          'Tu ELO actual: $elo',
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 18),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 60),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7, 
                            maxHeight: MediaQuery.of(context).size.height * 0.55,
                          ),                                  
                          child: Align(
                            alignment: const Alignment(-0.3, 0),
                            child: RankProgressBar(currentElo: elo),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
         )  
        ],
      )
    );
  }
}