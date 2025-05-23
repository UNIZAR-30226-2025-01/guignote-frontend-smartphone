/// Clase que representa un usuario en la aplicación.
/// 
/// Esta clase se utiliza para manejar la información de los usuarios
/// durante el registro y el inicio de sesión.
/// 
/// Atributos:
/// - `nombre`: Nombre del usuario.
/// - `email`: Dirección de correo electrónico del usuario.
/// - `password`: Contraseña del usuario. 
/// Métodos:
/// - `User.fromJson(Map<String, dynamic> json)`: Constructor que crea una instancia de `User` a partir de un mapa JSON.
/// - `Map<String, dynamic> toJson()`: Método que convierte una instancia de `User` a un mapa JSON.
/// Modelo de usuario que se utiliza para el registro y login de usuarios en la aplicación.
/// 
/// Se utiliza para manejar la información de los usuarios durante el registro y el inicio de sesión.
/// 
library;

class User
{

  static const String defaultProfileImageUrl = 'assets/images/default_profile.png';

  final int id;
  final String username;
  final String email;
  final String password;
  final String? token;
  final String profileImageUrl;

  User
  ({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.token,
    this.profileImageUrl = defaultProfileImageUrl,
  });

  // Conversión de JSON a modelo utilizable por la aplicación.
  factory User.fromJson(Map<String, dynamic> json) => User
  (
    id: json['id'],
    username: json['nombre'],
    email: json['correo'],
    password: json['contrasegna'],
    token: json['token'],
    profileImageUrl: json['imagen'] ?? defaultProfileImageUrl,
  );

  // Conversión de modelo a JSON para enviar a la API.
  Map<String, dynamic> toJson() => 
  {
    'id': id,
    'nombre': username,
    'correo': email,
    'contrasegna': password,
    'token': token,
    'imagen': profileImageUrl,
  };
}