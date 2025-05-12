import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sota_caballo_rey/src/screens/friends/friend_chat.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';

void main ()
{
  testWidgets('FriendChat muestra background, decoraciones, barra superior, nombre, input y botón de enviar', (tester) async 
  {
    // Montamos la pantalla.
    await tester.pumpWidget(
      MaterialApp(
        home: FriendChat(
          receptorId: '123', 
          receptorNom: 'Juan'
        ),
      )
    ); 
    await tester.pumpAndSettle();

    // fondo.
    expect(find.byType(Background), findsOneWidget);

    // Decoraciones de las esquinas.
    expect(find.byType(CornerDecoration), findsOneWidget);

    // botón de volver.
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // nombre del receptor.
    expect(find.text('Juan'), findsOneWidget);

    // Casilla de entrada del mensaje.
    expect(find.byType(TextField), findsOneWidget);

    // Botón de enviar el mensaje.
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('El boton de volver cumple su función', (tester) async 
  {
    // Montamos la pantalla.
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/chat',
        routes: {
          '/': (context) => const Scaffold(
            body: Center(child: Text('HOME PAGE')),
          ),
          '/chat': (context) => const FriendChat(
            receptorId: '123',
            receptorNom: 'Juan',
          ),
        },
      )
    );
    await tester.pumpAndSettle();

    // Pulsamos el botón de volver.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verificamos que estamos hemos vuelto a la pantalla anterior.
    expect(find.text('HOME PAGE'), findsOneWidget);
  });

  testWidgets('FriendChat inicia y carga los mensajes', (tester) async {
    // stub de mensajes y callback con delay.
    final fakeMensajes = [
      {
      'id'         : 'm1',
      'emisor'     : 'Juan',
      'contenido'  : '¡Hola!',
      'fecha_envio': '10:00',
    },
    {
      'id'         : 'm2',
      'emisor'     : 'Yo',
      'contenido'  : '¡Hey!',
      'fecha_envio': '10:01',
    },
    ];

    Future<List<Map<String,String>>> fakeLoad(String receptorId)
    {
      return Future.delayed(
        const Duration(milliseconds: 500),
        () => fakeMensajes,
      );
    }

    // Montamos la pantalla.
    await tester.pumpWidget(
      MaterialApp(
        home: FriendChat(receptorId: '123', receptorNom: 'Juan', onLoad: fakeLoad),
      )
    );
    await tester.pump();
    await tester.pump();

    // Avanzamos 500 ms para que fakeLoad termine.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Los mensajes se ven en pantalla.
    expect(find.text('¡Hola!'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('¡Hey!'), findsOneWidget);
    expect(find.text('10:01'), findsOneWidget);

    // Verifica que aparecen las burbujas de los mensajes.
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('FriendChat muestra mensajes alineados y con los colores correctos', (tester) async {
    // stub de mensajes y callback con delay.
    final fakeMensajes = [
      {
      'emisor'     : '123',
      'contenido'  : '¡Hola!',
      'fecha_envio': '10:00',
    },
    {
      'emisor'     : 'me',
      'contenido'  : '¡Hey!',
      'fecha_envio': '10:01',
    },
    ];

    Future<List<Map<String,String>>> fakeLoad(String receptorId)
    {
      return Future.value(fakeMensajes);
    }

    // Montamos la pantalla.
    await tester.pumpWidget(
      MaterialApp(
        home: FriendChat(receptorId: '123', receptorNom: 'Juan', onLoad: fakeLoad),
      )
    );
    await tester.pumpAndSettle();

    // Buscamos las alineaciones.
    final finderIzquierda = find.byWidgetPredicate((w) => w is Align && w.alignment == Alignment.centerLeft);
    final finderDerecha = find.byWidgetPredicate((w) => w is Align && w.alignment == Alignment.centerRight);
    expect(finderIzquierda, findsOneWidget);
    expect(finderDerecha, findsOneWidget);

    // Verificamos el color de fondo de cada burbuja.
    final containerIzq = tester.widget<Container>(
      find.descendant(of: finderIzquierda, matching: find.byType(Container))
    );
    final decoIzq = containerIzq.decoration as BoxDecoration;
    expect(decoIzq.color, Colors.grey[300]);

    final containerDer = tester.widget<Container>(
      find.descendant(of: finderDerecha, matching: find.byType(Container))
    );
    final decoDer = containerDer.decoration as BoxDecoration;
    expect(decoDer.color, Colors.blue);
  });

  testWidgets('FriendChat permite escribir y envia el mensaje', (tester) async
  {
    // Stub de carga inicial.
    Future<List<Map<String,String>>> fakeLoad(String _) async => [];

    // Spy para onSend.
    final enviados = <String>[];
    Future<void> fakeSend(String texto) async {
      enviados.add(texto);
    }

    // Montamos la pantalla.
    await tester.pumpWidget(
      MaterialApp(
        home: FriendChat(receptorId: '123', receptorNom: 'Juan', onLoad: fakeLoad, onSend: fakeSend),
      )
    );
    await tester.pumpAndSettle();

    // Comprueba que no hay mensajes.
    expect(find.text('¡Hola!'), findsNothing);

    // Escribe en el TextField y pulsa enviar.
    const mensaje = '¡Hola!';
    await tester.enterText(find.byType(TextField), mensaje);
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    // Comprobamos el mensaje.
    expect(enviados, ['¡Hola!']);
  });
}