import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/widgets/display_settings.dart';


/// HomeScreen
///
/// Pantalla de inicio de la aplicación
/// 
/// Muestra las opciones de juego disponibles
/// 
/// * Permite al usuario seleccionar el modo de juego
/// 
/// * Permite al usuario acceder a la configuración de la aplicación
/// 
/// * Permite al usuario acceder a su perfil
/// 
/// * Permite al usuario acceder a la pantalla de juego
/// 
/// * Permite al usuario acceder a la pantalla de amigos
/// 
/// * Permite al usuario acceder a la pantalla de estadísticas
/// 
/// * Permite al usuario acceder a la pantalla de ajustes
/// 
/// * Permite al usuario acceder a la pantalla de ayuda
/// 
class HomeScreen extends StatefulWidget 
{
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}


/// HomeScreenState
/// 
/// Estado de la pantalla de inicio
/// 
class HomeScreenState extends State<HomeScreen> 
{
  final String? profileImageUrl = 'https://www.pngkey.com/png/full/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png';
  int _selectedIndex = 2; // índice inicial para la pantalla de inicio 
  double _volume = 0.5; // initial volume value

  final _pageController = PageController(); // controlador de página

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      extendBodyBehindAppBar: true, // extender el fondo detrás de la barra de aplicaciones
      backgroundColor: Colors.transparent, // fondo transparente
      appBar:AppBar // barra de aplicaciones
      (
        backgroundColor: Colors.transparent, 
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row
        (
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: 
          [
            profileButton(context),
            Image.asset('assets/images/app_logo_white.png', width: 60, height: 60),
            DisplaySettings
            (
              volume: _volume,
              onVolumeChanged: (value) 
              {
                setState(() 
                {
                  _volume = value;
                });
              },
            ),
          ],
        ),
      ),
      body: Stack
      (
        children:
        [
          const Background(),
          const CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),
          
          Column
          (
            children: 
            [
              const SizedBox(height: 20),
              Expanded
              (
                child: Column
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                   [

                    SizedBox
                    (
                      height: 500,
                      child:  PageView
                      (
                        controller: _pageController,
                        children: 
                        [
                          _buildGameModeCard('Modo 2vs2', 'assets/images/cartasBoton.png', 'Juega en equipos de dos.'),
                          _buildGameModeCard('Modo 1vs1', 'assets/images/cartaBoton.png', 'Desafía a un solo oponente.'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    SmoothPageIndicator
                    (
                      controller: _pageController,
                      count: 2,
                      effect: WormEffect
                      (
                        dotHeight: 10,
                        dotWidth: 10,
                        activeDotColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),
                    
                    _buildPlayButton(),

                    
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: _selectedIndex),
    );
  }

  Widget profileButton(BuildContext context) 
  {
    return Padding
    (
      padding: const EdgeInsets.only(left: 10.0),
      child: GestureDetector
      (
        onTap: () 
        {
          ScaffoldMessenger.of(context).showSnackBar
          (
            const SnackBar
            (
              content: Text('¡Hola!', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: CircleAvatar
        (
          radius: 20,
          backgroundColor: Colors.transparent,
          backgroundImage: profileImageUrl != null
              ? NetworkImage(profileImageUrl!)
              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
          child: profileImageUrl == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  Widget _buildGameModeCard(String title, String assetPath, String description)
  {
    return Padding
    (
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card
      (
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,

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
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                ),
              ),
            ),

            Container
            (
              decoration: BoxDecoration
              (
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient
                (
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Padding
            (
              padding: const EdgeInsets.all(16.0),
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
      ),
    );
  }

  Widget _buildPlayButton()
  {
    return GestureDetector
    (
      key: const Key('play_button'),
      onTap: ()
      {
        ScaffoldMessenger.of(context).showSnackBar
        (
          const SnackBar
          (
            content: Text('¡A jugar!'),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 2),
          ),
        );
      },

      child: AnimatedContainer
      (
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(1.05, 1.05, 1),
        child: CustomButton(buttonText: 'Buscar Partida', onPressedAction: ()
        {
          Navigator.pushNamed(context, '/game');
        }, color: Colors.amber),
      ),
    );
  }
}