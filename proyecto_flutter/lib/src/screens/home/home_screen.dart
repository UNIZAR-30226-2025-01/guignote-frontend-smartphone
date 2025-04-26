import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/widgets/display_settings.dart';
import 'package:sota_caballo_rey/src/widgets/gamemode_card.dart';
import 'package:sota_caballo_rey/src/services/audio_service.dart';
import 'package:sota_caballo_rey/routes.dart';
import 'dart:async';
import 'package:sota_caballo_rey/src/services/websocket_service.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/widgets/search_lobby.dart';


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
  final WebsocketService _websocketService = WebsocketService(); // instancia del servicio de WebSocket
  final PageController _pageController = PageController(); // controlador de página

  bool _searching = false; // variable para controlar si se está buscando una partida
  String _statusMessage = 'Pulsa "Buscar Partida" para comenzar'; // mensaje de estado
  final List <Map<String, dynamic>> _players = []; // lista de jugadores
  StreamSubscription<Map<String,dynamic>>? _subscription; // suscripción al stream de mensajes entrantes
  String? _profileImageUrl; // URL de la imagen de perfil del usuario
  final int _selectedIndex = 2; // índice inicial para la pantalla de inicio 
  Map<String, dynamic>? _gameData; // datos del juego

  @override
  void initState() 
  {
    super.initState(); // Inicializa el estado del widget.
    AudioService().playMenuMusic(); // Reproduce la música del menú.
    _loadProfileImage(); // Carga la imagen de perfil del usuario.
  }

  Future<void> _loadProfileImage() async 
  {
    try
    {
      final url = await getProfileImage();

      if(!mounted) return; // Verifica si el widget está montado antes de actualizar el estado.
      setState(() 
      {
        _profileImageUrl = url; // Actualiza la URL de la imagen de perfil.
      });
    }
    catch(e)
    {
      debugPrint('Error al cargar la imagen de perfil: $e'); // Maneja el error de carga de la imagen.
    }
  }

  Future<void> _searchGame() async
  {
    setState(() 
    {
       _searching = true; // Cambia el estado a buscando.
       _statusMessage = 'Buscando partida...'; // Actualiza el mensaje de estado.
       _players.clear(); // Limpia la lista de jugadores.  
    });

    // Muestra un overlay de carga
    showDialog
    (
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try
    {
      // Conecta al socket pidiendo 2 jugadores
      await _websocketService.connect(capacidad: 4, soloAmigos: false);

      _subscription?.cancel(); // Cancela la suscripción anterior si existe.
      _subscription = null; // Restablece la suscripción.

      // Escucha los mensajes entrantes del socket
      _subscription = _websocketService.incomingMessages.listen
      (
        (message) 
        {
          final type = message['type'] as String?;
          final data = message['data'] as Map<String, dynamic>?;
          print(type); // Imprime el tipo de mensaje recibido.
          print(data); // Imprime los datos del mensaje recibido.

          if (type == 'player_joined' && data != null)
          {
            setState(() {
              _players.add(data['usuario'] as Map<String, dynamic>); // Agrega el jugador a la lista de jugadores.
              _statusMessage = 'Esperando jugadores: ${_players.length}/2'; // Actualiza el mensaje de estado.
            });

            //if(Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
          }

          if (type == 'start_game' && data != null) 
          {
            if( Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.

            setState(() {
              _gameData = data; // Guarda los datos del juego.
              _searching = false; // Cambia el estado a no buscando.
              _statusMessage = 'Partida iniciada'; // Actualiza el mensaje de estado. 
            });
          }

          if (type == 'turn_update' && data != null) 
          {
            // Cierra el overlay de carga
            if( Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
            _subscription?.cancel(); // Cancela la suscripción al socket en esta pantalla.

            // Navega a la pantalla de juego y pasamos los datos del juego , primer turno y socket
            Navigator.pushReplacementNamed(
              context, 
              AppRoutes.game, 
              arguments: {
                'gameData': _gameData, // Datos del juego
                'firstTurn': data, // Primer turno del juego
                'socket': _websocketService, // Socket del juego
              });
          }
        }
      );
    } catch (e)
    {
      if(Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
      setState(() {
        _searching = false; // Cambia el estado a no buscando.
        _statusMessage = 'Error al buscar partida'; // Actualiza el mensaje de estado.
      });

      ScaffoldMessenger.of(context).showSnackBar
      (
        const SnackBar
        (
          content: Text('Error al buscar partida'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _cancelSearch()
  {
    setState(() 
    {
      _searching = false; // Cambia el estado a no buscando.
      _statusMessage = 'Pulsa "Buscar Partida" para comenzar'; // Restablece el mensaje de estado.
      _players.clear(); // Limpia la lista de jugadores.
    });

    _websocketService.disconnect(); // Desconecta el socket.
    _subscription?.cancel(); // Cancela la suscripción al socket.
    _subscription = null; // Restablece la suscripción.
    

  }

  @override
  void dispose()
  {
    if(_searching)
    {
      _websocketService.disconnect(); // Desconecta el socket si se está buscando una partida.
      _subscription?.cancel(); // Cancela la suscripción al socket.
    }
    _pageController.dispose(); // Libera el controlador de página.
    super.dispose(); // Libera los recursos del estado.
  }

  @override
  Widget build(BuildContext context) 
  {
    return Stack
    (
      children: 
      [
        AbsorbPointer
        (
          absorbing: _searching, // Bloquea interacciones si se está buscando una partida.

          child: Scaffold
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
                          
                          CustomButton
                          (
                            buttonText: _searching ? 'Buscando...' : 'Buscar Partida',
                            color: Colors.amber,
                            onPressedAction: _searching ? null : () { _searchGame();}, // Llama a la función de búsqueda de partida
                          ),
                          
                        ],
                      ),
                    ),
                  ],
                ),            
              ],
            ),
            bottomNavigationBar: CustomNavBar(selectedIndex: _selectedIndex),
          ),
        ),
        
        // Mostramos el prelobby si se está buscando una partida
        if(_searching)...
        [
          SearchLobby
          (
            statusMessage: _statusMessage,
            players: _players,
            onCancel: _cancelSearch, // Llama a la función de cancelar búsqueda
          ),
        ],
      ],
    );
  }

  Widget profileButton(BuildContext context) 
  {
    return Padding
    (
      padding: const EdgeInsets.only(left: 10.0),
      child: GestureDetector
      (
        onTap: () => Navigator.pushNamed(context, AppRoutes.profile), // Navega a la pantalla de perfil
        child: CircleAvatar
        (
          radius: 20,
          backgroundColor: Colors.transparent,
          backgroundImage: _profileImageUrl != null
              ? NetworkImage(_profileImageUrl!)
              : const AssetImage('assets/images/default_profile.png') as ImageProvider, // Imagen de perfil por defecto
        ),
      ),
    );
  }

}