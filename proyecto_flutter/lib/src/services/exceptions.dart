/// Clase que define las excepciones que se pueden lanzar en la aplicación.
/// 
/// Se pueden lanzar excepciones de tipo [ApiException] o sus subtipos.
/// 
/// Los subtipos son:
/// 
/// * [InvalidCredentialsException]: Excepción lanzada cuando las credenciales son incorrectas.
/// * [UserNotFoundException]: Excepción lanzada cuando el usuario no se encuentra.
/// * [MethodNotAllowedException]: Excepción lanzada cuando el método no está permitido.
/// 
/// Las excepciones se lanzan con un mensaje que se puede mostrar al usuario.
/// 
/// Se pueden lanzar excepciones de tipo [Exception] si hay un error desconocido.
/// 
library;

/// Excepción genérica de la API.
/// 
/// Se lanza cuando hay un error en la API.
/// 
/// Se puede lanzar con un mensaje que se puede mostrar al usuario.
/// 
class ApiException implements Exception 
{
  // Mensaje de la excepción.
  final String message;

  // Constructor
  ApiException(this.message);

}

/// Excepción lanzada cuando las credenciales son incorrectas.
/// 
class InvalidCredentialsException extends ApiException 
{
  // Constructor
  InvalidCredentialsException(super.message);
}

/// Excepción lanzada cuando el usuario no se encuentra.
///
class UserNotFoundException extends ApiException 
{
  // Constructor
  UserNotFoundException(super.message);
}

/// Excepción lanzada cuando el método no está permitido.
/// 
class MethodNotAllowedException extends ApiException 
{
  // Constructor
  MethodNotAllowedException(super.message);
}

/// Excepción lanzada cuando las contraseñas no coinciden.
/// 
class PasswordsDoNotMatchException extends ApiException 
{
  // Constructor
  PasswordsDoNotMatchException(super.message);
}