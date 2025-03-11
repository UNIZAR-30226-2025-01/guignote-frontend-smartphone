/// Archivo de servicios de la API.
/// 
/// Contiene las funciones para iniciar sesión y registrar un usuario en la API.
/// 
/// Las funciones son asíncronas, por lo que se pueden usar el await para esperar a que terminen.
/// 
/// Las funciones lanzan excepciones específicas si hay un error en la petición.
/// 
/// Las excepciones se lanzan con un mensaje que se puede mostrar al usuario.
/// 
/// Las funciones también lanzan excepciones de tipo Exception si hay un error desconocido.
/// 
/// Si hay un error, lo imprime en consola si estamos en modo debug.
/// 
/// Relanza la excepción para que la UI la maneje como considere.
/// 
/// Para más información sobre `http`, se puede consultar la documentación en:
/// https://pub.dev/packages/http
/// 
/// Para más información sobre `json`, se puede consultar la documentación en:
/// https://api.dart.dev/stable/2.14.2/dart-convert/dart-convert-library.html
/// 
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sota_caballo_rey/config.dart';
import 'package:sota_caballo_rey/src/models/user.dart';
import 'package:sota_caballo_rey/src/services/storage_service.dart';
import 'package:sota_caballo_rey/src/services/exceptions.dart';


/// Función para iniciar sesión en la API.
/// 
/// Recibe un identificador que puede ser un nombre de usuario o un correo electrónico.
/// Recibe una contraseña.
/// Devuelve un Future con un String que puede ser el token o null.
/// 
/// La función es asíncrona, por lo que se puede usar el await para esperar a que termine.
Future<void> login(String id, String password) async
{
  // Construye la URL de la API.
  final url = Uri.parse('${Config.apiBaseURL}${Config.authEndPoint}');
  
  try
  {
    // Realiza una petición POST a la API.
    final response = await http.post
    (
      // URL de la API.
      url,
      headers:{ "Content-Type": "application/json", "Accept": "application/json" },

      // Cuerpo de la petición.
      body: jsonEncode
      (
        {
          // Dependiendo de si el identificador contiene un "@" o no, se envía como correo o nombre.
          "correo": id.contains("@") ? id : null,
          "nombre": id.contains("@") ? null : id,
          "contrasegna": password,
        }
      ),
    );

    // Comprobamos si la petición fue exitosa.
    if(response.statusCode == 201)
    {
      // Si la petición fue exitosa, se decodifica el cuerpo de la respuesta.
      final data = jsonDecode(response.body);
      final token = data['token'];

      if(token != null)
      {
        // Si el token no es nulo, se guarda en el almacenamiento seguro.
        await StorageService.saveToken(token);
      }
      else
      {
        // Si el token es nulo, se lanza una excepción.
        throw Exception("Error: Token no recibido");
      }
    }
    else
    {
      // Comprobamos los posibles errores específicos de backend.
      switch(response.statusCode)
      {
        case 400:
          throw InvalidCredentialsException('Faltan campos o la contraseña es incorrecta');
        
        case 404:
          throw UserNotFoundException("Usuario no encontrado");
        
        case 405:
          throw MethodNotAllowedException("Método no permitido");
        
        default:
          throw Exception("Error desconocido. Código de error: ${response.statusCode}");
      }
    }

  } catch(e)
  {
    if (kDebugMode) 
    {
      print("Error: en login $e"); // Si hay un error, lo imprime en consola. Para debug.
    }

    rethrow; // Relanza la excepción para que la UI la maneje como considere. 
  }
}

/// Función para registrar un usuario en la API.
/// 
/// Recibe un nombre de usuario.
/// Recibe un correo electrónico.
/// Recibe una contraseña.
/// Recibe una confirmación de la contraseña.
/// 
/// Devuelve un Future sin valor.
/// 
/// La función es asíncrona, por lo que se puede usar el await para esperar a que termine.

/// * Si las contraseñas no coinciden, lanza una excepción de tipo PasswordsDoNotMatchException.
/// 
/// * Si hay un error en la petición, lanza una excepción de tipo Exception.
/// 
/// * Si el usuario ya existe, lanza una excepción de tipo InvalidCredentialsException.
/// 
/// * Si el método no está permitido, lanza una excepción de tipo MethodNotAllowedException.
/// 
/// * Si hay un error desconocido, lanza una excepción de tipo Exception.
/// 
/// * Si hay un error, lo imprime en consola si estamos en modo debug.
/// 
/// * Relanza la excepción para que la UI la maneje como considere.
/// 
Future<void> register(String username, String email, String password, String confirmPassword) async
{

  if(password != confirmPassword)
  {
    // Si las contraseñas no coinciden, se lanza una excepción.
    throw PasswordsDoNotMatchException("Las contraseñas no coinciden");
  }

  // Construye la URL de la API.
  final url = Uri.parse('${Config.apiBaseURL}${Config.createUserEndPoint}');
  
  try
  {
    // Realiza una petición POST a la API.
    final response = await http.post
    (
      // URL de la API.
      url,
      headers:{ "Content-Type": "application/json", "Accept": "application/json" },

      // Cuerpo de la petición.
      body: jsonEncode
      (
        {
          "nombre": username,
          "correo": email,
          "contrasegna": password,
        }
      ),
    );

    // Comprobamos si la petición fue exitosa.
    if(response.statusCode == 201)
    {
      // Si la petición fue exitosa, se decodifica el cuerpo de la respuesta.
      final data = jsonDecode(response.body);
      final token = data['token'];

      if(token != null)
      {
        // Si el token no es nulo, se guarda en el almacenamiento seguro.
        await StorageService.saveToken(token);
      }
      else
      {
        // Si el token es nulo, se lanza una excepción.
        throw Exception("Error: Token no recibido");
      }
    }
    else
    {
      // Comprobamos los posibles errores específicos de backend.
      switch(response.statusCode)
      {
        case 400:
          throw InvalidCredentialsException('Faltan campos o el usuario ya existe');
        
        case 405:
          throw MethodNotAllowedException("Método no permitido");
        
        default:
          throw Exception("Error desconocido. Código de error: ${response.statusCode}");
      }
    }

  } catch(e)
  {
    if (kDebugMode) 
    {
      print("Error: en login $e"); // Si hay un error, lo imprime en consola. Para debug.
    }

    rethrow; // Relanza la excepción para que la UI la maneje como considere. 
  }
}

///
/// La siguiente función permite obtener el listado de amigos de un usuario
/// desde la API
///
Future<List<Map<String, String>>> obtenerAmigos() async {
  // Endpoint petición API
  final url = Uri.parse('${Config.apiBaseURL}${Config.obtenerAmigos}');

  // Obtener token de usuario, si existe
  String? token = await StorageService.getToken();
  if(token == null) {
    throw Exception("No hay un token de autentificación disponible.");
  }

  // Realizar petición GET a API
  try {
    final response = await http.get(
      url, headers: {"Auth": token}
    );
    if(response.statusCode == 200) {
      final data = json.decode(response.body);

      List<Map<String, String>> amigos = List<Map<String, String>>.from(
        data['amigos'].map((amigo) => {
          "id": amigo["id"].toString(),
          "nombre": amigo["nombre"].toString()
        })
      );
      return amigos;
    } else {
      switch (response.statusCode) {
        case 401:
          throw Exception("Token inválido o expirado. Debes iniciar sesión nuevamente.");
        case 405:
          throw Exception("Método no permitido.");
        default:
          throw Exception("Error desconocido. Código: ${response.statusCode}");
      }
    }
  } catch(e) {
    if (kDebugMode){
      print("Error en obtenerAmigos: $e");
    }
    rethrow;
  }
}

///
/// La siguiente función permite obtener un listado de usuarios
/// cuyo nombre contiene un prefijo dado a través de una petición a la API.
/// Incluir_amigos false: excluye de los resultados a los amigos del usuario
/// Incluir_me false: excluye al usuario de los resultados
/// Incluir_pendientes false: excluye usuarios a los que has enviado solicitud
///
Future<List<Map<String, String>>> buscarUsuarios(String prefijo, {bool incluirAmigos = false,
    bool incluirMe = false, bool incluirPendientes = false}) async {
  // Endpoint petición API
  final url =
    Uri.parse('${Config.apiBaseURL}${Config.buscarUsuarios}?nombre=$prefijo&incluir_amigos=$incluirAmigos' +
        '&incluir_me=$incluirMe&incluir_pendientes=$incluirPendientes');

  // Obtener token de usuario, si existe
  String? token = await StorageService.getToken();
  if(token == null) {
    throw Exception("No hay un token de autentificación disponible.");
  }

  // Realizar petición GET a API
  try {
    final response = await http.get(
      url, headers: {"Auth": token}
    );
    if(response.statusCode == 200) {
      final data = json.decode(response.body);

      List<Map<String, String>> usuarios = List<Map<String, String>>.from(
          data['usuarios'].map((usuario) => {
            "id": usuario["id"].toString(),
            "nombre": usuario["nombre"].toString()
          })
      );
      return usuarios;
    } else {
      switch (response.statusCode) {
        case 401:
          throw Exception("Token inválido o expirado. Debes iniciar sesión nuevamente.");
        case 405:
          throw Exception("Método no permitido.");
        default:
          throw Exception("Error desconocido. Código: ${response.statusCode}");
      }
    }
  } catch(e) {
    if (kDebugMode){
      print("Error en buscarUsuarios: $e");
    }
    rethrow;
  }
}

///
/// La siguiente función permite eliminar a un amigo dado su identificador
/// mediante una petición DELETE a la API
///
Future<String> eliminarAmigo(String amigoId) async {
  // Endpoint petición API
  final url =
  Uri.parse('${Config.apiBaseURL}${Config.eliminarAmigo}?amigo_id=$amigoId');

  // Obtener token de usuario, si existe
  String? token = await StorageService.getToken();
  if(token == null) {
    throw Exception("No hay un token de autentificación disponible.");
  }

  // Realizar petición DELETE a la API
  try {
    final response = await http.delete(
      url, headers: {"Auth": token}
    );
    if(response.statusCode == 200) {
      return "Amigo eliminado con éxito";
    } else {
      switch (response.statusCode) {
        case 400:
          throw Exception("Faltan campos.");
        case 401:
          throw Exception(
              "Token inválido o expirado. Debes iniciar sesión nuevamente (401)");
        case 404:
          throw Exception("Amigo no encontrado,");
        case 405:
          throw Exception("Método no permitido.");
        default:
          throw Exception("Error desconocido. Código: ${response.statusCode}");
      }
    }
  } catch(e) {
    if (kDebugMode){
      print("Error en eliminarAmigo: $e");
    }
    rethrow;
  }
}

///
/// La siguiente función permite aceptar una solicitud de amistad
/// mediante una petición POST a la API
///
Future<String> aceptarSolicitudAmistad(String solicitudId) async {
  // Endpoint petición API
  final url =
  Uri.parse('${Config.apiBaseURL}${Config.aceptarSolicitudAmistad}');

  // Obtener token de usuario, si existe
  String? token = await StorageService.getToken();
  if(token == null) {
    throw Exception("No hay un token de autentificación disponible.");
  }

  // Realizar petición POST
  try {
    final response = await http.post(
      url,
      headers: {"Auth": token, "Content-Type": "application/json",
        "Accept": "application/json"},
      body: jsonEncode({
        "solicitud_id": solicitudId
      })
    );
    if(response.statusCode == 200) {
      return "Solicitud aceptada con éxito";
    } else {
      switch (response.statusCode) {
        case 400:
          throw Exception("Faltan campos.");
        case 401:
          throw Exception(
              "Token inválido o expirado. Debes iniciar sesión nuevamente (401)");
        case 403:
          throw Exception("No puedes aceptar una solicitud que no te pertenece.");
        case 404:
          throw Exception("Solicitud no encontrada.");
        case 405:
          throw Exception("Método no permitido.");
        default:
          throw Exception("Error desconocido. Código: ${response.statusCode}");
      }
    }
  } catch(e) {
    if (kDebugMode){
      print("Error en aceptarSolicitudAmistad: $e");
    }
    rethrow;
  }
}

///
/// La siguiente función permite aceptar una solicitud de amistad
/// mediante una petición POST a la API
///
Future<String> denegarSolicitudAmistad(String solicitudId) async {
  // Endpoint petición API
  final url =
  Uri.parse('${Config.apiBaseURL}${Config.denegarSolicitudAmistad}');

  // Obtener token de usuario, si existe
  String? token = await StorageService.getToken();
  if(token == null) {
    throw Exception("No hay un token de autentificación disponible.");
  }

  // Realizar petición POST
  try {
    final response = await http.post(
        url,
        headers: {"Auth": token, "Content-Type": "application/json",
          "Accept": "application/json"},
        body: jsonEncode({
          "solicitud_id": solicitudId
        })
    );
    if(response.statusCode == 200) {
      return "Solicitud denegada con éxito";
    } else {
      switch (response.statusCode) {
        case 400:
          throw Exception("Faltan campos.");
        case 401:
          throw Exception(
              "Token inválido o expirado. Debes iniciar sesión nuevamente (401)");
        case 403:
          throw Exception("No puedes denegar una solicitud que no te pertenece.");
        case 404:
          throw Exception("Solicitud no encontrada.");
        case 405:
          throw Exception("Método no permitido.");
        default:
          throw Exception("Error desconocido. Código: ${response.statusCode}");
      }
    }
  } catch(e) {
    if (kDebugMode){
      print("Error en denegarSolicitudAmistad: $e");
    }
    rethrow;
  }
}

///
/// La siguiente función permite obtener la lista de solicitudes de amistad pendientes
/// mediante una petición GET a la API.
///
Future<List<Map<String, String>>> listarSolicitudesAmistad() async {
  // Endpoint petición API
  final url =
  Uri.parse('${Config.apiBaseURL}${Config.listarSolicitudesAmistad}');

  // Obtener token de usuario, si existe
  String? token = await StorageService.getToken();
  if(token == null) {
    throw Exception("No hay un token de autentificación disponible.");
  }

  // Realizar la petición get a la API
  try {
    final response = await http.get(
      url,
      headers: {"Auth": token}
    );
    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, String>> solicitudes = List<Map<String, String>>.from(
          data['solicitudes'].map((solicitud) => {
            "id": solicitud["id"].toString(),
            "solicitante": solicitud["solicitante"].toString()
          })
      );
      return solicitudes;
    } else {
      switch (response.statusCode) {
        case 401:
          throw Exception(
              "Token inválido o expirado. Debes iniciar sesión nuevamente (401)");
        case 405:
          throw Exception("Método no permitido.");
        default:
          throw Exception("Error desconocido.");
      }
    }
  } catch(e) {
    if (kDebugMode){
      print("Error en denegarSolicitudAmistad: $e");
    }
    rethrow;
  }
}

///
/// La siguiente función permite enviar una solicitud de amistad
/// a un usuario dado su id
///
Future<String> enviarSolicitud(String idRemitente) async {
  // Endpoint petición API
  final url =
  Uri.parse('${Config.apiBaseURL}${Config.enviarSolicitudAmistad}');

  // Obtener token de usuario, si existe
  String? token = await StorageService.getToken();
  if(token == null) {
    throw Exception("No hay un token de autentificación disponible.");
  }

  // Realizar petición POST
  try {
    final response = await http.post(
        url,
        headers: {"Auth": token, "Content-Type": "application/json",
          "Accept": "application/json"},
        body: jsonEncode({
          "destinatario_id": idRemitente
        })
    );
    if(response.statusCode == 201) {
      return "Solicitud envíada con éxito";
    } else {
      switch (response.statusCode) {
        case 400:
          throw Exception("Faltan campos o la solicitud ya fue enviada");
        case 401:
          throw Exception(
              "Token inválido o expirado. Debes iniciar sesión nuevamente (401)");
        case 404:
          throw Exception("Destinatario no encontrada.");
        case 405:
          throw Exception("Método no permitido.");
        default:
          throw Exception("Error desconocido. Código: ${response.statusCode}");
      }
    }
  } catch(e) {
    if (kDebugMode){
      print("Error en enviarSolicitudAmistad: $e");
    }
    rethrow;
  }
}


// La siguiente función busca extraer de la BD la información del usuario y de sus estadísticas.
Future<Map<String,dynamic>> getUserStatistics () async {
  // Obtenemos el token de autenticación.
  String? token = await StorageService.getToken();
  if (token == null || token.isEmpty)
  {
    throw Exception("No hay token de autenticación disponible.");
  }

  final url = Uri.parse ('${Config.apiBaseURL}${Config.buscarEstadisticasUsuario}');

  final response = await http.get(url, headers: {"Auth": token});

  if (response.statusCode == 200)
  {
    return jsonDecode(response.body);
  }
  else if (response.statusCode == 401)
  {
    throw Exception("Token inválido o no proporcionado.");
  }
  else if (response.statusCode == 405)
  {
    throw Exception("Método no permitido.");
  }
  else
  {
    throw Exception("Error desconocido. Codigo ${response.statusCode}");
  }
}