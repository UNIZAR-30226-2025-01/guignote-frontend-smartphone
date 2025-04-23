import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/services/storage_service.dart';
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
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final containerHeight = size.height * 0.76;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          //Fondo principal con degradado radial.
          const Background(),

          //Cuadro negro con el perfil y estadisticas dentro.
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 300,
                      maxHeight: containerHeight,
                    ),

                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF171718),
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: buildProfileBox(context, setState),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ponemos las decoraciones de las esquinas.
          const CornerDecoration(
            imageAsset: 'assets/images/gold_ornaments.png',
          ),

          // Boton de cierre de sesión
          Positioned(
            top: 40,
            right: 40,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF171718)),
              iconSize: 40,
              onPressed: () async {
                // Elimina el token del usuario.
                await StorageService.deleteToken();

                // Verifica si el widget sigue montado.
                if (!mounted) return;

                // Navega a la página de login.
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 0),
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
    child: imagenUrl.isNotEmpty
        ? ClipOval(
      child: Image.network(
        imagenUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.person, size: 32, color: Colors.white),
      ),
    )
        : const Icon(Icons.person, size: 32, color: Colors.white),
  );
}

// Construye la caja con la información del perfil, estadisticas y mochila.
Widget buildProfileBox(BuildContext context, Function setState) {
  return FutureBuilder<Map<String, dynamic>>(
    future: getUserStatistics(),
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
                const Text('Perfil', style: AppTheme.titleTextStyle),

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

                    SizedBox(width: 20),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/trophy.png',
                          width: 24,
                          height: 24,
                        ),

                        const SizedBox(width: 5),
                        Text(
                          elo.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'poppins',
                          ),
                        ),
                      ],
                    ),
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
                    buildStatItem(
                      "Nº Victorias",
                      victorias.toString(),
                      "assets/images/victory.png",
                    ),
                    buildStatItem(
                      "Nº Derrotas",
                      derrotas.toString(),
                      "assets/images/loss.png",
                    ),
                  ],
                ),

                // Segunda fila.
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildStatItem(
                      "Win/Loss",
                      winLoss.toString(),
                      "assets/images/laurel.png",
                    ),
                    buildStatItem(
                      "Partidas",
                      partidas.toString(),
                      "assets/images/laurel.png",
                    ),
                  ],
                ),

                // Tercera fila.
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildStatItem(
                      "Racha",
                      racha.toString(),
                      "assets/images/star.png",
                    ),
                    buildStatItem(
                      "Racha max",
                      rachaMax.toString(),
                      "assets/images/star.png",
                    ),
                  ],
                ),

                // Cuarta fila.
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildStatItem(
                      "ELO 1vs1",
                      elo.toString(),
                      "assets/images/trophy.png",
                    ),
                    buildStatItem(
                      "ELO 2vs2",
                      eloParejas.toString(),
                      "assets/images/trophy.png",
                    ),
                  ],
                ),

                // MOCHILA

                // Separador de sección
                buildSectionSeparator(),

                // Titulo mochila.
                const Text('Mochila', style: AppTheme.titleTextStyle),

                // Contenido mochila.
                const SizedBox(height: 30),
                const BackPackTabs(),
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
        width: 80,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageAsset, width: 24, height: 24),

            const SizedBox(width: 5),
            Text(
              statValue,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
                color: Colors.black,
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

//Widget para la creacion del contenido de la mochila.
class BackPackTabs extends StatefulWidget {
  const BackPackTabs({super.key});

  @override
  BackpackTabsState createState() => BackpackTabsState();
}

class BackpackTabsState extends State<BackPackTabs> {
  // 0 --> Cartas.
  // 1 --> Tapetes.
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      //Fila con los botones de cada categoria.
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Boton de cartas.
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = 0;
                });
              },

              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedTab == 0 ? Colors.white : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/Back.png', //URL CARTAS
                  width: 50,
                  height: 50,
                ),
              ),
            ),

            const SizedBox(width: 20),

            //Boton de tapetes.
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = 1;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedTab == 1 ? Colors.white : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/tapete.jpg', //URL TAPETES
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          ],
        ),

        //Muestra la coleccion de skins segun la categoría seleccionada.
        selectedTab == 0
            ? buildGridContent("cartas")
            : buildGridContent("tapetes"),
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
}
