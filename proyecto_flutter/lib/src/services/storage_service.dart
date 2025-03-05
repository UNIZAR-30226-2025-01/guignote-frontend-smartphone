import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para almacenar y recuperar información sensible de forma segura.
///
/// Este servicio utiliza `FlutterSecureStorage` para almacenar datos de forma segura en el dispositivo.
/// Proporciona métodos para guardar, obtener y eliminar un token JWT.
class StorageService {
  static final _storage = FlutterSecureStorage();

  /// Guarda el token de JWT en el almacenamiento seguro.
  ///
  /// Parámetros:
  /// - `token`: El token JWT a guardar.
  ///
  /// Devuelve:
  /// - Un `Future` que se completa cuando el token se ha guardado.
  static Future<void> saveToken(String token) async 
  {
    await _storage.write(key: 'jwt_token', value: token);
  }

  /// Obtiene el token de JWT del almacenamiento seguro.
  ///
  /// Devuelve:
  /// - Un `Future` que contiene el token JWT si existe, o `null` si no existe.
  static Future<String?> getToken() async 
  {
    return await _storage.read(key: 'jwt_token');
  }

  /// Elimina el token de JWT del almacenamiento seguro.
  ///
  /// Devuelve:
  /// - Un `Future` que se completa cuando el token se ha eliminado.
  static Future<void> deleteToken() async 
  {
    await _storage.delete(key: 'jwt_token');
  }
}