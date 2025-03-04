import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sota_caballo_rey/config.dart';
import 'package:sota_caballo_rey/src/services/storage_service.dart';


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
          throw Exception("Faltan campos o la contraseña es incorrecta");
        
        case 404:
          throw Exception("Usuario no encontrado");
        
        case 405:
          throw Exception("Método no permitido");
        
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