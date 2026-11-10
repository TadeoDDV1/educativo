import 'package:flutter_test/flutter_test.dart';
import 'package:sabermovil/datos/modelos/progreso_leccion.dart';
import 'package:sabermovil/datos/repositorios/repositorio_progreso.dart';
import 'package:sabermovil/logica/insignias.dart';

void main() {
  ProgresoLeccion progreso({
    required String id,
    int aciertos = 2,
    int total = 2,
    DateTime? fecha,
  }) {
    return ProgresoLeccion(
      leccionId: id,
      titulo: 'Lección $id',
      aciertos: aciertos,
      total: total,
      actualizadoEn: fecha ?? DateTime.now(),
    );
  }

  test('sin progreso no hay insignias', () {
    expect(calcularInsignias(progresos: [], racha: 0), isEmpty);
  });

  test('primera lección y perfección', () {
    final insignias = calcularInsignias(
      progresos: [progreso(id: 'l1')],
      racha: 1,
    );
    final codigos = insignias.map((item) => item.codigo).toList();

    expect(codigos, contains('primera_leccion'));
    expect(codigos, contains('perfecto'));
    expect(codigos, isNot(contains('racha_3')));
  });

  test('racha y cinco lecciones', () {
    final insignias = calcularInsignias(
      progresos: [
        for (var i = 0; i < 5; i++) progreso(id: 'l$i', aciertos: 1),
      ],
      racha: 3,
    );
    final codigos = insignias.map((item) => item.codigo).toList();

    expect(codigos, contains('cinco_lecciones'));
    expect(codigos, contains('racha_3'));
    expect(codigos, isNot(contains('perfecto')));
  });

  test('la racha cuenta días seguidos', () {
    final hoy = DateTime.now();
    final ayer = hoy.subtract(const Duration(days: 1));
    final anteayer = hoy.subtract(const Duration(days: 2));

    expect(
      calcularRacha([
        progreso(id: 'l1', fecha: hoy),
        progreso(id: 'l2', fecha: ayer),
        progreso(id: 'l3', fecha: anteayer),
      ]),
      3,
    );
  });

  test('la racha se corta si hay un día sin actividad', () {
    final hoy = DateTime.now();
    final haceTresDias = hoy.subtract(const Duration(days: 3));

    expect(
      calcularRacha([
        progreso(id: 'l1', fecha: hoy),
        progreso(id: 'l2', fecha: haceTresDias),
      ]),
      1,
    );
  });
}
