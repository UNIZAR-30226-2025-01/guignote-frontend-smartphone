import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para almacenar y recuperar información sensible de forma segura.
///
/// Este servicio utiliza `FlutterSecureStorage` para almacenar datos de forma segura en el dispositivo.
/// Proporciona métodos para guardar, obtener y eliminar un token JWT.
/// 
/// Para utilizar este servicio, se debe importar `package:flutter_secure_storage/flutter_secure_storage.dart`.
/// 
/// Ejemplo de uso:
/// 
/// ```dart
/// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
/// ```
/// 
/// Para guardar un token JWT, se puede utilizar el método `saveToken`:
/// 
/// ```dart
/// await StorageService.saveToken(token);
/// ```
/// 
/// Para obtener un token JWT, se puede utilizar el método `getToken`:
/// 
/// ```dart
/// String? token = await StorageService.getToken();
/// ```
/// 
/// Para eliminar un token JWT, se puede utilizar el método `deleteToken`:
/// 
/// ```dart
/// await StorageService.deleteToken();
/// ```
/// 
/// Para más información sobre `FlutterSecureStorage`, se puede consultar la documentación en:
/// https://pub.dev/packages/flutter_secure_storage
///
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
    // Guarda el token en el almacenamiento seguro.
    await _storage.write(key: 'jwt_token', value: token);
  }

  /// Obtiene el token de JWT del almacenamiento seguro.
  ///
  /// Devuelve:
  /// - Un `Future` que contiene el token JWT si existe, o `null` si no existe.
  static Future<String?> getToken() async 
  {
    // Obtiene el token del almacenamiento seguro.
    return await _storage.read(key: 'jwt_token');
  }

  /// Elimina el token de JWT del almacenamiento seguro.
  ///
  /// Devuelve:
  /// - Un `Future` que se completa cuando el token se ha eliminado.
  static Future<void> deleteToken() async 
  {
    // Elimina el token del almacenamiento seguro.
    await _storage.delete(key: 'jwt_token');
  }
}