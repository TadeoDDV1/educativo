import 'package:flutter_test/flutter_test.dart';
import 'package:sabermovil/datos/modelos/usuario.dart';
import 'package:sabermovil/datos/repositorios/repositorio_usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cargar devuelve null cuando no hay usuario guardado', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio = RepositorioUsuario();

    expect(await repositorio.cargar(), isNull);
  });

  test('guarda, carga y borra el usuario', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio = RepositorioUsuario();

    const usuario = Usuario(
      id: 'demo-1',
      nombre: 'Ana',
      grado: 3,
      idioma: 'lengua indígena',
    );

    await repositorio.guardar(usuario);

    final cargado = await repositorio.cargar();
    expect(cargado, isNotNull);
    expect(cargado!.id, 'demo-1');
    expect(cargado.nombre, 'Ana');
    expect(cargado.grado, 3);
    expect(cargado.nivel, 'primaria');
    expect(cargado.idioma, 'lengua indígena');

    await repositorio.borrar();
    expect(await repositorio.cargar(), isNull);
  });

  test('un perfil antiguo de secundaria se ajusta a primaria', () async {
    SharedPreferences.setMockInitialValues({
      'usuario_id': 'viejo-1',
      'usuario_nombre': 'Luis',
      'usuario_grado': 9,
      'usuario_nivel': 'secundaria',
      'usuario_idioma': 'es',
    });

    final cargado = await RepositorioUsuario().cargar();
    expect(cargado, isNotNull);
    expect(cargado!.nivel, 'primaria');
    expect(cargado.grado, 6);
  });
}
