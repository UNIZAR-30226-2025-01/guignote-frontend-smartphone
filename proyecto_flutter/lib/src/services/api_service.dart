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

/**
 * La siguiente función permite obtener el listado de amigos de un usuario
 * desde la API
 */
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