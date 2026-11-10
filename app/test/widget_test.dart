// Prueba de humo: la app abre y muestra las tres secciones.
import 'package:flutter_test/flutter_test.dart';
import 'package:sabermovil/app.dart';

void main() {
  testWidgets('muestra las tres secciones principales', (tester) async {
    await tester.pumpWidget(const AppSaberMovil());
    await tester.pump();

    expect(find.text('SaberMóvil'), findsOneWidget);
    expect(find.text('Aprender'), findsOneWidget);
    expect(find.text('Progreso'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
