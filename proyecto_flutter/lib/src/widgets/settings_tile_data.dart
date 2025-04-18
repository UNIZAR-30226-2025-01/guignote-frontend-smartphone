import 'package:flutter/material.dart';

/// Clase que representa un tile de configuración en el diálogo de ajustes.
/// Necesita un icono, un título y una función que se ejecuta al pulsar el tile.
class SettingsTileData
{
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  SettingsTileData({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}