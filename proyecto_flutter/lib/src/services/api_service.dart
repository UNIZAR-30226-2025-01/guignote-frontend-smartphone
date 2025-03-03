import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sota_caballo_rey/config.dart';


/// Función para iniciar sesión en la API.
/// 
/// Recibe un identificador que puede ser un nombre de usuario o un correo electrónico.
/// Recibe una contraseña.
/// Devuelve un Future con un String que puede ser el token o null.
/// 
/// La función es asíncrona, por lo que se puede usar el await para esperar a que termine.
Future<String?> login(String id, String password) async
{
  // Construye la URL de la API.
  final url = Uri.parse('${Config.apiBaseURL}${Config.authEndPoint}');
  
  try
  {
    final response = await http.post
    (
      url,
      headers:{ "Content-Type": "aplication/json", "Accept": "application/json" },

      body: jsonEncode
      (
        {
          "correo": id.contains("@") ? id : null,
          "nombre": id.contains("@") ? null : id,
          "contrasegna": password,
        }
      ),
    );

    if(response.statusCode == 201)
    {
      final data = jsonDecode(response.body);
      return data['token']; // Devuelve el token en caso de respuesta exitosa. 
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

    return null; 
  }
}