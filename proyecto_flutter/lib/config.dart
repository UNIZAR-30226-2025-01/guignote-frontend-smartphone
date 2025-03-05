import 'dart:convert';
import 'package:flutter/services.dart';

class Config
{
  static late Map<String, dynamic> _config;

  static Future<void> load() async
  {
    final configString = await rootBundle.loadString('assets/json/config.json');
    _config = jsonDecode(configString);
  }

  static String get apiBaseURL => _config['apiUrl'];
  static String get authEndPoint => _config['auth_endpoint'];
  static String get createUserEndPoint  => _config['create_user_endpoint'];
  static String get deleteUserEndPoint  => _config['delete_user_endpoint'];

}