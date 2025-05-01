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

void main() 
{
  testWidgets('SearchUsersScreen muestra titulo, fondo, decoraciones y la barra de teclado', (tester) async 
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

    // Cambia a la pestaña de "Buscar" en el menú superior.
    await tester.tap(find.text('Buscar'));
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

    // Titulo de Buscar amigos.
    final titleFinder = find.descendant(of: find.byType(CustomTitle), matching: find.text('Buscar usuarios'),).hitTestable();
    expect(titleFinder, findsOneWidget);

    // Barra de búsqueda y el botón de la lupa.
    final searchBar = find.byType(SearchBar);
    expect(searchBar, findsOneWidget);
    expect(find.descendant(of: searchBar, matching: find.byIcon(Icons.search)), findsOneWidget);
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

    // Cambia a la pestaña de "Buscar" en el menú superior.
    await tester.tap(find.text('Buscar'));
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

    // Comprobamos que Buscar este seleccionado por defecto.
    final amigosColor = findBackgroundColor('Buscar');
    expect(amigosColor, const Color.fromRGBO(0, 0, 0, 0.5));

    // Al pulsar "Amigos" cambia de pantalla.
    final menuRow = find.byType(Row).first;
    await tester.tap(find.descendant(of: menuRow, matching: find.text('Amigos')));
    await tester.pumpAndSettle();
    expect(find.byType(FriendsListScreen), findsOneWidget);
    expect(find.descendant(of: find.byType(CustomTitle), matching: find.text('Amigos')), findsOneWidget);

    // Al pulsar "Solicitudes" cambia de pantalla.
    await tester.tap(find.text('Solicitudes'));
    await tester.pumpAndSettle();
    expect(find.byType(FriendRequestScreen), findsOneWidget);
    expect(find.descendant(of: find.byType(CustomTitle), matching: find.text('Peticiones de amistad')), findsOneWidget);
  });

  testWidgets('SearchUsersScreen al escribir y pulsar lupoa, llama a _cargarUsuarios', (tester) async 
  {
    // Stub de búsqueda con delay.
    Future<List<Map<String,String>>> fakeSearch(String prefix) 
    {
      return Future.delayed(
        const Duration(milliseconds: 500),
        () => <Map<String,String>>[],
      );
    }

    // Montamos la pantalla.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(height: 32,),
              Expanded(child: SearchUsersScreen(onSearch: fakeSearch)),
            ],
          )
        ),
      ));
    await tester.pumpAndSettle();

    // Tecleamos en el SearchBar.
    final searchBar = find.byType(SearchBar);
    expect(searchBar, findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Jul');
    await tester.pump();

    // Pulsamos la lupa.
    await tester.tap(find.descendant(of: searchBar, matching: find.byIcon(Icons.search)));
    await tester.pump();

    // Tras pulsar debe salir algo.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Si avanzamos mas tiempo se termina la búsqueda y luego se oculta.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('SearchUsersScreen muestra nombre, foto y botón de enviar por cada usuario.', (tester) async 
  {
    // Stub de búsqueda con delay.
    Future<List<Map<String,String>>> fakeSearch(String prefix) async
    {
      final todos = <Map<String,String>>
      [
        {"id" : "1", "nombre" : "Paco", "imagen" : ""},
        {"id" : "2", "nombre" : "Ana", "imagen" : "https://example.com/a.png"},
      ];

      return todos.where((u) => u["nombre"]!.toLowerCase().contains(prefix.toLowerCase())).toList();
    }

    // Montamos la pantalla.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(height: 32,),
              Expanded(child: SearchUsersScreen(onSearch: fakeSearch)),
            ],
          )
        ),
      ));
    await tester.pumpAndSettle();

    // Tecleamos en el SearchBar.
    final searchBar = find.byType(SearchBar);
    expect(searchBar, findsOneWidget);
    await tester.enterText(find.byType(TextField), 'An');
    await tester.pump();
    await tester.tap(find.descendant(of: searchBar, matching: find.byIcon(Icons.search)));
    await tester.pump();

    // Esperamos a que el stub complete y desaparezca spinner.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Se comprueba que Ana aparece y Paco no lo hace.
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Paco'), findsNothing);

    // Se comprueba que la foto de Ana aparece.
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);

    // Aparece el botón de enviar solicitud.
    expect(find.widgetWithText(TextButton, 'Enviar solicitud'), findsOneWidget);
  }); 

  testWidgets('El botón de "Enviar solicitud cumple con su función.', (tester) async 
  {
    // Stub de búsqueda con delay.
    Future<List<Map<String,String>>> fakeSearch(String prefix) async
    {
      return
      [
        {"id" : "1", "nombre" : "Paco", "imagen" : ""},
        {"id" : "2", "nombre" : "Ana", "imagen" : ""},
      ];
    }

    // Spy para onSend.
    bool sendCalled = false;
    String? sentId;
    Future<void> fakeSend(String id) async 
    {
      sendCalled = true;
      sentId = id;
    }

    // Montamos la pantalla.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(height: 32,),
              Expanded(child: SearchUsersScreen(onSearch: fakeSearch, onSend: fakeSend,)),
            ],
          )
        ),
      ));
    await tester.pumpAndSettle();

    // Tecleamos en el SearchBar.
    final searchBar = find.byType(SearchBar);
    expect(searchBar, findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Pac');
    await tester.pump();
    await tester.tap(find.descendant(of: searchBar, matching: find.byIcon(Icons.search)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Se comprueba que aparece Paco.
    expect(find.text('Paco'), findsOneWidget);

    // Pulsamos "Enviar solicitud" para Paco.
    final sendButton = find.widgetWithText(TextButton, 'Enviar solicitud');
    await tester.tap(sendButton.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // Verificamos que el callback fue llamado con el ID correcto.
    expect(sendCalled, isTrue);
    expect(sentId, '1');
    
    // Verificamos que Paco no aparece pero Ana si.
    expect(find.text('Paco'), findsNothing);
    });

  testWidgets('SearchUsersScreen muestra el mensaje "Sin resultados" cuando la lista está vacia.', (tester) async 
  {
    // Montamos la pantalla.
    await tester.pumpWidget
    (
      MaterialApp (
        home: Scaffold (
          body: SearchUsersScreen(
          ),
        )
      )
    );
    await tester.pumpAndSettle();

    // Verificamos que aparece el mensaje de lista vacia.
    expect(find.text('Sin resultados'), findsOneWidget);
  });
}