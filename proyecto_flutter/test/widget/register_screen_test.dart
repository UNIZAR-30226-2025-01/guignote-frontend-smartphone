import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sota_caballo_rey/src/screens/auth/register_screen.dart';
import 'package:sota_caballo_rey/tests_config.dart' as tests_config;



void main()
{
  tests_config.isTestEnvironment = true; // Establece el entorno de prueba para evitar la carga del video.

  testWidgets('Validación de campos en RegisterScreen', (WidgetTester tester) async
  {
    await tester.pumpWidget(const MaterialApp(
      home: RegisterScreen(),
    ));

    // Pulsamos el botón de registro sin completar los campos
    await tester.tap(find.byKey(const Key('registerButton')));
    await tester.pump();

    // Se espera encontrar mensajes de error para los campos vacíos
    expect(find.text('Por favor, ingrese su nombre de usuario'), findsOneWidget);
    expect(find.text('Por favor, ingrese su email'), findsOneWidget);
    expect(find.text('Por favor, ingrese su contraseña'), findsOneWidget);
    expect(find.text('Confirme su contraseña'), findsOneWidget);

  });

    testWidgets('Contraseñas que no coinciden manejadas correctamente', (WidgetTester tester) async
  {
    await tester.pumpWidget(const MaterialApp(
      home: RegisterScreen(),
    ));

    await tester.enterText(find.byKey(const Key('usernameField')), 'testuser');
    await tester.enterText(find.byKey(const Key('emailField')), 'tests@gmail.com)');
    await tester.enterText(find.byKey(const Key('passwordField')), 'Testpassword123');
    await tester.enterText(find.byKey(const Key('confirmPasswordField')), 'DifferentPassword123');

    // Pulsamos el botón de registro sin completar los campos
    await tester.tap(find.byKey(const Key('registerButton')));
    await tester.pump();

    // Se espera encontrar un mensaje de error para las contraseñas que no coinciden
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);

  });


  

  
}
