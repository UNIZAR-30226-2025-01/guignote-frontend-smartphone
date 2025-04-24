import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/models/gamechat_model.dart';
import 'package:sota_caballo_rey/src/services/gamechat_service.dart';

class GamechatModal extends StatefulWidget
{
  final int chatId;

  const GamechatModal({super.key, required this.chatId});

  @override
  State<GamechatModal> createState() => _GamechatModalState();
}

class _GamechatModalState extends State<GamechatModal>
{
  // Controller para el campo de texto del mensaje
  final TextEditingController _messageController = TextEditingController();
  // Controlador para el scroll del chat
  final ScrollController _scrollController = ScrollController();
  // Lista de mensajes del chat
  final List<GameChatMessage> _messages = [];

  // subscripción al stream de mensajes
  late StreamSubscription _webSocketSubscription;
  // Variable para el estado de conexión del WebSocket
  bool _isloading = true;

  // Instancia del servicio de chat
  final gamechatService = GamechatService();


  @override
  void initState()
  {
    super.initState();

    _initChat();    

  }

  Future<void> _initChat() async
  {
    try
    {
      // En primer lugar obtenemos los mensajes mediante el servicio
      final mensajes = await gamechatService.getMessages(widget.chatId);

      setState(() 
      {
        // Asignamos los mensajes a la lista 
        _messages.addAll(mensajes);
        _isloading = false;  
      });

      // Desplazamos el scroll al final para mostrar los mensajes más recientes
      _scrollAlFinal();

      // Conexión al WebSocket
      await gamechatService.conectarWebSocket(widget.chatId);

      // Escuchamos los mensajes del WebSocket y los añadimos a la lista
      _webSocketSubscription = gamechatService.messagesStream.listen((newMessage) 
      {
        setState(() 
        {
          _messages.insert(0, newMessage); // Añadimos el nuevo mensaje al principio de la lista
        });
      });

      // Desplazamos el scroll al final para mostrar los mensajes más recientes
      _scrollAlFinal();

    }catch(e)
    {
      if(!mounted) return; // Si el widget no está montado, no hacemos nada
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al cargar el chat: $e")));
    }
  }

  @override
  void dispose()
  {
    _messageController.dispose(); // Limpiamos el controlador del mensaje
    _scrollController.dispose(); // Limpiamos el controlador del scroll
    _webSocketSubscription.cancel(); // Cancelamos la subscripción al WebSocket
    gamechatService.disconnect(); // Desconectamos el WebSocket
    super.dispose();
  }

  void _sendMessage()
  {
    final message = _messageController.text.trim();
    if(message.isNotEmpty)
    {
      gamechatService.sendMessage(message);
      _messageController.clear(); // Limpiamos el campo de texto
    }
  }

  void _scrollAlFinal()
  {
    WidgetsBinding.instance.addPostFrameCallback((_) 
    {
      if(_scrollController.hasClients)
      {
        _scrollController.animateTo
        (
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut, // Animación suave al final del scroll
        );
      }
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return DraggableScrollableSheet
    (
      // Configuración del DraggableScrollableSheet
      initialChildSize: 0.6, 
      maxChildSize: 0.9,
      minChildSize: 0.3,

      // Definimos el builder del DraggableScrollableSheet
      builder: (_, _) => Container
      (
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration
        (
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column
        (
          children: 
          [
            const Text('Chat de la partida', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),

            Expanded
            (
              child: _isloading // Si está cargando, mostramos un CircularProgressIndicator
              ? const Center(child: CircularProgressIndicator(color: Colors.amber,))
              : ListView.builder // En caso contrario mostramos el chat de la partida.
              (
                controller: _scrollController,
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) 
                {
                  final message = _messages[index];
                  return ListTile
                  (
                    leading: CircleAvatar(backgroundImage: NetworkImage(message.emisor.profileImageUrl)),
                    title: Text(message.emisor.username),
                    subtitle: Text(message.contenido),
                    trailing: Text(message.fechaEnvio.toString()),
                  );
                },
              ),
            ),
            Row
            (
              children: 
              [
                Expanded
                (
                  child: TextField
                  (
                    controller: _messageController,
                    decoration: const InputDecoration
                    (
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton
                (
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage, // Enviamos el mensaje al pulsar el botón
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}