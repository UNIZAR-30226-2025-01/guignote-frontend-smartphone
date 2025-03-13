import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/services/storage_service.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FriendChat extends StatefulWidget {
  final String receptorId;
  const FriendChat({super.key, required this.receptorId});

  @override
  FriendChatState createState() => FriendChatState();
}

class FriendChatState extends State<FriendChat> {
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
  /// Conectar al WebSocket del chat usando 'receptorId'
  ///
  void _conectar() async {
    try {
      String? token = await StorageService.getToken();
      if(token == null || token.isEmpty) {
        if(kDebugMode) { print("Error: No se encontró token"); }
        return;
      }
      final wsUrl = Uri.parse("ws://188.165.76.134:8000/ws/chat/${widget.receptorId}/?token=$token");
      channel = WebSocketChannel.connect(wsUrl);
      channel!.stream.listen(
          (message) {
            final data = json.decode(message);
            setState(() {
              mensajes.insert(0, {
                "emisor": data["emisor"].toString(),
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
      List<Map<String, String>> mensajesCargados = await obtenerMensajes(widget.receptorId);
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
          final esPropio = mensaje["emisor"] != widget.receptorId;
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
                style: TextStyle(color: esPropio ? Colors.white : Colors.black)
            ),
            Text(
              mensaje["fecha_envio"]!,
              style: TextStyle(fontSize: 10, color: Colors.black54)
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

  ///
  /// Botón de volver sin usar `AppBar`
  ///
  Widget _botonVolver() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Background(),
          const CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                children: [
                  _botonVolver(),
                  _listaMensajes(),
                  _inputMensaje()
                ],
              ),
            )
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