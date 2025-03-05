import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sota_caballo_rey/src/screens/auth/login_screen.dart';
import 'package:sota_caballo_rey/main.dart';
import 'package:sota_caballo_rey/src/screens/auth/register_screen.dart';
import 'package:sota_caballo_rey/src/screens/auth/welcome_screen.dart';

import 'tests_reutilizables.dart';

void main() 
{
  group('LoginScreen Widget Tests', () 
  {
    testWidgets('La pantalla de inicio de sesión muestra el formulario de inicio de sesión.', (WidgetTester tester) async 
    {
      // Construye nuestra aplicación
      await tester.pumpWidget(const MyApp());

      // Navega a la pantalla de login después de la pantalla de bienvenida.
      await checkNavigation(tester, 'Iniciar Sesión', LoginScreen);
      
      // Verifica que la entrada para el nombre esté presente.
      await checkWidgetVisibilityByKey(tester, const Key('usernameField'));

      // Verifica que la entrada para la contraseña esté presente.
      await checkWidgetVisibilityByKey(tester, const Key('passwordField'));

      // Verifica que el botón de inicio de sesión esté presente.
      await checkWidgetVisibilityByKey(tester, const Key('loginButton'));

    });

    testWidgets('Debe mostrar mensajes de error si los campos están vacíos', (WidgetTester tester) async 
    {
      // Construye nuestra aplicación
      await tester.pumpWidget(const MyApp());

      // Navega a la pantalla de login después de la pantalla de bienvenida.
      await checkNavigation(tester, 'Iniciar Sesión', LoginScreen);

      // Intenta presionar el botón de iniciar sesión sin ingresar datos.
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      // Verifica que se muestra un mensaje de error indicando que faltan datos.
      checkVisibility(tester, 'Faltan campos o la contraseña es incorrecta');
    });

    testWidgets('Debe alternar la visibilidad de la contraseña', (WidgetTester tester) async 
    {
      // Construye nuestra aplicación
      await tester.pumpWidget(const MyApp());

      // Navega a la pantalla de login después de la pantalla de bienvenida.
      await checkNavigation(tester, 'Iniciar Sesión', LoginScreen);

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

      // Navega a la pantalla de login después de la pantalla de bienvenida.
      await checkNavigation(tester, 'Iniciar Sesión', LoginScreen);

      await checkNavigation(tester, '¿Aún no tienes cuenta? Crear una cuenta', RegisterScreen);

    });

    testWidgets('El botón de volver debe navegar correctamente a la pantalla de bienvenida.', (WidgetTester tester) async
    {
      // Construye nuestra aplicación
      await tester.pumpWidget(const MyApp());

      // Navega a la pantalla de login después de la pantalla de bienvenida.
      await checkNavigation(tester, 'Iniciar Sesión', LoginScreen);

      await checkNavigation(tester, 'Volver', WelcomeScreen);

    });

    testWidgets('Si el inicio de sesión es correcto debe navegar a la pantalla principal', (WidgetTester tester) async 
    {
      // Construye nuestra aplicación
      await tester.pumpWidget(const MyApp());

      // Navega a la pantall de login después de la pantalla de bienvenida.
      await checkNavigation(tester, 'Iniciar Sesión', LoginScreen);
      
      // Ingresa datos válidos en los campos de usuario y contraseña.
      await tester.enterText(find.byKey(const Key('usernameField')), 'usuario');
      await tester.enterText(find.byKey(const Key('passwordField')), '123');


      // Verifica que la navegación fue exitosa.
      await checkNavigation(tester, 'Iniciar Sesión', WelcomeScreen);

    });
  });
}