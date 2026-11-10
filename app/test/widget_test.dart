// Test de humo del shell. Sección C amplía esta suite.
import 'package:flutter_test/flutter_test.dart';
import 'package:sabermovil/main.dart';

void main() {
  testWidgets('el shell muestra las tres secciones', (tester) async {
    await tester.pumpWidget(const SaberMovilApp());

    expect(find.text('SaberMóvil'), findsOneWidget);
    expect(find.text('Aprender'), findsOneWidget);
    expect(find.text('Progreso'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
