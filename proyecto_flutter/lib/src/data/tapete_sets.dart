class TapeteSet{
  final int id;
  final String assetPath;

  const TapeteSet({
    required this.id,
    required this.assetPath,
  });
}


// Registramos todos los tapetes.
const List<TapeteSet> tapeteSets = [
  TapeteSet(
    id: 1,
    assetPath: 'assets/images/tapete1.png',
  ),
  TapeteSet(
    id: 2,
    assetPath: 'assets/images/tapete2.png',
  ),
  TapeteSet(
    id: 3,
    assetPath: 'assets/images/tapete3.png',
  ),
  TapeteSet(
    id: 4,
    assetPath: 'assets/images/tapete4.png',
  ),
];