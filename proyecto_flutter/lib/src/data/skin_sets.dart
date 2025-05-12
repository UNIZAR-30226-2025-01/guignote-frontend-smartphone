// Un único punto de verdad para cada set de cartas (frontales + dorso).
class Skinset
{
  final int id;
  final String name;
  final String backAsset;
  final List<String> skinAssets;

  const Skinset
  ({
      required this.id,
      required this.name,
      required this.backAsset,
      required this.skinAssets,
  });
}

// Definimos los sets que tenemos en assets/images/decks/.
final List<Skinset> skinSets = [
  Skinset(
    id: 1,
    name: 'Base',
    backAsset: 'assets/images/decks/base/Back.png',
    skinAssets: [
      for (var number in ['1', '2', '3', '4', '5', '6', '7', '10', '11', '12'])
        for (var suit in ['Bastos', 'Copas', 'Espadas', 'Oros'])
          'assets/images/decks/base/$number$suit.png',
    ]
  ),
  Skinset(
    id: 2,
    name: 'Poker',
    backAsset: 'assets/images/decks/poker/Back.png',
    skinAssets: [
      for (var number in ['1', '2', '3', '4', '5', '6', '7', '10', '11', '12'])
        for (var suit in ['Bastos', 'Copas', 'Espadas', 'Oros'])
          'assets/images/decks/poker/$number$suit.png',
    ]
  ),
  Skinset(
    id: 3,
    name: 'Paint',
    backAsset: 'assets/images/decks/paint/Back.png',
    skinAssets: [
      for (var number in ['1', '2', '3', '4', '5', '6', '7', '10', '11', '12'])
        for (var suit in ['Bastos', 'Copas', 'Espadas', 'Oros'])
          'assets/images/decks/poker/$number$suit.png',
    ]
  ),
];