import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sota_caballo_rey/src/screens/auth/login_screen.dart';
import 'package:sota_caballo_rey/main.dart';
import 'package:sota_caballo_rey/src/screens/auth/register_screen.dart';
import 'package:sota_caballo_rey/src/screens/auth/welcome_screen.dart';
import 'package:sota_caballo_rey/tests_config.dart' as tests_config;

import 'tests_reutilizables.dart';

void main() 
{
  // Configuración inicial de las pruebas
  tests_config.isTestEnvironment = true; // Establece el entorno de prueba para evitar la carga del video.

  group('LoginScreen Widget Tests', () 
  {
    testWidgets('La pantalla de inicio de sesión muestra el formulario de inicio de sesión.', (WidgetTester tester) async 
    {
      // Construye nuestra aplicación
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();


      // Navega a la pantalla de login después de la pantalla de bienvenida.
      await checkNavigation(tester, const Key('login-button'), LoginScreen);
      
      // Verifica que la entrada para el nombre esté presente.
      await checkWidgetVisibilityByKey(tester, const Key('_usernameField'));

      // Verifica que la entrada para la contraseña esté presente.
      await checkWidgetVisibilityByKey(tester, const Key('_passwordField'));

      // Verifica que el botón de inicio de sesión esté presente.
      await checkWidgetVisibilityByKey(tester, const Key('loginButton'));

    });

    testWidgets('Debe mostrar mensajes de error si los campos están vacíos', (WidgetTester tester) async 
    {
      // Construye nuestra aplicación
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navega a la pantalla de login después de la pantalla de bienvenida.
      await checkNavigation(tester, const Key('login-button'), LoginScreen);

      // Intenta presionar el botón de iniciar sesión sin ingresar datos.
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Verificamos que se muestre un mensaje de error para el campo de usuario.
      expect(find.byType(SnackBar), findsOneWidget);      
    });

    testWidgets('Debe alternar la visibilidad de la contraseña', (WidgetTester tester) async 
    {
      // Construye nuestra aplicación
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();


      // Navega a la pantalla de login después de la pantalla de bienvenida.
      await checkNavigation(tester, const Key('login-button'), LoginScreen);


      // Verifica que la contraseña está oculta inicialmente.
      await checkIconExists(tester, Icons.visibility_off);

      // Presiona el icono de visibilidad.
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Verifica que la contraseña ahora está visible.
      await checkIconExists(tester, Icons.visibility);
    });

    testWidgets('El botón ¿Aún no tienes cuenta? Crear una cuenta navega correctamente a la pantalla de crear cuenta.', (WidgetTester tester) async 
    {
      // Construye nuestra aplicación
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();


      // Navega a la pantalla de login después de la pantalla de bienvenida.
      await checkNavigation(tester, const Key('login-button'), LoginScreen);


      await checkNavigation(tester, const Key('registerButton'), RegisterScreen);

    });

    testWidgets('El botón de volver debe navegar correctamente a la pantalla de bienvenida.', (WidgetTester tester) async
    {
      // Construye nuestra aplicación
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();


      // Navega a la pantalla de login después de la pantalla de bienvenida.
      await checkNavigation(tester, const Key('login-button'), LoginScreen);


      await checkNavigation(tester, const Key('backButton') , WelcomeScreen);

    });
  });
}