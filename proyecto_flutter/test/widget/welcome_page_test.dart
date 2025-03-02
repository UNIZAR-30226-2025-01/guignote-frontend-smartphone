import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sota_caballo_rey/main.dart';
import 'package:sota_caballo_rey/screens/login_screen.dart';
import 'package:sota_caballo_rey/screens/register_screen.dart';

// Tests reutilizables
import 'tests_reutilizables.dart';

void main()
{
  testWidgets('La pantalla de bienvenida muestra los elementos correctos', (WidgetTester tester) async
  {
    // Carga la app completa 
    await tester.pumpWidget(const MyApp());

    // Verifica que el título de la app esté visible.
    await checkVisibility(tester, 'SOTA, CABALLO Y REY');

    // Verifica que el logo esté visible.
    expect(find.byKey(Key('logo-image')), findsOneWidget);

    // Verifica que los botones de 'Iniciar sesión' y 'Registrarse' estén visibles
    await checkVisibility(tester, 'Iniciar Sesión');
    await checkVisibility(tester, 'Registrarse');
  });


  testWidgets('El botón Iniciar Sesión navega a la pantalla de inicio de sesión', (WidgetTester tester) async
  {
    // Carga la app completa
    await tester.pumpWidget(const MyApp());

    // Verifica la navegación a la pantalla de inicio de sesión
    await checkNavigation(tester, 'Iniciar Sesión', LoginScreen);
  });

  testWidgets('El botón Registrarse navega a la pantalla de registro', (WidgetTester tester) async
  {
    // Carga la app completa
    await tester.pumpWidget(const MyApp());

    // Verifica la navegación a la pantalla de inicio de sesión
    await checkNavigation(tester, 'Registrarse', RegisterScreen);
  });
   
  

}
