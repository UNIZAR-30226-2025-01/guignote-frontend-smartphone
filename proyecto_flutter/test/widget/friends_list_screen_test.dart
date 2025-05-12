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

void main() {
  testWidgets('FriendsScreen muestra titulo, fondo, decoraciones y botones', (tester) async 
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
    expect(find.text('Amigos'), findsNWidgets(3));
    expect(find.text('Solicitudes'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);

    // Titulo de Amigos.
    final titleFinder = find.descendant(of: find.byType(CustomTitle), matching: find.text('Amigos'),).hitTestable();
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

    // Extraemos el color de fondo de un AnimatedContainer.
    Color? findBackgroundColor (String label)
    {
      final container = tester.widgetList<AnimatedContainer>
      (
        find.ancestor(of: find.text(label), matching: find.byType(AnimatedContainer)),
      ).first;

      return (container.decoration as BoxDecoration).color;
    }

    // Comprobamos que Amigos este seleccionado por defecto.
    final amigosColor = findBackgroundColor('Amigos');
    expect(amigosColor, const Color.fromRGBO(0, 0, 0, 0.5));

    // Al pulsar "Solicitudes" cambia de pantalla.
    await tester.tap(find.text('Solicitudes'));
    await tester.pumpAndSettle();
    expect(find.byType(FriendRequestScreen), findsOneWidget);
    expect(find.descendant(of: find.byType(CustomTitle), matching: find.text('Peticiones de amistad')), findsOneWidget);

    // Al pulsar "Buscar" cambia de pantalla.
    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchUsersScreen), findsOneWidget);
    expect(find.descendant(of: find.byType(CustomTitle), matching: find.text('Buscar usuarios')), findsOneWidget);
  });

  testWidgets('FriendsListScreen muestra nombre, avatar e incono delete por cada amigo.', (tester) async 
  {
    // Montamos la pantalla.
    await tester.pumpWidget
    (
      const MaterialApp (
        home: Scaffold (
          body: FriendsListScreen(
            initialFriends: [
              {"id" : "1", "nombre" : "Paco", "imagen" : ""},
              {"id" : "2", "nombre" : "Ana", "imagen" : "https://example.com/a.png"},
            ],
          ),
        )
      )
    );
    await tester.pumpAndSettle();

    // Comprobamos que los dos nombres están en pantalla.
    expect(find.text('Paco'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);

    // Comprobamos el avatar por defecto y las imagenes.
    expect(find.byIcon(Icons.person), findsNWidgets(2));
    expect(find.byType(Image), findsOneWidget); //Image.network en test devuelve 400 lo que hace error y carga un icono de persona (no obstante se sigue evaluando como una imagen aunque haya dos iconos).

    // Comprobamnos que hay dos botones de eliminar.
    expect(find.widgetWithIcon(IconButton, Icons.delete), findsNWidgets(2));
  });

  testWidgets('Al pulsar el botón de eliminar amigo, este lleva a cabo su función.', (tester) async 
  {
    // stub que simula exito inmediato.
    Future<void> fakeDelete (String id) async
    {
      return;
    }

    // Montamos la pantalla.
    await tester.pumpWidget
    (
      MaterialApp (
        home: Scaffold (
          body: FriendsListScreen(
            initialFriends: [
              {"id" : "1", "nombre" : "Paco", "imagen" : ""},
              {"id" : "2", "nombre" : "Ana", "imagen" : "https://example.com/a.png"},
            ],
            onDelete: fakeDelete,
          ),
        )
      )
    );
    await tester.pumpAndSettle();

    // Comprobamos que los dos nombres están en pantalla.
    expect(find.text('Paco'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);

    // Tap en el botón.
    final deleteButtons = find.widgetWithIcon(IconButton, Icons.delete);
    expect(deleteButtons, findsNWidgets(2));
    await tester.tap(deleteButtons.first);

    // Avanzamos la animación.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // Comprueba Paco ha desaparecido.
    expect(find.text('Paco'), findsNothing);
    expect(find.text('Ana'), findsOneWidget);
  });

  testWidgets('FriendsListScreen muestra el mensaje "No tienes amigos" cuando la lista está vacia.', (tester) async 
  {
    // Montamos la pantalla.
    await tester.pumpWidget
    (
      MaterialApp (
        home: Scaffold (
          body: FriendsListScreen(
            initialFriends: [],
            onDelete: (_) async {},
          ),
        )
      )
    );
    await tester.pumpAndSettle();

    // Verificamos que aparece el mensaje de lista vacia.
    expect(find.text('No tienes amigos'), findsOneWidget);
  });
}

