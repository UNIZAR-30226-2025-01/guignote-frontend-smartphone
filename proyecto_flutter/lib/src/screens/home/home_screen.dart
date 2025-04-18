import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/widgets/display_settings.dart';
import 'package:sota_caballo_rey/src/widgets/gamemode_card.dart';
import 'package:sota_caballo_rey/src/services/audio_service.dart';
import 'package:sota_caballo_rey/src/services/notifications_service.dart';
import 'package:sota_caballo_rey/routes.dart';


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

  @override
  void initState() 
  {
    super.initState(); // Inicializa el estado del widget.
    AudioService().playMenuMusic(); // Reproduce la música del menú.
  }

  final String? profileImageUrl = 'https://www.pngkey.com/png/full/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png';
  final int _selectedIndex = 2; // índice inicial para la pantalla de inicio 
  final NotificationsService notificacion = NotificationsService(); // instancia del servicio de notificaciones


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
              onVolumeChanged: (value) => AudioService().setGeneralVolume(value),
              onMusicVolumeChanged: (value) => AudioService().setMusicVolume(value),
              onEffectsVolumeChanged: (value) => AudioService().setEffectsVolume(value),
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
                          BuildGameModeCard(title: 'Modo 2vs2', assetPath: 'assets/images/cartasBoton.png', description: 'Juega en equipos de dos.'),
                          BuildGameModeCard(title: 'Modo 1vs1', assetPath: 'assets/images/cartaBoton.png', description: 'Desafía a un solo oponente.'),
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
          notificacion.showNotification
          (
            '¡Hola!',
            'Bienvenido a la pantalla de inicio.',
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
          Navigator.pushNamed(context, AppRoutes.game);
        }, color: Colors.amber),
      ),
    );
  }
}