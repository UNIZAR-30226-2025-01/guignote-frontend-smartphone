import 'package:audioplayers/audioplayers.dart';	
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de audio para gestionar la música y los efectos de sonido de la aplicación.
///
/// Este servicio utiliza el patrón Singleton para garantizar que solo exista una instancia
/// de la clase en toda la aplicación. Proporciona métodos para reproducir música, efectos
/// de sonido y ajustar los volúmenes generales, de música y de efectos.
class AudioService
{
  /// Instancia única de AudioService (Singleton).
  static final AudioService _instance = AudioService._internal();

  /// Constructor privado para evitar la creación de instancias adicionales.
  /// 
  /// Utiliza el patrón Singleton para garantizar que solo exista una instancia de AudioService.
  factory AudioService() => _instance;
  AudioService._internal();

  /// Reproductores de audio para música y efectos de sonido.
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _effectsPlayer = AudioPlayer();

  /// Volúmenes de música, efectos y general.
  double _musicVolume = 1.0; // Volumen de la música (0.0 a 1.0).
  double _effectsVolume = 1.0; // Volumen de los efectos (0.0 a 1.0).
  double _generalVolume = 1.0; // Volumen general (0.0 a 1.0).


  /// Inicializa el servicio de audio.
  /// 
  /// Carga los volúmenes de música, efectos y general desde las preferencias compartidas.
  Future <void> init() async
  {
    final prefs = await SharedPreferences.getInstance();
    _musicVolume = prefs.getDouble('musicVolume') ?? 1.0;
    _effectsVolume = prefs.getDouble('effectsVolume') ?? 1.0;
    _generalVolume = prefs.getDouble('generalVolume') ?? 1.0;

    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume * _generalVolume);
  }

  /// Reproduce la música de fondo del menú en bucle.
  /// 
  /// Establece la fuente de audio en el archivo 'menu_jazz_lofi.mp3' y reanuda la reproducción.
  Future<void> playMenuMusic() async 
  {
    await _musicPlayer.setSource(AssetSource('sounds/menu_jazz_lofi.mp3'));
    await _musicPlayer.resume();
  }

  /// Detiene la música de fondo.
  /// 
  /// Detiene la reproducción de la música y libera los recursos del reproductor.
  Future<void> stopMusic() async 
  {
    await _musicPlayer.stop();
  }

  /// Reproduce un efecto de sonido específico.
  ///
  /// Parámetros:
  /// - [name]: Nombre del archivo de sonido (sin la extensión).
  Future<void> playEffect(String name) async 
  {
    await _effectsPlayer.setSource(AssetSource('sounds/$name.mp3'));
    await _effectsPlayer.setVolume(_effectsVolume * _generalVolume);
    await _effectsPlayer.resume();
  }

  /// Ajusta el volumen general de la aplicación.
  ///
  /// Parámetros:
  /// - [volume]: Nuevo valor del volumen general (entre 0.0 y 1.0).
  Future<void> setGeneralVolume(double volume) async 
  {
    _generalVolume = volume;
    await _musicPlayer.setVolume(_musicVolume * _generalVolume);
    await _effectsPlayer.setVolume(_effectsVolume * _generalVolume);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', volume);
  }

  /// Ajusta el volumen de la música.
  ///
  /// Parámetros:
  /// - [volume]: Nuevo valor del volumen de la música (entre 0.0 y 1.0).
  Future<void> setMusicVolume(double volume) async 
  {
    _musicVolume = volume;
    await _musicPlayer.setVolume(_musicVolume * _generalVolume);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', volume);
  }

  /// Ajusta el volumen de los efectos de sonido.
  ///
  /// Parámetros:
  /// - [volume]: Nuevo valor del volumen de los efectos (entre 0.0 y 1.0).
  Future<void> setEffectsVolume(double volume) async 
  {
    _effectsVolume = volume;
    await _effectsPlayer.setVolume(_effectsVolume * _generalVolume);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('effectsVolume', volume);
  }

  /// Getters para acceder a los volúmenes actuales.
  double get generalVolume => _generalVolume;
  double get musicVolume => _musicVolume;
  double get effectsVolume => _effectsVolume;
}