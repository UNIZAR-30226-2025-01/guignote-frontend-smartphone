/// Clase que carga la configuración de la aplicación desde un archivo JSON
/// y proporciona métodos para acceder a los valores de configuración.
///
/// La configuración se carga desde el archivo `assets/json/config.json`.
///
/// El archivo JSON debe tener la siguiente estructura:
///
/// ```json
/// {
///  "apiUrl": "https://api.example.com",
/// "auth_endpoint": "/auth",
/// "create_user_endpoint": "/create_user",
/// "delete_user_endpoint": "/delete_user"
/// }
/// ```
///
/// Se ha declarado en el gitignore para que no se suba al repositorio. Por lo que
/// se debe crear un config.json en la carpeta assets/json con la estructura anterior.
///
/// Los valores de configuración disponibles son:
///
/// - `apiUrl`: URL base de la API.
/// - `auth_endpoint`: Endpoint para la autenticación.
/// - `create_user_endpoint`: Endpoint para crear un usuario.
/// - `delete_user_endpoint`: Endpoint para eliminar un usuario.
///
/// Para acceder a los valores de configuración, se pueden utilizar los métodos
/// estáticos de la clase `Config`.
///
/// Ejemplo de uso:
///
/// ```dart
/// String apiUrl = Config.apiBaseURL;
/// ```
///
/// Para cargar la configuración, se debe llamar al método `load` antes de acceder
/// a los valores de configuración.
///
/// Ejemplo de uso:
///
/// ```dart
/// await Config.load();
/// ```
///
/// Una vez cargada la configuración, se pueden acceder a los valores de configuración
/// utilizando los métodos estáticos de la clase `Config`.
///
library;

import 'dart:convert';
import 'package:flutter/services.dart';

class Config {
  // Mapa que contiene la configuración.
  static late Map<String, dynamic> _config;

  // Método para cargar la configuración desde el archivo JSON.
  static Future<void> load() async {
    // Carga el archivo JSON desde los assets.
    final configString = await rootBundle.loadString('assets/json/config.json');
    _config = jsonDecode(configString); // Decodifica el archivo JSON.
  }

  // Métodos para acceder a los valores de configuración.
  static String get apiBaseURL => _config['apiUrl'];
  static String get wsBaseURL => _config['ws_base_url'];
  static String get authEndPoint => _config['auth_endpoint'];
  static String get createUserEndPoint => _config['create_user_endpoint'];
  static String get deleteUserEndPoint => _config['delete_user_endpoint'];
  static String get obtenerAmigos => _config['obtener_amigos_endpoint'];
  static String get buscarUsuarios => _config['buscar_usuarios_endpoint'];
  static String get eliminarAmigo => _config['eliminar_amigo_endpoint'];
  static String get aceptarSolicitudAmistad =>
      _config['aceptar_solicitud_amistad_endpoint'];
  static String get denegarSolicitudAmistad =>
      _config['denegar_solicitud_amistad_endpoint'];
  static String get listarSolicitudesAmistad =>
      _config['listar_solicitudes_amistad_endpoint'];
  static String get enviarSolicitudAmistad =>
      _config['enviar_solicitud_amistad_endpoint'];
  static String get buscarEstadisticasUsuario =>
      _config['buscar_estadisticas_usuario_endpoint'];
  static String get enviarMensajeAmigo =>
      _config['enviar_mensaje_amigo_endpoint'];
  static String get obtenerMensajes => _config['obtener_mensajes_endpoint'];
  static String get topEloEndpoint => _config['top_elo_endpoint'];
  static String get topEloParejasEndpoint =>
      _config['top_elo_parejas_endpoint'];
  
  static String get conexionPartida => _config['conexion_partida_endpoint'];
  static String get topEloFriendsEndpoint => _config['top_elo_amigos_endpoint'];
  static String get topEloParejasFriendsEndpoint =>
      _config['top_elo_parejas_amigos_endpoint'];
  
  static String get obtenerMensajesChatPartida => _config['obtener_mensajes_chat_partida_endpoint'];
  static String get websocketChatPartida => _config['websocket_chat_partida_endpoint'];
  static String get listarSalasDisponibles => _config['listar_salas_disponibles_endpoint'];
  static String get listarSalasReconectables => _config['listar_salas_reconectables_endpoint']; 
}
