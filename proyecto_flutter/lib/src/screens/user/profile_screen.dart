import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/data/skin_sets.dart';
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
  // Esto sirve para el test del boton de logout.
  final Future<void> Function()? onLogout;

  // Esto sirve para poder Generar el FutureBuilder de profileBox en los tests.
  final Future<Map<String, dynamic>> Function() loadStats;

  const ProfileScreen({super.key, this.onLogout, this.loadStats = getUserStatistics});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
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

          // Boton de cierre de sesión
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 40,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF171718)),
              iconSize: 40,
              onPressed: () async {
                // Elimina el token del usuario.
                if (widget.onLogout != null) {
                  await widget.onLogout!(); //Pruebas para el test.
                } else {
                  await StorageService.deleteToken();
                }

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

                // MOCHILA

                // Separador de sección
                buildSectionSeparator(),

                // Titulo mochila.
                const Text('Mochila', style: AppTheme.titleTextStyle),

                // Contenido mochila.
                const SizedBox(height: 30),
                
                
                // Obtenemos el userID antes de mostrar la mochila.
                FutureBuilder<int>(
                  future: getUserIdByUsername(usuario),
                  builder: (ctx, snapId) {
                    if (snapId.connectionState == ConnectionState.waiting)
                    {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapId.hasError)
                    {
                      return Text(
                        "Error al cargar el usuario: ${snapId.error}",
                        style: const TextStyle(color: Colors.white),
                      );
                    }
                    final userId = snapId.data!;
                    return BackPackTabs(userId: userId);
                  },
                )
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

//Widget para la creacion del contenido de la mochila.
class BackPackTabs extends StatefulWidget {
  final int userId;
  const BackPackTabs({super.key, required this.userId});

  @override
  BackpackTabsState createState() => BackpackTabsState();
}

class BackpackTabsState extends State<BackPackTabs> {
  // 0 --> Cartas.
  // 1 --> Tapetes.
  int selectedTab = 0;
  int selectedSetIndex = 0;
  List<int> unlockedSetIds = [];
  int? equippedSetId;
  
  @override
  void initState() 
  {
    super.initState();
    _loadInventory();
  }

  // Obtiene los ids de los sets desbloqueados por el usuario y el equipado.
  Future<void> _loadInventory () async
  {
    // Obtenemos los items desbloqueados.
    final unlockedData = await getUnlockedItems(widget.userId);
    final ids = (unlockedData['unlocked_skins'] as List).map((m) => m['id'] as int).toList();

    // Obtenemos los items equipados.
    final equippedData = await getEquippedItems(widget.userId);
    final equippedSkinIds = equippedData['equipped_skin'] as Map<String,dynamic>?;
    final eqId = equippedSkinIds != null ? equippedSkinIds['id'] as int : null;

    setState(() {
      unlockedSetIds = ids;
      equippedSetId = eqId;
    });
  }

  Future<void> _onSelectSet (int setId) async
  {
    // Si no esta desbloqueada no hacemos nada.
    if (!unlockedSetIds.contains(setId)) return;

    // Equipamos el set.
    await equipSkin (widget.userId, setId);

    // Recargamos unlocked y equipped.
    await _loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabButton(
              iconAsset: 'assets/images/Back.png',
              isSelected: selectedTab == 0,
              onTap: () => setState(() => selectedTab = 0),
              keyBtn: const Key ('tabCartasButton'),
              keyImg: const Key ('tabCartasImage'),
            ),
            
            const SizedBox(width: 20),

            _buildTabButton(
              iconAsset: 'assets/images/tapete.jpg',
              isSelected: selectedTab == 1,
              onTap: () => setState(() => selectedTab = 1),
              keyBtn: const Key ('tabTapetesButton'),
              keyImg: const Key ('tabTapetesImage'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Contenido según la pestaña.
        if (selectedTab == 0)
          _buildSetsGrid()
        else
          _buildTapetesGrid(),
      ],
    );      
  }

  Widget _buildSetsGrid ()
  {
    final availableSets = skinSets.where((s) => unlockedSetIds.contains(s.id));

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      children: availableSets.map((set) {
        final equipped = equippedSetId == set.id;
        
        return GestureDetector(
          onTap: () => _onSelectSet(set.id),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Imagen del dorso de cada set.
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: equipped ? Colors.green : Colors.transparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  set.backAsset, 
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTapetesGrid ()
  {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      children: List.generate(4, (i) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text('Tapete ${i + 1}')),
        ),
      ),
    );
  }

  Widget _buildTabButton ({required String iconAsset, required bool isSelected,required VoidCallback onTap, required Key keyBtn, required Key keyImg,}) 
  {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: keyBtn,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(iconAsset, key: keyImg, width: 50, height: 50),
      ),
    );
  }
}