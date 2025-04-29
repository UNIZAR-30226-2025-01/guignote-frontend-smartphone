import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sota_caballo_rey/src/screens/user/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';

// Crea un NavigatorObserver simulado para espiar la navegación.
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  // Prepara un SharedPreferences de prueba con un token cualquiera.
  setUpAll(() {
    SharedPreferences.setMockInitialValues({'token': 'dummy'});
  });

  testWidgets('ProfileScreen muestra elementos estáticos clave', (
    tester,
  ) async {
    // Monta el widget.
    await tester.pumpWidget(MaterialApp(home: const ProfileScreen()));
    await tester.pump();

    // Fondo.
    expect(
      find.byType(Background),
      findsOneWidget,
      reason: 'debe pintar el widget Backgorund',
    );

    // Decoraciones de las esquinas.
    expect(
      find.byType(CornerDecoration),
      findsOneWidget,
      reason: 'debe pintar las decoraciones de esquina',
    );

    // Barra de navegación inferior.
    expect(
      find.byType(CustomNavBar),
      findsOneWidget,
      reason: 'debe mostrar la barra de navegación inferior',
    );

    // Boton de cierre de sesión
    expect(
      find.byIcon(Icons.logout),
      findsOneWidget,
      reason: 'Debe de tener un botón para cerrar sesion.',
    );
  });

  testWidgets('El boton de logout navega a /login', (tester) async {
    // Creamos un callback de logout que hace nada
    Future<void> fakeLogout() async {}

    // Crea el NavigatorObserver y monta el widget en un MaterialApp.
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(onLogout: fakeLogout),
        navigatorObservers: [mockObserver],
        routes: {
          '/login':
              (_) => const Scaffold(body: Center(child: Text('LoginScreen'))),
        },
      ),
    );
    await tester.pump();

    // Encuentra y pulsa el botón de logout.
    final logoutButton = find.byIcon(Icons.logout);
    expect(logoutButton, findsOneWidget);
    await tester.tap(logoutButton);
    await tester.pump();
    await tester.pump();

    // Nos aseguramos que estamos en el widget de login.
    expect(find.text('LoginScreen'), findsOneWidget);
  });

  testWidgets('ProfileBox muestra los elementos.', (tester) async {
    // Montamos unas stats de ejemplo
    Future<Map<String, dynamic>> fakeStats() async => {
      "victorias": 10,
      "derrotas": 5,
      "total_partidas": 15,
      "racha_victorias": 3,
      "mayor_racha_victorias": 4,
      "nombre": "TestUser",
      "imagen": "", // fuerza Icons.person
      "porcentaje_victorias": 66.6,
      "elo": 2500,
      "elo_parejas": 2300,
    };

    // Montamos el profileScreen().
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          onLogout: () async {}, // no-op para logout
          loadStats: fakeStats, // nuestro FutureBuilder “rápido”
        ),
      ),
    );

    // 4) Dejamos que todo se pinte y que cierren animaciones/frames
    await tester.pumpAndSettle();

    // Buscamos el ProfileBox
    final perfilBox = find.byKey(const Key('ProfileBox'));
    expect(perfilBox, findsOneWidget);

    // Bloque del perfil.
    expect(
      find.descendant(of: perfilBox, matching: find.text('Perfil')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: perfilBox, matching: find.byIcon(Icons.person)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: perfilBox, matching: find.text('TestUser')),
      findsOneWidget,
    );
    // Falta el rango.

    // Bloque de estadísticas.
    expect(
      find.descendant(of: perfilBox, matching: find.text('Estadísticas')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: perfilBox, matching: find.text('Nº Victorias')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: perfilBox, matching: find.text('10')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: perfilBox, matching: find.text('Nº Derrotas')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: perfilBox, matching: find.text('5')),
      findsOneWidget,
    );

    // Bloque de mochila.
    expect(
      find.descendant(of: perfilBox, matching: find.text('Mochila')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: perfilBox,
        matching: find.byKey(const Key('tabCartasButton')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: perfilBox,
        matching: find.byKey(const Key('tabTapetesButton')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: perfilBox,
        matching: find.byKey(const Key('tabCartasImage')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: perfilBox,
        matching: find.byKey(const Key('tabTapetesImage')),
      ),
      findsOneWidget,
    );

    // Separadores.
    expect(
      find.descendant(of: perfilBox, matching: find.byType(Divider)),
      findsNWidgets(2),
    );
  });

  testWidgets('BackPackTabs resalta el tab seleccionado al clickar.', (tester) async {
    // Override de tamaño de la ventana de test para que quepa el FutureBuilder
    final origSize = tester.view.physicalSize;
    final origDpr  = tester.view.devicePixelRatio;
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.physicalSize = origSize;
      tester.view.devicePixelRatio = origDpr;
    });

    // Montamos unas stats de ejemplo (necesarias para pintar el FutureBuilder).
    Future<Map<String, dynamic>> fakeStats() async => {
      "victorias": 10,
      "derrotas": 5,
      "total_partidas": 15,
      "racha_victorias": 3,
      "mayor_racha_victorias": 4,
      "nombre": "TestUser",
      "imagen": "", // fuerza Icons.person
      "porcentaje_victorias": 66.6,
      "elo": 2500,
      "elo_parejas": 2300,
    };

    // Montamos el profileScreen().
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          onLogout: () async {}, // no-op para logout
          loadStats: fakeStats, // nuestro FutureBuilder “rápido”
        ),
      ),
    );

    await tester.pumpAndSettle();

    final cartasFinder = find.byKey(const Key('tabCartasButton'));
    final tapetesFinder = find.byKey(const Key('tabTapetesButton'));

    // Estado inicial es cartas seleccionado.
    Container cartasContainer = tester.widget<Container>(cartasFinder);
    BoxDecoration cartasDeco = cartasContainer.decoration! as BoxDecoration;
    Border cartasBorder = cartasDeco.border as Border;
    expect(cartasBorder.top.color, Colors.white);

    Container tapetesContainer = tester.widget<Container>(tapetesFinder);
    BoxDecoration tapetesDeco = tapetesContainer.decoration! as BoxDecoration;
    Border tapetesBorder = tapetesDeco.border as Border;
    expect(tapetesBorder.top.color, Colors.transparent);

    // Pulsa Tapetes.
    await tester.tap(tapetesFinder);
    await tester.pump();

    // Ahora tapetes debe tener un borde blanco y Cartas transparente.
    cartasContainer = tester.widget<Container>(cartasFinder);
    cartasDeco = cartasContainer.decoration! as BoxDecoration;
    cartasBorder = cartasDeco.border as Border;
    expect(cartasBorder.top.color, Colors.transparent);

    tapetesContainer = tester.widget<Container>(tapetesFinder);
    tapetesDeco = tapetesContainer.decoration! as BoxDecoration;
    tapetesBorder = tapetesDeco.border as Border;
    expect(tapetesBorder.top.color, Colors.white);

    // Volvemos a pulsar cartas
    await tester.tap(cartasFinder);
    await tester.pump();

    // Volvemos al estado inicial.
    cartasContainer = tester.widget<Container>(cartasFinder);
    cartasDeco = cartasContainer.decoration! as BoxDecoration;
    cartasBorder = cartasDeco.border as Border;
    expect(cartasBorder.top.color, Colors.white);

    tapetesContainer = tester.widget<Container>(tapetesFinder);
    tapetesDeco = tapetesContainer.decoration! as BoxDecoration;
    tapetesBorder = tapetesDeco.border as Border;
    expect(tapetesBorder.top.color, Colors.transparent);
  });
}
