// lib/src/utils/validator.dart

/// Valida un email.
///
/// Esta función verifica si el email proporcionado no está vacío y si cumple con
/// el formato de un email válido utilizando una expresión regular.
///
/// Parámetros:
/// - `email`: El email a validar.
///
/// Devuelve:
/// - Un mensaje de error si el email está vacío o no es válido.
/// - `null` si el email es válido.
String? validateEmail(String email)
{
  if(email.isEmpty)
  {
    return 'Por favor, ingrese su email';
  }
  else if(!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email))
  {
    return 'El email no es válido';
  }
  return null;
}

/// Valida una contraseña.
///
/// Esta función verifica si la contraseña proporcionada no está vacía y si cumple con
/// los requisitos de seguridad: al menos 8 caracteres, una letra mayúscula, una letra
/// minúscula y un número, utilizando una expresión regular.
///
/// Parámetros:
/// - `password`: La contraseña a validar.
///
/// Devuelve:
/// - Un mensaje de error si la contraseña está vacía o no cumple con los requisitos.
/// - `null` si la contraseña es válida.
String? validatePassword(String password)
{
  if(password.isEmpty)
  {
    return 'Por favor, ingrese su contraseña';
  }
  
  final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');
  if(!passwordRegex.hasMatch(password))
  {
    return 'La contraseña debe tener al menos 8 caracteres, una letra mayúscula, una letra minúscula y un número';
  }

  return null;
}

/// Valida un nombre de usuario.
///
/// Esta función verifica si el nombre de usuario proporcionado no está vacío y si cumple con
/// el formato permitido: solo letras y números, utilizando una expresión regular.
///
/// Parámetros:
/// - `username`: El nombre de usuario a validar.
///
/// Devuelve:
/// - Un mensaje de error si el nombre de usuario está vacío o no cumple con el formato.
/// - `null` si el nombre de usuario es válido.
String? validateUsername(String username)
{
  if(username.isEmpty)
  {
    return 'Por favor, ingrese su nombre de usuario';
  }

  final usernameRegEx = RegExp(r'^[a-zA-Z0-9]+');

  if(!usernameRegEx.hasMatch(username))
  {
    return 'El nombre de usuario solo puede contener letras y números';
  }
  
  return null;
}
