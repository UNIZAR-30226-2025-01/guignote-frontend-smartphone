
import 'package:sota_caballo_rey/src/models/user.dart';

class GameChatMessage
{
  final User emisor;
  final String contenido;
  final DateTime fechaEnvio;

  GameChatMessage({
    required this.emisor,
    required this.contenido,
    required this.fechaEnvio,
  });


  factory GameChatMessage.fromJson(Map<String,dynamic> json)
  {
    return GameChatMessage
    (
      emisor: User
      (
        id: json['emisor']['id'],
        username: json['emisor']['nombre'],
        email: '',
        password: '',
        token: null,
        profileImageUrl: User.defaultProfileImageUrl,
      ),
      contenido: json['contenido'],
      fechaEnvio:  DateTime.parse(json['fecha_envio']),
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'emisor': emisor.toJson(),
      'contenido': contenido,
      'fecha_envio': fechaEnvio.toIso8601String(),
    };
  }
}