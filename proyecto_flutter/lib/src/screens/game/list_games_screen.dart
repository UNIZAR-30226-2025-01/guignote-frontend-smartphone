import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/services/websocket_service.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/routes.dart';
import 'package:sota_caballo_rey/src/widgets/search_lobby.dart';

class ListGamesScreen extends StatefulWidget {
  const ListGamesScreen({super.key});

  @override
  ListGamesScreenState createState() => ListGamesScreenState();
}

class ListGamesScreenState extends State<ListGamesScreen> with SingleTickerProviderStateMixin{

  late TabController _tabController; // Controlador para las pestañas

  // Variables para la pestaña "Unirse"
  Map<String, dynamic>? salas;
  String seleccionFiltro1 = 'Disponibles';
  String seleccionFiltro2 = 'Todas';
  Timer? updateTimer; // Timer para actualizar la lista de partidas
  final WebsocketService websocketService = WebsocketService(); // instancia del servicio de WebSocket

  // Variables para la pestaña "Crear"
  final _formKey = GlobalKey<FormState>(); // clave para el formulario
  int _capacidad = 4; // capacidad de la sala
  int _tiempoturno = 60; // tiempo de turno
  bool _reglasArrastre = true; // reglas de arrastre
  bool _permitirPartidasRevueltas = true; // permitir partidas revueltas
  bool _searching = false; // indica si se está buscando una partida    
  StreamSubscription<Map<String,dynamic>>? subscription; // suscripción al stream de mensajes entrantes
  Map<String, dynamic>? gameData; // datos del juego
  String _statusMessage = ''; // mensaje de estado
  List<Map<String, dynamic>> players = []; // lista de partidas


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    iniciarTimer(); // Inicia el timer para actualizar la lista de partidas cada segundo
  }

  @override
  void dispose() {
    // Cancela el Timer para evitar fugas de memoria
    updateTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void iniciarTimer()
  {
    updateTimer = Timer.periodic(const Duration(seconds: 1), (_)
    {
      if(_tabController.index == 0)
      {
        _loadSalas(); // Carga las salas disponibles cada segundo
      }
    });
  }

  Future<void> _loadSalas() async
  {
    switch(seleccionFiltro1)
    {
      case 'Reconectables':
        salas = await getSalasReconectables();
        break;
      case 'Pausadas':
        salas = await getSalasPausadas();
        break;
      
      case 'Amigos':
        if(seleccionFiltro2 == '2 vs 2')
        {
          salas = await getSalasAmigos(capacidad: 4);
        }
        else if(seleccionFiltro2 == '1 vs 1')
        {
          salas = await getSalasAmigos(capacidad: 2);
        }
        else
        {
          // Si no se ha seleccionado nada, o se ha seleccionado "Todas", obtenemos todas las salas disponibles.
          salas = await getSalasAmigos();
        }
        break;
      
      default:
        if(seleccionFiltro2 == '2 vs 2')
        {
          salas = await getSalasDisponibles(capacidad: 4);
        }
        else if(seleccionFiltro2 == '1 vs 1')
        {
          salas = await getSalasDisponibles(capacidad: 2);
        }
        else
        {
          // Si no se ha seleccionado nada, o se ha seleccionado "Todas", obtenemos todas las salas disponibles.
          salas = await getSalasDisponibles();
        }
        break;
    }
    print(salas);
    setState(() {
    });
  }

  void _cancelSearch()
  {
    setState(() 
    {
      _searching = false; // Cambia el estado a no buscando.

    });

    websocketService.disconnect(); // Desconecta el socket.
    subscription?.cancel(); // Cancela la suscripción al socket.
    subscription = null; // Restablece la suscripción.
    

  }

  Future<void> _createCustomGame() async
  {
    if(!(_formKey.currentState?.validate() ?? false)) return; // Valida el formulario
    
    setState(() 
    {
      _searching = true; // Cambia el estado de búsqueda a verdadero
      _statusMessage = 'Creando partida personalizada...'; // Establece el mensaje de estado
      players.clear(); // Limpia la lista de partidas 
    });

    try
    {
      // Conecta al socket para pedir una partida personalizada
      await websocketService.connectPersonalizada
      (
        capacidad: _capacidad,
        tiempoTurno: _tiempoturno,
        reglasArrastre: _reglasArrastre,
        permitirRevueltas: _permitirPartidasRevueltas,
        soloAmigos: true,
      );

      await subscription?.cancel(); // Cancela la suscripción anterior si existe.
      subscription = websocketService.incomingMessages.listen
      (
        (message) 
        {
          final type = message['type'] as String?;
          final data = message['data'] as Map<String, dynamic>?;

          switch(type)
          {
            case 'player_joined':
            setState(() {
              players.add(data!['usuario']); // Agrega el jugador a la lista de jugadores
              _statusMessage = 'Esperando jugadores: ${players.length}/$_capacidad'; // Actualiza el mensaje de estado
            });
            break;

            case 'start_game':
            setState(() {
              _statusMessage = 'Partida iniciada'; // Actualiza el mensaje de estado
              _searching = false; // Cambia el estado de búsqueda a falso
              gameData = data; // Guarda los datos del juego
            });
            break;

            case 'turn_update':
            setState(() 
            {
             subscription?.cancel(); // Cancela la suscripción al socket
              _searching = false; // Cambia el estado de búsqueda a falso
              _statusMessage = ''; // Restablece el mensaje de estado 
              Navigator.pushReplacementNamed(context, AppRoutes.game, arguments: 
              {
                'gameData': gameData, // Datos del juego
                'firstTurn': data, // Primer turno del juego
                'socket': websocketService, // Socket del juego
              });
            });
            break;

            case 'error':
              ScaffoldMessenger.of(context).showSnackBar
              (
                SnackBar
                (
                  content: Text(data?['message'] ?? 'Error al crear la partida'),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 3),
                ),
              );
          }
        }
      );
  
    }
    catch(e)
    {
      _cancelCreateGame(); // Cancela la creación de la partida
      setState(() {
        _searching = false; // Cambia el estado de búsqueda a falso
        _statusMessage = ''; // Restablece el mensaje de estado
      });
      ScaffoldMessenger.of(context).showSnackBar
      (
        const SnackBar
        (
          content: Text('Error al crear partida'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _cancelCreateGame()
  {
    subscription?.cancel(); // Cancela la suscripción al socket
    subscription = null; // Restablece la suscripción.
    websocketService.disconnect(); // Desconecta el socket
    setState(() {
      _searching = false; // Cambia el estado de búsqueda a falso
      _statusMessage = ''; // Restablece el mensaje de estado
      players.clear(); // Limpia la lista de partidas
    });
  } 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: 
        [
          //Fondo principal con degradado radial.
          const Background(),

          // Ponemos las decoraciones de las esquinas.
          const CornerDecoration(
            imageAsset: 'assets/images/gold_ornaments.png',
          ),

          SafeArea
          (
            child: Column
            (
              children: 
              [
                Padding
                (
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),

                  child: Container
                  (
                    decoration: BoxDecoration
                    (
                      color: AppTheme.blackColor.withAlpha(200),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:TabBar
                    (
                      controller: _tabController,
                      labelPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      labelColor: Colors.amber,
                      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      
                      indicatorColor: Colors.amber,
                      unselectedLabelColor: Colors.white70,
                      unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),

                      dividerColor: Colors.transparent,
                      tabs: const 
                      [
                        Tab(text: "Unirse"),
                        Tab(text: "Crear"),
                      ],
                    ), 
                  ),
                  

                ),
                
                Expanded
                (
                  child: TabBarView
                  (
                    controller: _tabController,
                    children: 
                    [
                      // Pestaña "Unirse"
                      Column
                      (
                        children: 
                        [
                          const SizedBox(height: 12),
                          _buildFiltros(),
                          Expanded(child: _buildListaSalas()),
                        ],
                      ),

                      // Pestaña "Crear"
                      _buildCrearTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Mostramos el prelobby si se está buscando una partida
          if(_searching)...[
            SearchLobby
            (
              statusMessage: "Esperando jugadores...",
              onCancel: _cancelSearch, // Llama a la función de cancelar búsqueda
            ),
          ],
        ],
      ),

      bottomNavigationBar: CustomNavBar(selectedIndex: 3),


    );
  }

  Widget _buildFiltros()
  {
    final opciones1 = ['Disponibles', 'Reconectables', 'Pausadas', 'Amigos'];
    final opciones2 = ['Todas', '1 vs 1', '2 vs 2'];
    return Padding
    (
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column
      (
        children: 
        [
          // Primer grupo de filtros
          Container
          (
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration
            (
              color: AppTheme.blackColor.withAlpha(200),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),  

            child: LayoutBuilder
            (
              builder: (context, constraints)
              {
                final totalPadding = 16.0;
                final baseWidth = (constraints.maxWidth - totalPadding) / opciones1.length ; // Calcula el ancho de cada elemento
                final itemWidth = baseWidth * 1.2;

                return Scrollbar
                (
                  thumbVisibility: true,
                  child: SingleChildScrollView
                  (
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ToggleButtons
                    (
                      isSelected: opciones1.map((opcion) => seleccionFiltro1 == opcion).toList(),
                      onPressed: (index)
                      {
                        setState(() {
                          seleccionFiltro1 = opciones1[index];
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      fillColor: Colors.amber,
                      color: Colors.white,
                      selectedColor: AppTheme.blackColor,

                      constraints: BoxConstraints
                      (
                        minWidth: itemWidth ,
                        maxWidth: itemWidth,
                        minHeight: 36,
                      ),
                      children: opciones1
                        .map((o) => Center(
                              child: Text(o,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                    ),
                  ),
                );
              },
             
            ),
          ),

          const SizedBox(height: 12),
          // Filtros de capacidad

          Container
          (
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration
            (
              color: AppTheme.blackColor.withAlpha(200),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),

            child: LayoutBuilder
            (
              builder: (context, constraints)
              {
                final totalPadding = 16.0;
                final baseWidth = (constraints.maxWidth - totalPadding) / opciones2.length ; // Calcula el ancho de cada elemento
                final itemWidth = baseWidth * 1.2;

                return Scrollbar
                (
                  thumbVisibility: true,
                  child: SingleChildScrollView
                  (
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ToggleButtons
                    (
                      isSelected: opciones2.map((opcion) => seleccionFiltro2 == opcion).toList(),
                      onPressed: (index)
                      {
                        setState(() {
                          seleccionFiltro2 = opciones2[index];
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      fillColor: Colors.amber,
                      color: Colors.white,
                      selectedColor: AppTheme.blackColor,

                      constraints: BoxConstraints
                      (
                        minWidth: itemWidth ,
                        maxWidth: itemWidth,
                        minHeight: 36,
                      ),
                      children: opciones2
                        .map((o) => Center(
                              child: Text(o,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                    ),
                  ),
                );
              }, 
            ),
          ),          
        ],
      ),
    );
  }

  Widget _buildListaSalas() 
  {
    final lista = salas?['salas'] as List? ?? [];
    
    return ListView.builder
    (
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: lista.length,
      itemBuilder: (_, i) 
      {
        final s = lista[i] as Map;
        return Card
        (
          color: AppTheme.blackColor,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile
          (
            contentPadding:  const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            title: Text(s['nombre'], style: const TextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            subtitle: 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${s['num_jugadores']}/${s['capacidad']} jugadores",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text('${(s['jugadores']?.length ?? 0) > 0 ? s['jugadores'][0] : '-'}'),
                  Text('${(s['jugadores']?.length ?? 0) > 1 ? s['jugadores'][1] : '-'}'),
                  if ((s['capacidad'] ?? 0) > 2) 
                  Text('${(s['jugadores']?.length ?? 0) > 2 ? s['jugadores'][2] : '-'}'),
                  if ((s['capacidad'] ?? 0) > 2)
                  Text('${(s['jugadores']?.length ?? 0) > 3 ? s['jugadores'][3] : '-'}'),
                ],
              ),
            

            
            
            trailing: const Icon(Icons.chevron_right, color: Colors.amber),
            onTap: () => joinGame(s['id'] as int, s['capacidad'] as int, seleccionFiltro1 == 'Amigos' ? true : false),
          ),
        );
      },
    );
  }

  Future<void> joinGame(int partidaID, int capacidad, bool soloAmigos) async
  {
    setState(() {
      _searching = true; // Cambia el estado a buscando.
      _statusMessage = 'Esperando jugadores...'; // Establece el mensaje de estado
    });
    try
    {
      // Conecta al socket pidiendo 2 jugadores
      await websocketService.connect(partidaID: partidaID, capacidad: capacidad, soloAmigos: soloAmigos);

      subscription?.cancel(); // Cancela la suscripción anterior si existe.
      subscription = null; // Restablece la suscripción.

      // Escucha los mensajes entrantes del socket
      subscription = websocketService.incomingMessages.listen
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
              players.add(data['jugadores']); // Agrega el jugador a la lista de jugadores
              _statusMessage = 'Esperando jugadores: ${players.length}/$capacidad'; // Actualiza el mensaje de estado
            });
          }

          if (type == 'start_game' && data != null) 
          {
            // Cierra el overlay de carga
            if( Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
            setState(() {
              gameData = data; // Guarda los datos del juego.
              _searching = false;
              _statusMessage = ''; // Restablece el mensaje de estado
              players.clear(); // Limpia la lista de jugadores
            });
          }

          if (type == 'turn_update' && data != null) 
          {
            // Cierra el overlay de carga
            if( Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
            subscription?.cancel(); // Cancela la suscripción al socket en esta pantalla.

            // Navega a la pantalla de juego y pasamos los datos del juego , primer turno y socket
            Navigator.pushReplacementNamed(
              context, 
              AppRoutes.game, 
              arguments: {
                'gameData': gameData, // Datos del juego
                'firstTurn': data, // Primer turno del juego
                'socket': websocketService, // Socket del juego
              });
          }
        }
      );
    } catch (e)
    {
      if(Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
      setState(() {
        
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

  Widget _buildCrearTab()
  {
    return SingleChildScrollView
    (
      padding: const EdgeInsets.all(16),
      child: Container
      (
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration
        (
          color: AppTheme.blackColor.withAlpha(200),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Form
        (
          key: _formKey,
          child: Column
          (
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: 
            [
            
            const Text
            (
              'Crear partida personalizada',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            const Text('Solo se podrán unir amigos a la partida.', style: TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),

            const SizedBox(height: 24),

            const Text
            (
              'Capacidad',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
            ),
              const SizedBox(height: 8),

              ToggleButtons
              (
                isSelected: [_capacidad == 2, _capacidad == 4],
                onPressed: (index)
                {
                  setState(() {
                    _capacidad = index == 0 ? 2 : 4;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                fillColor: Colors.amber,
                color: Colors.white,
                selectedColor: AppTheme.blackColor,
                constraints: const BoxConstraints
                (
                  minWidth: 80,
                  minHeight: 40,
                ),

                children: const 
                [
                  Text('1 vs 1', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('2 vs 2', style: TextStyle(fontWeight: FontWeight.bold)),
                ],

              ),

              const SizedBox(height: 16),

              const Text
              (
                'Tiempo de turno',
                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              ToggleButtons
              (
                isSelected: [_tiempoturno == 15, _tiempoturno == 30, _tiempoturno == 60],
                onPressed: (index)
                {
                  setState(() 
                  {
                    switch(index)
                    {
                      case 0:
                        _tiempoturno = 15;
                        break;
                      case 1:
                        _tiempoturno = 30;
                        break;
                      case 2:
                        _tiempoturno = 60;
                        break;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                fillColor: Colors.amber,
                color: Colors.white,
                selectedColor: AppTheme.blackColor,
                constraints: const BoxConstraints
                (
                  minWidth: 80,
                  minHeight: 40,
                ),

                children: const 
                [
                  Text('15s', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('30s', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('60s', style: TextStyle(fontWeight: FontWeight.bold)),
                ],

              ),

              const SizedBox(height: 24),
              // — Switches personalizados —

              SwitchListTile.adaptive
              (
                title: const Text('Reglas de arrastre', style: TextStyle(color: Colors.white)),
                
                tileColor: AppTheme.blackColor.withAlpha(150),
                
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                
                activeColor: AppTheme.blackColor,
                activeTrackColor: Colors.amber,
                
                contentPadding:const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                
                value: _reglasArrastre,
                onChanged: (v) => setState(() => _reglasArrastre = v),
              
              ),
              
              const SizedBox(height: 8),
              
              SwitchListTile.adaptive
              (
                title: const Text('Permitir partidas revueltas', style: TextStyle(color: Colors.white)),
                tileColor: AppTheme.blackColor.withAlpha(150),
                
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                
                activeColor: AppTheme.blackColor,
                activeTrackColor: Colors.amber,
                
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                value: _permitirPartidasRevueltas,
                onChanged: (v) => setState(() => _permitirPartidasRevueltas = v),
              ),
                            
              const SizedBox(height: 24),

              // — Botón “Crear sala” —
              ElevatedButton
              (
                onPressed: _searching ? null : _createCustomGame,

                style: ElevatedButton.styleFrom
                (
                  backgroundColor: Colors.amber,
                  foregroundColor: AppTheme.blackColor,
                  disabledBackgroundColor: Colors.white10,
                  
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                child: const Text('Crear sala', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
            
          ),
        ),
      ),
    );
  } 
}
