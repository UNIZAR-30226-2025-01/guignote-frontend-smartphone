import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sota_caballo_rey/src/screens/user/profile_screen.dart';
import 'package:flutter/services.dart';

void main ()
{
  TestWidgetsFlutterBinding.ensureInitialized();

  // Define el canal usado por flutter_secure_storage.
  const MethodChannel channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  // Mapa en memoria para simular el almacenamiento de token.
  final Map<String, String> inMemoryStorage = {};

  // Configuramos el handler mock para simular un almacenamiento seguro en memoria, para poder escribir, leer y borrar el token. (El canal nativo no funciona en los tests).
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger .setMockMethodCallHandler(channel, (MethodCall call) async {
    switch (call.method) {
      case 'write':
        final key = call.arguments['key'] as String;
        final value = call.arguments['value'] as String?;
        if (value == null) {
          inMemoryStorage.remove(key);
        } 
        else {
          inMemoryStorage[key] = value;
        }
        return null;

      case 'read':
        final key = call.arguments['key'] as String;
        return inMemoryStorage[key]; 

      case 'delete':
        final key = call.arguments['key'] as String;
        inMemoryStorage.remove(key);
        return null;

      default:
        return null;
    }
   });


  group('ProfileScreen tests', () {
    testWidgets('Boton de logout navega a menu principal.', (WidgetTester tester) async
    {
      // Creamos token de prueba.
      inMemoryStorage['jwt_token'] = 'Token de prueba';

      // Configuramos el materialApp con las rutas necesarias.
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/profile',
        routes: {
          '/profile': (context) => const ProfileScreen(),
          '/login': (context) => const Scaffold(
            key: Key('loginScreen'),
            body: Center(child: Text('Login Screen.'),),
          ) // CAMBIAR A MENU PRINCIPAL CUANDO ESTE IMPLEMENTADO.
        },
      ));

      // Buscamos el boton de logout (con el icono).
      final logoutButton = find.byIcon(Icons.logout);
      expect(logoutButton, findsOneWidget);

      // Simulamos el tap en el boton de logout.
      await tester.tap(logoutButton);
      await tester.pump(); 
      await tester.pump(const Duration(seconds: 1));

      // Verificamos que se navega a la pantalla de login.
      expect(find.byKey(const Key('loginScreen')), findsOneWidget); // CAMBIAR A MENU PRINCIPAL CUANDO ESTE IMPLEMENTADO.

      // Comprobamos que el token se ha eliminado del almacenamiento simulado.
      expect(inMemoryStorage['jwt_token'], isNull);
    });

    testWidgets('El boton de volver navega a login', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/profile',
        routes: {
          '/profile': (context) => const ProfileScreen(),
          '/login': (context) => const Scaffold(
            key: Key('loginScreen'),
            body: Center(child: Text('Login Screen.'),),
          )
        }
      ));

      // Buscamos el boton de voler (Con el icono).
      final backButton = find.byIcon(Icons.reply);
      expect(backButton, findsOneWidget);

      // Simulamos el tap en el boton de volver.
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verificamos que se navega a la pantalla de login.
      expect(find.byKey(const Key('loginScreen')), findsOneWidget);
    });
  });
}

