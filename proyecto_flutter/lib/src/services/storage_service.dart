import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para almacenar y recuperar información sensible de forma segura.
class StorageService
{
  static final _storage = FlutterSecureStorage();

  // Guarda el token de JWT en el almacenamiento seguro.
  static Future<void> saveToken(String token) async
  {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Obtiene el token de JWT del almacenamiento seguro.
  static Future<String?> getToken() async
  {
    return await _storage.read(key: 'jwt_token');
  }

  // Elimina el token de JWT del almacenamiento seguro.
  static Future<void> deleteToken() async
  {
    await _storage.delete(key: 'jwt_token');
  }


}