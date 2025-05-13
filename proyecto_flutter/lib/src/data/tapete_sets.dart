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
    assetPath: 'assets/images/tapetes/tapete1.png',
  ),
  TapeteSet(
    id: 2,
    assetPath: 'assets/images/tapetes/tapete2.png',
  ),
  TapeteSet(
    id: 3,
    assetPath: 'assets/images/tapetes/tapete3.png',
  ),
  TapeteSet(
    id: 4,
    assetPath: 'assets/images/tapetes/tapete4.png',
  ),
];