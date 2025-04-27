import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/services/storage_service.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:web_socket_channel/web_socket_channel.dart';



class GameChatModal extends StatefulWidget {
  final int chatId;
  final int jugadorId;

  const GameChatModal({
    super.key,
    required this.chatId,
    required this.jugadorId,
  });

  @override
  GameChatState createState() => GameChatState();
}

class GameChatState extends State<GameChatModal> {
  WebSocketChannel? channel;
  List<Map<String, String>> mensajes = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _conectar();
    _cargarMensajes();
  }

  ///
  /// Conectar al WebSocket del chat usando 'chatId'
  ///
  void _conectar() async {
    try {
      String? token = await StorageService.getToken();
      if(token == null || token.isEmpty) {
        if(kDebugMode) { print("Error: No se encontró token"); }
        return;
      }
      final wsUrl = Uri.parse("ws://188.165.76.134:8000/ws/chat_partida/${widget.chatId}/?token=$token");
      channel = WebSocketChannel.connect(wsUrl);
      channel!.stream.listen(
          (message) {
            final data = json.decode(message);
            setState(() {
              mensajes.insert(0, {
                "emisor": data["emisor"]["id"].toString(),
                "contenido": data["contenido"],
                "fecha_envio": data["fecha_envio"]
              });
            });
            _scrollMensajeMasReciente();
          },
          onError: (error) {
            if(kDebugMode) { print("Error en Websocket: $error"); }
          },
          onDone: () {
            if(kDebugMode) { print("WebSocket cerrado"); }
          }
      );
    } catch(e) {
      if(kDebugMode) {
        print("Error al conectar WebSocket: $e");
      }
    }
  }

  ///
  /// Cargar mensajes previos
  ///
  Future<void> _cargarMensajes() async {
    try {
      List<Map<String, String>> mensajesCargados = await obtenerMensajesChatPartida(widget.chatId);
      setState(() {
        mensajes = mensajesCargados;
      });
      _scrollMensajeMasReciente();
    } catch(e) {
      if(kDebugMode) {
        print("Error al cargar mensajes: $e");
      }
    }
  }

  ///
  /// Desplazar al último mensaje
  ///
  void _scrollMensajeMasReciente() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    });
  }

  ///
  /// Enviar mensaje con WebSocket
  ///
  void _enviarMensaje() {
    if(_controller.text.trim().isEmpty) return;
    if(channel != null) {
      channel!.sink.add(jsonEncode({
        "contenido": _controller.text.trim(),
      }));
      _controller.clear();
    } else {
      if(kDebugMode) {
        print("Error: WebSocket no conectado");
      }
    }
  }

  ///
  /// Lista de mensajes
  ///
  Widget _listaMensajes() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        itemCount: mensajes.length,
        itemBuilder: (context, index) {
          final mensaje = mensajes[index];
          final esPropio = mensaje["emisor"] == widget.jugadorId.toString();
          // Si el mensaje es propio, se alinea a la derecha, si no, a la izquierda
          return _itemLista(mensaje, esPropio);
        }
      )
    );
  }

  ///
  /// Mensaje ítem
  ///
  Widget _itemLista(Map<String, String> mensaje, bool esPropio) {
    return Align(
      alignment: esPropio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: esPropio ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(8)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                mensaje["contenido"]!,
                style: TextStyle(color: esPropio ? Colors.white : Colors.black,
                  fontSize: 16)
            ),
            Text(
              mensaje["fecha_envio"]!,
              style: TextStyle(fontSize: 12, color: Colors.black54)
            )
          ],
        )
      )
    );
  }

  ///
  /// input en el que escribes el mensaje
  ///
  Widget _inputMensaje() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Escribe un mensaje...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _enviarMensaje,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Background(),
          const CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Column(
                      children: [
                        _listaMensajes(),
                        _inputMensaje()
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ]
      )
    );
  }

  @override
  void dispose() {
    channel?.sink.close(WebSocketStatus.goingAway);
    super.dispose();
  }
}