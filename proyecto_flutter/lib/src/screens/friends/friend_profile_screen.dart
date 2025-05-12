import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/screens/friends/friend_chat.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';

//Pantalla de perfil del usuario.
//
// Esta pantalla le mostrará al usuario la información de su perfil, la informacion de sus estadisticas
// y su mochila con las skins de sus cartas y tapetes.
class FriendProfileScreen extends StatefulWidget {

  // Esto sirve para poder Generar el FutureBuilder de profileBox en los tests.
  final Future<Map<String, dynamic>> Function() loadStats;

  final String friendId;
  final String nombre;

  const FriendProfileScreen({super.key, required this.friendId, required this.nombre, required this.loadStats});


  @override
  FriendProfileScreenState createState() => FriendProfileScreenState();

}





class FriendProfileScreenState extends State<FriendProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          //Fondo principal con degradado radial.
          const Background(),

          //Cuadro negro con el perfil y estadisticas dentro.
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 50,
            right: 50,
            bottom: kBottomNavigationBarHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                color: const Color(0xff171718),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: buildProfileBox(context, setState, widget.loadStats),
                ),
              ),
            ),
          ),

          // Ponemos las decoraciones de las esquinas.
          const CornerDecoration(
            imageAsset: 'assets/images/gold_ornaments.png',
          ),

          //Boton de volver.
          Align(
            alignment: const Alignment(-0.75, -0.9),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Botón circular con el icono del chat.
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 20),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendChat(receptorId: widget.friendId, receptorNom: widget.nombre)),
                  );
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.chat, color: Colors.white),
              ),
            ),
          ),

  
        ],
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 1),
    );
  }
}

// Devuelve widget con imagen de perfil y opción de cambiarla
Widget _buildProfileImage(String imagenUrl, BuildContext context, Function setState) {
  return GestureDetector(
    onTap: () async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        final imagen = File(picked.path);
        try {
          await cambiarImagenPerfil(imagen);
          setState(() {}); // Fuerza recarga para mostrar la nueva imagen
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error al actualizar imagen: $e")),
            );
          }
        }
      }
    },
    child:
      imagenUrl.isNotEmpty
        ? ClipOval(
            child: Image.network(
              imagenUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder:
              (_, __, ___) => const Icon(Icons.person, size: 32, color: Colors.white))
          ) : const Icon(Icons.person, size: 32, color: Colors.white),
  );
}

// Construye la caja con la información del perfil, estadisticas y mochila.
Widget buildProfileBox(BuildContext context, Function setState, Future<Map<String, dynamic>> Function() loadStats) {
  return FutureBuilder<Map<String, dynamic>>(
    future: loadStats(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(
          child: Text(
            "Error: ${snapshot.error}",
            style: const TextStyle(color: Colors.white),
          ),
        );
      } else if (snapshot.hasData) {
        final stats = snapshot.data!;
        int victorias = stats["victorias"];
        int derrotas = stats["derrotas"];
        int partidas = stats["total_partidas"];
        int racha = stats["racha_victorias"];
        int rachaMax = stats["mayor_racha_victorias"];
        String usuario = stats["nombre"];
        String imagenUrl = stats["imagen"].toString();
        double winLoss = stats["porcentaje_victorias"];
        int elo = stats["elo"];
        int eloParejas = stats["elo_parejas"];

        return Center(
          child: Container(
            key: const Key('ProfileBox'),
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
                // PERFIL

                // Titulo del perfil.
                const SizedBox(height: 10),
                const Text('Perfil', style: AppTheme.titleTextStyle, key: Key('profileTitle'),),

                // Foto del usuario.
                const SizedBox(height: 30),
                _buildProfileImage(imagenUrl, context, setState),

                // Nombre del usuario.
                const SizedBox(height: 10),
                Text(
                  usuario,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'poppins',
                  ),
                ),

                // Rango y ELO del usuario.
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/default_portrait.png', // Por el momento no se implementa en el backend.
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Oro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'poppins',
                      ),
                    ), // Por el momento no se implementa en el backend.
                  ],
                ),

                //ESTADISTICAS

                // Separador de sección
                buildSectionSeparator(),

                // Titulo de estadisticas.
                const Text('Estadísticas', style: AppTheme.titleTextStyle),

                // Recuadro de las estadisticas.

                // Primera fila.
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: buildStatItem("Nº Victorias", victorias.toString(), "assets/images/victory.png")),
                    const SizedBox(width: 10),
                    Expanded(child:buildStatItem("Nº Derrotas",  derrotas.toString(),  "assets/images/loss.png")),
                  ],
                ),

                // Segunda fila.
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: buildStatItem("Win/Loss", winLoss.toString(), "assets/images/laurel.png")),
                    const SizedBox(width: 10),
                    Expanded(child: buildStatItem("Partidas", partidas.toString(), "assets/images/laurel.png")),
                  ],
                ),

                // Tercera fila.
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: buildStatItem("Racha", racha.toString(), "assets/images/star.png")),
                    const SizedBox(width: 10),
                    Expanded(child: buildStatItem("Racha max", rachaMax.toString(), "assets/images/star.png")),
                  ],
                ),

                // Cuarta fila.
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded( child: buildStatItem("ELO 1vs1", elo.toString(), "assets/images/trophy.png")),
                    const SizedBox(width: 10),
                    Expanded(child: buildStatItem("ELO 2vs2", eloParejas.toString(), "assets/images/trophy.png"))
                  ],
                ),

              ],
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    },
  );
}

//Widget para rectangulo de estadisticas.
Widget buildStatItem(String statName, String statValue, String imageAsset) {
  return Column(
    children: [
      //Nombre de la estadistica.
      Text(
        statName,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontFamily: 'poppins',
        ),
      ),

      //Recuadro blanco con el valor e imagen al lado.
      const SizedBox(height: 5),
      Container(
        width: double.infinity,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageAsset, width: 24, height: 24),

            const SizedBox(width: 5),
            Flexible(
              child: Text(
                statValue,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

//Widget para crear una linea separadora entre secciones.
Widget buildSectionSeparator() {
  return Column(
    children: const [
      SizedBox(height: 40),
      Divider(color: Colors.white, thickness: 1, indent: 20, endIndent: 20),
      SizedBox(height: 20),
    ],
  );
}

// Método para construir el grid de elementos.
Widget buildGridContent(String tipo) {
  return GridView.count(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    children: List.generate(4, (index) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white),
        ),

        child: Center(
          child: Text(
            tipo == "cartas"
                ? 'skin de Carta ${index + 1}'
                : 'skin de tapete ${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }),
  );
}

