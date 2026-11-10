import 'package:flutter_test/flutter_test.dart';
import 'package:sabermovil/datos/modelos/unidad.dart';
import 'package:sabermovil/nucleo/nem.dart';

void main() {
  test('cada grado de primaria pertenece a su fase', () {
    expect(Nem.faseDeGrado(1), 3);
    expect(Nem.faseDeGrado(2), 3);
    expect(Nem.faseDeGrado(3), 4);
    expect(Nem.faseDeGrado(4), 4);
    expect(Nem.faseDeGrado(5), 5);
    expect(Nem.faseDeGrado(6), 5);
    expect(Nem.gradosDeFase(4), [3, 4]);
  });

  test('etiqueta del grado', () {
    expect(Nem.etiquetaGrado(3), '3.º de primaria · Fase 4');
  });

  test('las materias del contrato v1 se traducen a campos formativos', () {
    final unidad = Unidad.fromJson({
      'id': 'vieja',
      'titulo': 'Fracciones',
      'materia': 'matematicas',
      'grado': 6,
      'lecciones': <dynamic>[],
    });
    expect(unidad.campo, 'saberes');
    expect(unidad.fase, 5);
    expect(Unidad.campoDesdeMateria('espanol'), 'lenguajes');
  });

  test('hay cuatro campos formativos y siete ejes articuladores', () {
    expect(CampoFormativo.todos.length, 4);
    expect(ejesArticuladores.length, 7);
    expect(CampoFormativo.orden('etica'), 2);
    expect(CampoFormativo.orden('desconocido'), 4);
  });
}
