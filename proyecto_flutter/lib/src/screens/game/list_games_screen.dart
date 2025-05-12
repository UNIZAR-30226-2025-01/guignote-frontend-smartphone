import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/services/websocket_service.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/routes.dart';
import 'dart:convert';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';

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
  final _form_key = GlobalKey<FormState>(); // clave para el formulario
  int _capacidad = 4; // capacidad de la sala
  int _tiempoturno = 60; // tiempo de turno
  bool _reglasArrastre = true; // reglas de arrastre
  bool _permitirPartidasRevueltas = true; // permitir partidas revueltas
  bool _soloAmigos = false; // solo amigos    
  StreamSubscription<Map<String,dynamic>>? subscription; // suscripción al stream de mensajes entrantes
  Map<String, dynamic>? gameData; // datos del juego


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
        salas = await getSalasAmigos(capacidad: seleccionFiltro2 == '2 vs 2' ? 4 : null);
        break;
      
      default:
        salas = await getSalasDisponibles(capacidad: seleccionFiltro2 == '2 vs 2' ? 4 : null);
        break;
    }
    setState(() {
    });
  }

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
                      SingleChildScrollView
                      (
                        padding:  const EdgeInsets.all(16),
                        child: Form
                        (
                          key: _form_key,
                          child: Column
                          (
                            children: 
                            [
                              DropdownButtonFormField<int>
                              (
                                value: _capacidad,
                                decoration: const InputDecoration(labelText: 'Capacidad'),
                                items: [2, 4].map((n) => DropdownMenuItem(value: n, child: Text("$n"))).toList(),
                                onChanged: (value) => setState(() => _capacidad = value!),
                              ),

                              TextFormField
                              (
                                initialValue: "$_tiempoturno",
                                decoration: const InputDecoration(labelText: 'Tiempo de turno (segundos)'),
                                keyboardType: TextInputType.number,
                                validator: (value) => int.tryParse(value ?? "") == null ? 'Introduce un número' : null,
                                onChanged: (value) => setState(() => _tiempoturno = int.tryParse(value) ?? _tiempoturno),
                              ),

                              SwitchListTile.adaptive
                              (
                                title: const Text('Reglas de arrastre'),
                                value: _reglasArrastre,
                                onChanged: (value) => setState(() => _reglasArrastre = value),
                              ),
                              SwitchListTile.adaptive
                              (
                                title: const Text('Permitir partidas revueltas'),
                                value: _permitirPartidasRevueltas,
                                onChanged: (value) => setState(() => _permitirPartidasRevueltas = value),
                              ),
                              SwitchListTile.adaptive
                              (
                                title: const Text('Solo amigos'),
                                value: _soloAmigos,
                                onChanged: (value) => setState(() => _soloAmigos = value),
                              ),
                              const SizedBox(height: 24),
                              CustomButton(buttonText: "Crear sala", onPressedAction: null , color: Colors.amber),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            subtitle: Text
            (
              "${s['num_jugadores']}/${s['capacidad']} jugadores",
              style: const TextStyle(color: Colors.white70),
            ),
            
            trailing: const Icon(Icons.chevron_right, color: Colors.amber),
            // onTap: () => _unirse(s['id'] as int),
          ),
        );
      },
    );
  }

  Future<void> joinGame(int partidaID) async
  {

    try
    {
      // Conecta al socket pidiendo 2 jugadores
      await websocketService.connect(partidaID: partidaID);

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

            //if(Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
          }

          if (type == 'start_game' && data != null) 
          {
            // Cierra el overlay de carga
            if( Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra el diálogo de carga.
            setState(() {
              gameData = data; // Guarda los datos del juego.
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
}

Widget _buildCrearTab()
{
  return SingleChildScrollView
  (
    padding: const EdgeInsets.all(16),
    child: Container
    (
      
    ),
  );
}



