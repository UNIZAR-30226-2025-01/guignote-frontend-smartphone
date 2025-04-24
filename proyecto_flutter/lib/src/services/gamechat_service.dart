import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:sota_caballo_rey/config.dart';
import 'package:sota_caballo_rey/src/services/storage_service.dart';
import 'package:sota_caballo_rey/src/models/gamechat_model.dart';


class GamechatService 
{
  WebSocketChannel? _channel;
  StreamController<GameChatMessage>? _messageStreamController;

  // Devuelve los mensajes actuales del stream
  Stream<GameChatMessage> get messagesStream
  {
    _messageStreamController ??= StreamController<GameChatMessage>.broadcast();
    return _messageStreamController!.stream;
  }

  // Obtiene  mensajes por petición HTTP, en orden descendente de fecha
  Future<List<GameChatMessage>> getMessages(int chatId) async
  {
    final token = await StorageService.getToken();

    if(token == null)
    {
      throw Exception("No se ha encontrado el token de autenticación"); // Si no se encuentra el token, lanza una excepción
    }

    final url = Uri.parse("${Config.apiBaseURL}${Config.obtenerMensajesChatPartida}?chat_id=$chatId");

    final response = await http.get(url, headers:
    {
      'Auth' : token,
      'Accept': 'application/json',
    });

    // Si la respuesta es exitosa, decodifica el JSON y devuelve la lista de mensajes
    if(response.statusCode == 200)
    {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final mensajesJson = data['mensajes'] as List<dynamic>;
      return mensajesJson.map((json) => GameChatMessage.fromJson(json)).toList();
    }
    else
    {
      // En cualquier otro caso, lanza una excepción
      throw Exception("Error al obtener los mensajes del chat: ${response.statusCode} - ${response.body}");
    }
  }

  /// Conecta al WebSocket de un chat de partida
  Future<void> conectarWebSocket(int chatId) async
  {
    final token = await StorageService.getToken();

    if(token == null)
    {
      throw Exception("No se ha encontrado el token de autenticación"); // Si no se encuentra el token, lanza una excepción
    }

    final url = Uri.parse("${Config.wsBaseURL}${Config.websocketChatPartida}$chatId/?token=$token");

    _channel = WebSocketChannel.connect(url);
    _messageStreamController = StreamController<GameChatMessage>.broadcast();

    _channel!.stream.listen((raw)
    {
      try
      {
        final data = jsonDecode(raw);
        if(data is Map<String, dynamic> && data.containsKey('contenido'))
        {
          _messageStreamController!.add(GameChatMessage.fromJson(data)); // Añade el mensaje al stream
        }
      }catch(e)
      {
        _messageStreamController!.addError(e); // En caso de error, añade el error al stream
      }

    },
    onError: (error)
    {
      _messageStreamController!.addError(error); // En caso de error, añade el error al stream
    },
    onDone: ()
    {
      _messageStreamController!.close(); // Cierra el stream al finalizar la conexión
    });
  }

  /// Envía un mensaje al WebSocket
  void sendMessage(String message)
  {
    if(_channel != null)
    {
      _channel!.sink.add(jsonEncode(
      {
        'contenido': message,
        'fecha_envio': DateTime.now().toIso8601String(),
      })); // Envía el mensaje al WebSocket
    }
    else
    {
      throw Exception("El WebSocket no está conectado"); // Si el WebSocket no está conectado, lanza una excepción
    }
  }

  /// Desconecta el WebSocket y cierra el stream de mensajes
  Future<void> disconnect() async
  {
    if(_channel != null)
    {
      await _channel?.sink.close(status.normalClosure, 'Cerrando conexión'); // Cierra la conexión del WebSocket
      await _messageStreamController?.close(); // Cierra el stream de mensajes
      _channel = null;
    }
  }
}