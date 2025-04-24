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
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/widgets/search_lobby.dart';
import 'package:sota_caballo_rey/src/services/search_game_service.dart';
import 'package:sota_caballo_rey/src/utils/show_error.dart';


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
  final SearchGameService _searchGameService = SearchGameService(); // servicio para buscar partidas
  final PageController _pageController = PageController(); // controlador de página
  bool _searching = false; // variable para controlar si se está buscando una partida
  String _statusMessage = 'Pulsa "Buscar Partida" para comenzar'; // mensaje de estado
  final List <Map<String, dynamic>> _players = []; // lista de jugadores
  StreamSubscription<Map<String,dynamic>>? _subscription; // suscripción al stream de mensajes entrantes
  String? _profileImageUrl; // URL de la imagen de perfil del usuario
  final int _selectedIndex = 2; // índice inicial para la pantalla de inicio 
  int _currentModeIndex = 0; // índice del modo de juego seleccionado
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

    final capacidad = (_currentModeIndex == 0) ? 4 : 2; // Establece la capacidad según el modo de juego seleccionado.
    
    try
    {
      // Conecta al servidor usando el servicio de búsqueda de partidas
      await _searchGameService.connectToGame(capacidad: capacidad, soloAmigos: false); // Conecta al servidor para buscar una partida.

      _subscription?.cancel(); // Cancela la suscripción anterior si existe.
      _subscription = null; // Restablece la suscripción.

      // Escucha los mensajes entrantes del socket
      _subscription = _searchGameService.listenIncomingMessages().listen
      (
        (message) 
        {
          final type = message['type'] as String?; // Obtiene el tipo de mensaje.
          final data = message['data'] as Map<String, dynamic>?; // Obtiene los datos del mensaje.

          if (type == 'player_joined' && data != null) 
          {
            setState(() 
            {
              _players.add(data['usuario'] as Map<String, dynamic>); // Agrega el jugador a la lista de jugadores.
              _statusMessage = 'Esperando jugadores: ${_players.length}/$capacidad'; // Actualiza el mensaje de estado.
            });
          }

          if (type == 'start_game' && data != null) 
          {
            setState(() 
            {
              _gameData = data; // Guarda los datos del juego.
              _searching = false; // Cambia el estado a no buscando.
              _statusMessage = 'Partida iniciada'; // Actualiza el mensaje de estado. 
            });
          }
        },
        onError: (error) => debugPrint('Error en la conexión: $error'), // Maneja errores de conexión.
      );
      (
        (message) 
        {
          final type = message['type'] as String?;
          final data = message['data'] as Map<String, dynamic>?;

          if (type == 'player_joined' && data != null)
          {
            setState(() {
              _players.add(data['usuario'] as Map<String, dynamic>); // Agrega el jugador a la lista de jugadores.
              _statusMessage = 'Esperando jugadores: ${_players.length}/2'; // Actualiza el mensaje de estado.
            });

            if(Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
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

          if(type == 'player_left' && data != null) 
          {
            setState(() 
            {
              _players.removeWhere((player) => player['id'] == data['usuario']['id']); // Elimina el jugador de la lista.
              _statusMessage = 'Esperando jugadores: ${_players.length}/$capacidad'; // Actualiza el mensaje de estado.
            });
          }
        }
      );
    } catch (e)
    {
      setState(() {
        _searching = false; // Cambia el estado a no buscando.
        _statusMessage = 'Error al buscar partida'; // Actualiza el mensaje de estado.
      });

      if(!mounted) return; // Verifica si el widget está montado antes de continuar.

      showError(context, 'Error al buscar partida'); // Muestra un mensaje de error.

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

    // Notifica al servidor que se ha cancelado la búsqueda de partida.
    _searchGameService.sendMessage
    (
      {
        'type': 'cancel_search', // Tipo de mensaje: cancelar búsqueda.
        'data': {}, // Datos vacíos.
      },
    );

    _searchGameService.disconnectFromMatch(); // Desconecta el socket.
    _subscription?.cancel(); // Cancela la suscripción al socket.
    _subscription = null; // Restablece la suscripción.
  }

  Future<void> _showAvailableGames() async
  {
    try
    {
      final games = await _searchGameService.getAvailableGames(); // Obtiene las partidas disponibles.  

      if(!mounted) return; // Verifica si el widget está montado antes de continuar.

      showDialog
      (
        context: context,
        builder: (context) => AlertDialog
        (
          title: const Text('Partidas disponibles'),
          content: ListView.builder
          (
            itemCount: games.length,
            itemBuilder: (context, index) 
            {
              final game = games[index]; // Obtiene la partida actual.
              return ListTile
              (
                title: Text(game['nombre']), // Muestra el nombre de la partida.
                subtitle: Text('Jugadores: ${game['num_jugadores']}/${game['capacidad']}'), // Muestra la cantidad de jugadores.
                onTap: () 
                {
                  _searchGameService.connectToGame(idPartida: int.parse(game['id']), capacidad: game['capacidad']); // Conecta a la partida seleccionada.
                  Navigator.of(context).pop(); // Cierra el diálogo.
                },
              );
            },
          ),
        ),
      );
    }
    catch(e)
    {
      if(!mounted) return; // Verifica si el widget está montado antes de continuar.
      showError(context, 'Error al obtener partidas disponibles'); // Muestra un mensaje de error.
    }
  }

  Future<void> _showReconnectableGames() async
  {
    try
    {
      final games = await _searchGameService.getReconnectableGames(); // Obtiene las partidas reconectables.
      if(!mounted) return; // Verifica si el widget está montado antes de continuar.

      showDialog
      (
        context: context,
        builder: (context) => AlertDialog
        (
          title: const Text('Mis partidas'),
          content: ListView.builder
          (
            itemCount: games.length,
            itemBuilder: (context, index) 
            {
              final game = games[index]; // Obtiene la partida actual.
              return ListTile
              (
                title: Text(game['nombre']), // Muestra el nombre de la partida.
                subtitle: Text('Jugadores: ${game['num_jugadores']}/${game['capacidad']}'), // Muestra la cantidad de jugadores.
                onTap: () 
                {
                  _searchGameService.connectToGame(idPartida: int.parse(game['id']), capacidad: game['capacidad']); // Conecta a la partida seleccionada.
                  Navigator.of(context).pop(); // Cierra el diálogo.
                },
              );
            },
          ),
        ),

      );
    }
    catch(e)
    {
      if(!mounted) return; // Verifica si el widget está montado antes de continuar.
      showError(context, 'Error al obtener partidas reconectables'); // Muestra un mensaje de error.
    }
  }

  @override
  void dispose()
  {
    if(_searching)
    {
      _searchGameService.disconnectFromMatch(); // Desconecta el socket si se está buscando una partida.
      _searching = false; // Cambia el estado a no buscando.
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
                              onPageChanged: (index)
                              {
                                setState(() 
                                {
                                  _currentModeIndex = index; // Actualiza el índice del modo de juego seleccionado.
                                });
                              },
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
                              activeDotColor: Colors.amber,
                            ),
                          ),
          
                          const SizedBox(height: 20),

                          Column
                          (
                            children: 
                            [
                              CustomButton
                              (
                                buttonText: _searching ? 'Buscando...' :  'Partida rápida',
                                color: Colors.amber,
                                onPressedAction: _searching ? null : _searchGame, // Llama a la función de buscar partida.
                              ),

                              const SizedBox(height: 20),
                              Row
                              (
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: 
                                [
                                  Expanded
                                  (
                                    child: CustomButton
                                    (
                                      buttonText: 'Partidas disponibles',
                                      color: Colors.amber,
                                      onPressedAction: _showAvailableGames, // Llama a la función de mostrar partidas disponibles.
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 10),

                                  Expanded
                                  (
                                    child: CustomButton
                                    (
                                      buttonText: 'Mis partidas',
                                      color: Colors.amber,
                                      onPressedAction: _showReconnectableGames, // Llama a la función de mostrar partidas reconectables.
                                    ),
                                  ),
                                ],
                              ),
                            ],
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