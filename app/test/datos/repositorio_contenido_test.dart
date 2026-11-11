import 'package:flutter_test/flutter_test.dart';
import 'package:sabermovil/datos/repositorios/repositorio_contenido.dart';
import 'package:sabermovil/nucleo/nem.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repositorio = RepositorioContenido();

  test('carga el manifest y la primera unidad de 1.º', () async {
    final unidades = await repositorio.cargarUnidades();

    expect(unidades, isNotEmpty);

    final unidad = unidades.first;
    expect(unidad.id, 'prim-1-leng-u1');
    expect(unidad.grado, 1);
    expect(unidad.fase, 3);
    expect(unidad.campo, 'lenguajes');
    expect(unidad.pda, isNotEmpty);
    expect(unidad.lecciones.length, greaterThanOrEqualTo(2));
    expect(unidad.lecciones.first.ejercicios, isNotEmpty);
  });

  test('solo hay contenido de primaria, de 1.º a 6.º', () async {
    final unidades = await repositorio.cargarUnidades();
    for (final unidad in unidades) {
      expect(unidad.grado, inInclusiveRange(1, 6), reason: unidad.id);
      expect(unidad.fase, Nem.faseDeGrado(unidad.grado), reason: unidad.id);
      expect(CampoFormativo.buscar(unidad.campo), isNotNull, reason: unidad.id);
      for (final eje in unidad.ejesArticuladores) {
        expect(ejesArticuladores.containsKey(eje), isTrue, reason: unidad.id);
      }
    }
  });

  test('cada grado tiene los cuatro campos formativos', () async {
    for (var grado = 1; grado <= 6; grado++) {
      final unidades = await repositorio.cargarUnidadesDeGrado(grado);
      expect(unidades.every((u) => u.grado == grado), isTrue);
      expect(
        unidades.map((u) => u.campo).toSet(),
        CampoFormativo.todos.map((c) => c.id).toSet(),
        reason: '$grado.º grado',
      );
    }
  });

  test('los ids de lección no se repiten entre unidades', () async {
    final unidades = await repositorio.cargarUnidades();
    final ids = [
      for (final unidad in unidades)
        for (final leccion in unidad.lecciones) leccion.id,
    ];
    expect(ids.toSet().length, ids.length);
  });

  test('las respuestas correctas existen entre las opciones', () async {
    final unidades = await repositorio.cargarUnidades();
    for (final unidad in unidades) {
      for (final leccion in unidad.lecciones) {
        for (final ejercicio in leccion.ejercicios) {
          expect(
            ejercicio.correcta,
            inInclusiveRange(0, ejercicio.opciones.length - 1),
            reason: '${leccion.id}/${ejercicio.id}',
          );
        }
      }
    }
  });
}
