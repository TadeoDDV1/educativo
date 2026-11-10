import 'package:flutter_test/flutter_test.dart';
import 'package:sabermovil/datos/repositorios/repositorio_contenido.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('carga el manifest y la unidad de ejemplo', () async {
    const repositorio = RepositorioContenido();
    final unidades = await repositorio.cargarUnidades();

    expect(unidades, isNotEmpty);

    final unidad = unidades.first;
    expect(unidad.id, 'prim-6-mate-u1');
    expect(unidad.titulo, 'Fracciones');
    expect(unidad.lecciones.length, greaterThanOrEqualTo(2));
    expect(unidad.lecciones.first.ejercicios, isNotEmpty);
  });
}
