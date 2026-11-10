// Prueba de humo: sin usuario guardado, la app abre en la bienvenida.
import 'package:flutter_test/flutter_test.dart';
import 'package:sabermovil/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('muestra la bienvenida cuando no hay usuario guardado', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AppSaberMovil());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a SaberMóvil'), findsOneWidget);
    expect(find.text('¿Cómo te llamas?'), findsOneWidget);
    expect(
      find.text('Se guarda en tu dispositivo, no necesitas internet'),
      findsOneWidget,
    );
    expect(find.text('Aprender'), findsNothing);
  });
}
