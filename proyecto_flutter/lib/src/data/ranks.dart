// Modelo para un rango.
class Ranks {
  final String name;
  final int minElo;
  final String iconAsset;
  const Ranks({
    required this.name,
    required this.minElo,
    required this.iconAsset,
  });
}

// Lista de rangos.
const List<Ranks> ranks = 
[
  Ranks(name: 'Guiri', minElo: 0, iconAsset: 'assets/images/tapete.jpg'),
  Ranks(name: 'Casual', minElo: 1200, iconAsset: 'assets/images/tapete.jpg'),
  Ranks(name: 'Parroquiano', minElo: 1600, iconAsset: 'assets/images/tapete.jpg'),
  Ranks(name: 'Octogenario', minElo: 2100, iconAsset: 'assets/images/tapete.jpg'),
  Ranks(name: 'Leyenda del IMSERSO', minElo: 2700, iconAsset: 'assets/images/tapete.jpg'),
];
