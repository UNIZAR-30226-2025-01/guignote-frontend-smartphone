import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sota_caballo_rey/main.dart';
import 'package:sota_caballo_rey/src/screens/auth/login_screen.dart';
import 'package:sota_caballo_rey/src/screens/auth/register_screen.dart';
import 'package:sota_caballo_rey/tests_config.dart' as tests_config;

// Tests reutilizables
import 'tests_reutilizables.dart';

void main()
{
  tests_config.isTestEnvironment = true; // Establece el entorno de prueba para evitar la carga del video.

  group('WelcomePage Widgets Tests', ()
  {
    testWidgets('La pantalla de bienvenida muestra los elementos correctos', (WidgetTester tester) async
    {
      // Carga la app completa 
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verifica que el título de la app esté visible.
      await checkVisibility(tester, 'Sota, Caballo y Rey');

      // Verifica que el logo esté visible.
      expect(find.byKey(Key('logo-image')), findsOneWidget);

      // Verifica que los botones de 'Iniciar sesión' y 'Registrarse' estén visibles
      await checkWidgetVisibilityByKey(tester, Key('login-button'));
      await checkWidgetVisibilityByKey(tester, Key('register-button'));
    });


    testWidgets('El botón Iniciar Sesión navega a la pantalla de inicio de sesión', (WidgetTester tester) async
    {
      // Carga la app completa
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verifica la navegación a la pantalla de inicio de sesión
      await checkNavigation(tester, const Key('login-button') , LoginScreen);
    });

    testWidgets('El botón Registrarse navega a la pantalla de registro', (WidgetTester tester) async
    {
      // Carga la app completa
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verifica la navegación a la pantalla de inicio de sesión
      await checkNavigation(tester, const Key('register-button'), RegisterScreen);
    });
    
  });  

}
