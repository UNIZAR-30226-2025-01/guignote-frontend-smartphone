import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sota_caballo_rey/src/screens/friends/friend_request_screen.dart';
import 'package:sota_caballo_rey/src/screens/friends/friends_screen.dart';
import 'package:sota_caballo_rey/src/screens/friends/search_users_screen.dart';
import 'package:sota_caballo_rey/src/screens/friends/friends_list_screen.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';

void main ()
{
  testWidgets('FriendsRequestScreen muestra titulo, fondo, decoraciones y botones', (tester) async 
  {
    // Monta el widget.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: 
              FriendsScreen(),
          ),
        ),
      ));
    await tester.pumpAndSettle();

    // Cambia a la pestaña de "Solicitudes" en el menú superior.
    await tester.tap(find.text('Solicitudes'));
    await tester.pumpAndSettle();

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
      reason: 'debe pintar las decoraciones de las esquinas',
    );

    // Barra de Navegación inferior.
    expect(
      find.byType(CustomNavBar),
      findsOneWidget,
      reason: 'debe mostrar la barra de navegación inferior',
    );

    // Barra de Navegación superior.
    expect(find.text('Amigos'), findsNWidgets(2));
    expect(find.text('Solicitudes'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);

    // Titulo de Amigos.
    final titleFinder = find.descendant(of: find.byType(CustomTitle), matching: find.text('Peticiones de amistad'),).hitTestable();
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('Menú superior selecciona y navega entre pantallas.', (tester) async 
  {
    // Montamos FriendsScreen.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: 
              FriendsScreen(),
          ),
        ),
      ));
    await tester.pumpAndSettle();

    // Cambia a la pestaña de "Solicitudes" en el menú superior.
    await tester.tap(find.text('Solicitudes'));
    await tester.pumpAndSettle();

    // Extraemos el color de fondo de un AnimatedContainer.
    Color? findBackgroundColor (String label)
    {
      final container = tester.widgetList<AnimatedContainer>
      (
        find.ancestor(of: find.text(label), matching: find.byType(AnimatedContainer)),
      ).first;

      return (container.decoration as BoxDecoration).color;
    }

    // Comprobamos que "Solicitudes" este seleccionado por defecto.
    final amigosColor = findBackgroundColor('Solicitudes');
    expect(amigosColor, const Color.fromRGBO(0, 0, 0, 0.5));

    // Al pulsar "Amigos" cambia de pantalla.
    final menuRow = find.byType(Row).first;
    await tester.tap(find.descendant(of: menuRow, matching: find.text('Amigos')));
    await tester.pumpAndSettle();
    expect(find.byType(FriendsListScreen), findsOneWidget);
    expect(find.descendant(of: find.byType(CustomTitle), matching: find.text('Amigos')), findsOneWidget);

    // Al pulsar "Buscar" cambia de pantalla.
    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchUsersScreen), findsOneWidget);
    expect(find.descendant(of: find.byType(CustomTitle), matching: find.text('Buscar usuarios')), findsOneWidget);
  });

  testWidgets('FriendRequestScreen muestra el nombre del usuario de la peticiones y los botones de aceptar y rechazar', (tester) async {
    // Stub que simula éxito inmediato de carga de peticiones.
    Future<void> fakeManage (String id, bool accept) async {}

    //Montamos la pantalla.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: 
              FriendRequestScreen(
                initialRequests: [
                  {"id" : "1", "solicitante": "Juan"},
                  {"id" : "2", "solicitante" : "María"}
                ],
                onManage: fakeManage,
              ),
          ),
        ),
      ));
    await tester.pumpAndSettle();

    // Comprobamos que se ven las peticiones.
    expect(find.text('Juan'), findsOneWidget);
    expect(find.text('María'), findsOneWidget);
    
    // Cada solicitante tiene un botón de aceptar y rechazar.
    expect(find.byIcon(Icons.close), findsNWidgets(2));
    expect(find.byIcon(Icons.check), findsNWidgets(2));
  });

  testWidgets('Los botones de aceptar y rechazar cumplen su función', (tester) async {
    // Stub que simula éxito inmediato de carga de peticiones.
    Future<void> fakeManage (String id, bool accept) async {}

    //Montamos la pantalla.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: 
              FriendRequestScreen(
                initialRequests: [
                  {"id" : "1", "solicitante": "Juan"},
                  {"id" : "2", "solicitante" : "María"}
                ],
                onManage: fakeManage,
              ),
          ),
        ),
      ));
    await tester.pumpAndSettle();

    // Ambas peticiones estan presentes.
    expect(find.text('Juan'), findsOneWidget);
    expect(find.text('María'), findsOneWidget);
    
    // Pulsamos el botón de rechazar.
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // Juan debe de desaparecer.
    expect(find.text('Juan'), findsNothing);
    expect(find.text('María'), findsOneWidget);

    // Pulsamos el botón de aceptar con Maria.
    await tester.tap(find.byIcon(Icons.check).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // María debe de desaparecer.
    expect(find.text('María'), findsNothing);
  });

  testWidgets('FriendsRequestScreen muestra el mensaje "No tienes peticiones pendientes" cuando la lista está vacia.', (tester) async 
  {
    // Stub que simula éxito inmediato de carga de peticiones.
    Future<void> fakeManage (String id, bool accept) async {}

    // Montamos la pantalla.
    await tester.pumpWidget
    (
      MaterialApp (
        home: Scaffold (
          body: FriendRequestScreen(
            initialRequests: [],
            onManage: fakeManage, 
          ),
        )
      )
    );
    await tester.pumpAndSettle();

    // Verificamos que aparece el mensaje de lista vacia.
    expect(find.text('No tienes solicitudes pendientes'), findsOneWidget);
  });
}