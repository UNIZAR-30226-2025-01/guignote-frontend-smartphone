import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/services/storage_service.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';


class FriendChat extends StatefulWidget {
  final String receptorId;
  final String receptorNom;

  // Para los tests
  final List<Map<String,String>>? initialMensajes;
  final Future<void> Function(String)? onSend;
  final Future<List<Map<String,String>>> Function(String receptorId)? onLoad;

  const FriendChat({
    super.key,
    required this.receptorId,
    required this.receptorNom,
    this.initialMensajes,
    this.onLoad,
    this.onSend,
  });

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
    if (widget.initialMensajes != null)
    {
      mensajes = widget.initialMensajes!;
    }
    else
    {
      _cargarMensajes();
    }

    _conectar();
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
      final lista = widget.onLoad != null
        ? await widget.onLoad!(widget.receptorId)
        : await obtenerMensajes(widget.receptorId);
      if (mounted) 
      {
        setState(() {
          mensajes = lista;
        });
      }
    } catch (_) {}
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
  Future<void> _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    if (widget.onSend != null)
    {
      await widget.onSend!(texto);

      setState(() {
        mensajes.insert(0, {
          'emisor': 'me',
          'contenido': texto,
          'fecha_envio': DateFormat.Hm().format(DateTime.now())
        });
      });
    }
    else
    {
      channel!.sink.add(jsonEncode({'contenido' : texto}));
    }

    _controller.clear();
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

  ///
  /// Barra superior con botón para volver a pantalla
  /// anterior y nombre del amigo con el que chateas
  ///
  Widget _barraSuperior() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white)
          ),
          Expanded(
            child: Text(
              widget.receptorNom,
              style: const TextStyle(
                fontFamily: 'tituloApp',
                fontSize: 24,
                color: Colors.white
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center
            )
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    double barraAltura = MediaQuery.of(context).padding.top + 52.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Background(),
          const CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),
          Container(
            height: barraAltura,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.black.withAlpha(192), Colors.black.withAlpha(64)]
              )
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _barraSuperior(),
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