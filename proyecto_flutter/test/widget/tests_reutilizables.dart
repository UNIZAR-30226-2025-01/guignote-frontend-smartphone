import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Este test verifica si un texto específico es visible en la pantalla.
Future<void> checkVisibility(WidgetTester tester, String text) async
{
  expect(find.text(text), findsOneWidget);
}

/// Este test verifica la navegación de un botón
Future<void> checkNavigation(WidgetTester tester, String buttonText, Type expectedPageType) async
{
  final button = find.text(buttonText);
  
  // Verificación de que el botón exista.
  expect(button,findsOneWidget);

  // Simula la pulsación 
  await tester.tap(button);
  await tester.pumpAndSettle();

  // Verifica que el texto de la nueva pantalla aparece
  expect(find.byType(expectedPageType), findsOneWidget);
}

/// Este test verifica que un icono existe, útil para IconButtons
Future<void> checkIconExists(WidgetTester tester, IconData icon) async
{
  expect(find.byIcon(icon), findsOneWidget);
}


/// Este test verifica que un widget específico (por tipo) exista en la pantalla.

Future<void> checkWidgetExits(WidgetTester tester, Type widgetType) async
{
  expect(find.byType(widgetType), findsOneWidget);
}

/// Este test verifica si un widget específico con un Key es visible en la pantalla.
Future<void> checkWidgetVisibilityByKey(WidgetTester tester, Key key) async 
{
  expect(find.byKey(key), findsOneWidget);
}

/// Este test verifica si un widget específico está presente dentro de un contenedor (por ejemplo, Column).
Future<void> checkWidgetInsideContainer(WidgetTester tester, Type containerType, String widgetText) async 
{
  expect(find.descendant(of: find.byType(containerType), matching: find.text(widgetText)), findsOneWidget);
}


/// Este test verifica que un `TextField` contenga el texto esperado.
Future<void> checkTextFieldValue(WidgetTester tester, Key key, String expectedText) async 
{
  final textField = find.byKey(key);
  expect(textField, findsOneWidget);
  expect(((textField.evaluate().single.widget) as TextField).controller!.text, expectedText);
}

/// Este test verifica que un botón esté deshabilitado (es decir, no interactuable).
Future<void> checkButtonDisabled(WidgetTester tester, String buttonText) async
{
  final button = find.text(buttonText);
  expect(button, findsOneWidget);
  expect(tester.widget<ElevatedButton>(button).enabled, false);
}

/// Este test verifica si un `Switch` o `Checkbox` está en el estado esperado.
Future<void> checkSwitchState(WidgetTester tester, Key key, bool expectedState) async 
{
  final switchWidget = find.byKey(key);
  expect(switchWidget, findsOneWidget);
  
  final switchState = tester.widget<Switch>(switchWidget).value;
  expect(switchState, expectedState);
}

/// Este test verifica si un SnackBar es visible en la pantalla.
Future<void> checkSnackBarVisible(WidgetTester tester, String message) async 
{
  expect(find.byWidgetPredicate((widget) =>
      widget is SnackBar && widget.content is Text && (widget.content as Text).data == message), findsOneWidget);
}

/// Este test verifica si un `Dialog` aparece en la pantalla.
Future<void> checkDialogVisible(WidgetTester tester, String dialogText) async 
{
  expect(find.byType(AlertDialog), findsOneWidget);
  expect(find.text(dialogText), findsOneWidget);
}





