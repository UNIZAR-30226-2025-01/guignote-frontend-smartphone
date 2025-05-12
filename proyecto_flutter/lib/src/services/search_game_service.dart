import 'dart:async';
import 'dart:convert';
import 'package:sota_caballo_rey/config.dart';
import 'package:http/http.dart' as http;
import 'package:sota_caballo_rey/src/services/storage_service.dart';
import 'package:sota_caballo_rey/src/services/websocket_service.dart';

class SearchGameService 
{
  final WebsocketService _websocketService = WebsocketService();


  /// Busca listado de partidas disponibles 
  Future<List<Map<String, dynamic>>> getAvailableGames({int? capacidad}) async
  {
    final token = await StorageService.getToken(); // Esperamos a que se obtenga el token de almacenamiento seguro.
    if (token == null) 
    {
      // En caso de ser nulo lanzamos una excepción.
      // Esto indica que el usuario no está autenticado.
      throw Exception('Usuario no autenticado');
    }
    // Construimos la URL de la API para obtener el listado de partidas disponibles.
    // La URL se construye concatenando la URL base de la API con el endpoint correspondiente.
    final url = Uri.parse('${Config.apiBaseURL}${Config.obtenerListadoPartidasDisponibles}');

    // Realizamos una solicitud GET a la API para obtener el listado de partidas disponibles.
    final response = await http.get
    (
      url, // URL de la API.
      headers: {
        'Auth': token, // Campo que espera obligatoriamente: token de autenticación.
        'Content-Type': 'application/json', // Indicamos el tipo de contenido de la solicitud.
        'Accept': 'application/json', // Indicamos el tipo de contenido esperado en la respuesta.
      },
    );

    if(response.statusCode == 200)
    {
      // En caso de recibir una respuesta exitosa (código 200), decodificamos la respuesta JSON.
      // Decodificamos la respuesta JSON recibida del servidor a un mapa de Dart.
      final data = json.decode(response.body) as Map<String, dynamic>;
      
      // Devolvemos la lista de partidas disponibles.
      // La lista de partidas disponibles se encuentra en el campo 'partidas' del mapa decodificado.
      return List<Map<String, dynamic>>.from(data['partidas'] as List<dynamic>);
    }
    else
    {
      // En cualquier otro caso, lanzamos una excepción. Sin entrar en detalles de la respuesta.
      // El único código de error que se puede recibir es 405: Método no permitido.

      throw Exception('Error al obtener el listado de partidas disponibles: ${response.statusCode} - ${response.body}');  
    }
  }

  /// Método que muestra la lista de partidas reconectables por el usuario, es decir, partidas que ha empezado pero no terminado
  /// y tiene la posibilidad de continuar.
  Future<List<Map<String,dynamic>>> getReconnectableGames() async
  {
    final token = await StorageService.getToken(); // Esperamos a que se obtenga el token de almacenamiento seguro.
    if (token == null) 
    {
      // En caso de ser nulo lanzamos una excepción.
      // Esto indica que el usuario no está autenticado.
      throw Exception('Usuario no autenticado');
    }
    // Construimos la URL de la API para obtener el listado de partidas disponibles.
    // La URL se construye concatenando la URL base de la API con el endpoint correspondiente.
    final url = Uri.parse('${Config.apiBaseURL}${Config.obtenerListadoPartidasReconectables}');

    // Realizamos una solicitud GET a la API para obtener el listado de partidas disponibles.
    final response = await http.get
    (
      url, // URL de la API.
      headers: {
        'Auth': token, // Campo que espera obligatoriamente: token de autenticación.
        'Content-Type': 'application/json', // Indicamos el tipo de contenido de la solicitud.
        'Accept': 'application/json', // Indicamos el tipo de contenido esperado en la respuesta.
      },
    );
    if(response.statusCode == 200)
    {
      // En caso de recibir una respuesta exitosa (código 200), decodificamos la respuesta JSON.
      // Decodificamos la respuesta JSON recibida del servidor a un mapa de Dart.
      final data = json.decode(response.body) as Map<String, dynamic>;
      
      // Devolvemos la lista de partidas disponibles.
      // La lista de partidas disponibles se encuentra en el campo 'partidas' del mapa decodificado.
      return List<Map<String, dynamic>>.from(data['partidas'] as List<dynamic>);
    }
    else
    {
      // En cualquier otro caso, lanzamos una excepción. Sin entrar en detalles de la respuesta.
      // El único código de error que se puede recibir es 405: Método no permitido.

      throw Exception('Error al obtener el listado de partidas reconectables: ${response.statusCode} - ${response.body}');  
    }
  }

  /// Método que se encarga de conectar a una partida, ya sea nueva o existente.
  /// Puede recibir el parámetro [id_partida] que indica la partida a la que se desea conectar. Pero no es obligatorio.
  /// En caso de no recibirlo se conectará mediante el parámetro [capacidad] que indica el número de jugadores que se desea en la partida.
  Future<void> connectToGame({int? idPartida, int? capacidad, bool soloAmigos = false}) async
  {
    // Primero validamos los parámetros, al menos necesitamos idPartida o capacidad.
    if(idPartida == null && capacidad == null) 
    {
      throw ArgumentError('Se necesita al menos un parámetro: idPartida o capacidad');
    }

    await _websocketService.connect
    (
      partidaID: idPartida, // ID de la partida a la que se desea conectar.
      capacidad: capacidad ?? 2, // Capacidad de la partida a la que se desea conectar. Por defecto 2.
      soloAmigos: soloAmigos, // Indica si la partida es solo para amigos.
    ); // Conectamos al WebSocket.
  }

  /// Escucha los mensajes entrantes del WebSocket y los emite en el StreamController.
  Stream<Map<String, dynamic>> listenIncomingMessages() 
  {
    return _websocketService.incomingMessages; // Retorna el Stream de mensajes entrantes del WebSocket.
  }

  /// Desconecta de la partida actual y libera recursos.
  Future<void> disconnectFromMatch() async 
  {
    await _websocketService.disconnect();
  }
  
  /// Método para enviar un mensaje al WebSocket.
  void sendMessage(Map<String, dynamic> message) 
  {
    _websocketService.send(message); // Envía el mensaje al WebSocket.
  }
  
}