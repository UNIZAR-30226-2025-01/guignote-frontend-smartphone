import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sota_caballo_rey/src/screens/home/ranking_screen.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';

// Subclase que devuelve siempre lista vacia.
class EmptyRankingScreen extends RankingScreen {
  const EmptyRankingScreen({super.key});

  @override
  RankingScreenState createState() => _EmptyRankingScreenState();
}

class _EmptyRankingScreenState extends RankingScreenState {
  @override
  Future<List<Map<String, String>>> getRankingData() async {
    // Simula que no hay datos.
    return [];
  }
}

// Subclase que devuelve siempre datos de prueba.
class SampleRankingScreen extends RankingScreen {
  const SampleRankingScreen({super.key});

  @override
  RankingScreenState createState() => _SampleRankingScreenState();
}

class _SampleRankingScreenState extends RankingScreenState {
  @override
  Future<List<Map<String, String>>> getRankingData() async {
    // Simula 2 entradas.
    return [
      {'nombre': 'Mauricio', 'elo': '1200'},
      {'nombre': 'Antonio', 'elo': '1100'},
    ];
  }
}

void main() {
  testWidgets('RankingScreen muestra titulo, fondo, decoraciones y botones', (
    tester,
  ) async {
    // Monta el widget.
    await tester.pumpWidget(MaterialApp(home: const RankingScreen()));
    await tester.pump();

    // Verificamos los elementos estáticos.
    expect(
      find.byType(Background),
      findsOneWidget,
      reason: 'debe pintar el widget Backgorund',
    );
    expect(
      find.byType(CornerDecoration),
      findsOneWidget,
      reason: 'debe pintar las decoraciones de esquina',
    );
    expect(
      find.byType(CustomNavBar),
      findsOneWidget,
      reason: 'debe mostrar la barra de navegación inferior',
    );
    expect(
      find.text('Rankings'),
      findsOneWidget,
      reason: 'debe mostrar el titulo',
    );

    // Verificamos que los botones de filtro existen.
    expect(find.widgetWithText(ElevatedButton, '1 vs 1'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '2 vs 2'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Global'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Amigos'), findsOneWidget);
  });

  testWidgets('Al pulsar los botones de filtro cambian su color de fondo', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: const RankingScreen()));
    await tester.pump();

    // Por defecto 1 vs 1 y Global estan seleccionados (azul).
    final btn1v1 = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, '1 vs 1'),
    );
    final btnGlobal = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Global'),
    );
    expect(btn1v1.style!.backgroundColor!.resolve({}), Colors.blue);
    expect(btnGlobal.style!.backgroundColor!.resolve({}), Colors.blue);

    // Pulsamos 2 vs 2.
    await tester.tap(find.text('2 vs 2'));
    await tester.pump();
    final btn2v2 = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, '2 vs 2'),
    );
    expect(btn2v2.style!.backgroundColor!.resolve({}), Colors.blue);

    // Pulsamos Amigos.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Amigos'));
    await tester.pump();
    final btnAmigos = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Amigos'),
    );
    expect(btnAmigos.style!.backgroundColor!.resolve({}), Colors.blue);
  });

  testWidgets('Cuando no hay datos muestra mensaje de "No hay datos de ranking disponibles."', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EmptyRankingScreen()));
    await tester.pumpAndSettle();
    expect(find.text('No hay datos de ranking disponibles.'), findsOneWidget);
  });

  testWidgets('Cuando hay datos, pinta las entradas con nombre y elo', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SampleRankingScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Mauricio'), findsOneWidget);
    expect(find.text('1200'), findsOneWidget);
    expect(find.text('Antonio'), findsOneWidget);
    expect(find.text('1100'), findsOneWidget);
  });
}
