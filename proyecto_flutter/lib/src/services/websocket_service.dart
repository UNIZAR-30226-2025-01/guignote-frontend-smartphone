import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sota_caballo_rey/config.dart';
import 'dart:async';
import 'package:sota_caballo_rey/src/services/storage_service.dart';

/// Servicio para gestionar la conexión WebSocket con el PartidaConsumer de Django Channels
class WebsocketService 
{
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _incomingController;

  Stream<Map<String, dynamic>> get incomingMessages
  {
    if(_incomingController == null || _incomingController!.isClosed)
    {
      _incomingController = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _incomingController!.stream;
  }

  /// Conecta al servidor para crear o unirse a una partida.
  /// 
  /// Si [partidaID] no es nulo, se usa para unirse a una partida existente.
  /// En caso contrario se usa [capacidad] y [soloAmigos] para buscar/crear una partida.
  /// Devuelve un Future que se completa cuando la conexión está lista.
  Future<void> connect
  (
    {
      int? partidaID,
      int capacidad = 2,
      bool soloAmigos = false,
    }
  ) async
  {
    final token = await StorageService.getToken();
    if (token == null) 
    {
      throw Exception('Usuario no autenticado');
    }

    // Construimos los parametros de la URL
    final params = Uri(queryParameters: 
    {
      'token': token,
      if (partidaID != null) 'partida_id': partidaID.toString(),
      if (partidaID == null) 'capacidad': capacidad.toString(),
      if (partidaID == null) 'solo_amigos': soloAmigos.toString(),
    }).query;

    // URL completa para la conexión WebSocket
    final url = Uri.parse('${Config.wsBaseURL}${Config.conexionPartida}?$params');
    _channel = WebSocketChannel.connect(url);

    // Nos aseguramos de que el controlador esté inicializado y abierto
    if(_incomingController == null || _incomingController!.isClosed) 
    {
      _incomingController = StreamController<Map<String, dynamic>>.broadcast();
    }

    // Escuchamos los mensajes entrantes y los emitimos en el StreamController
    _channel!.stream.listen
    (
      (raw)
      {
        try
        {
          final data = jsonDecode(raw as String) as Map<String, dynamic>;
          _incomingController!.add(data);
        } catch (e)
        {
          _incomingController!.addError(e);
        }
      },
      onError: (error) => _incomingController!.addError(error),
      onDone: () => _incomingController!.close(),
    );
  }

  /// Envía un mensaje en formato JSON al servidor.
  void send(Map<String, dynamic> message) 
  {
    if (_channel != null) 
    {
      _channel!.sink.add(jsonEncode(message));
    } else 
    {
      throw Exception('No hay conexión WebSocket activa');
    }
  }

  /// Cierra la conexión WebSocket y libera los recursos.
  Future<void> disconnect() async 
  {
    await _channel?.sink.close();
    await _incomingController?.close();

    _channel = null;
  }
}