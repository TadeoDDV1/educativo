import 'package:flutter_test/flutter_test.dart';
import 'package:sabermovil/datos/base_datos/base_datos.dart';
import 'package:sabermovil/datos/modelos/progreso_leccion.dart';
import 'package:sabermovil/datos/repositorios/repositorio_progreso_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('guarda en SQLite y lo recupera en otra instancia', () async {
    final baseDatos = BaseDatos(
      fabrica: databaseFactoryFfi,
      ruta: inMemoryDatabasePath,
    );
    final repositorio = ProgresoSqlite(
      baseDatos: baseDatos,
      usuarioId: 'test',
    );
    await repositorio.iniciar();

    await repositorio.guardar(
      ProgresoLeccion(
        leccionId: 'l1',
        titulo: 'Fracciones',
        aciertos: 2,
        total: 2,
        actualizadoEn: DateTime.now(),
      ),
    );

    // Otra instancia: simula cerrar y volver a abrir la app.
    final repositorio2 = ProgresoSqlite(
      baseDatos: baseDatos,
      usuarioId: 'test',
    );
    await repositorio2.iniciar();

    expect(repositorio2.buscar('l1')?.aciertos, 2);
    expect(repositorio2.estaCompletada('l1'), isTrue);
    expect(repositorio2.aciertosTotales, 2);
    expect(repositorio2.preguntasTotales, 2);
    expect(repositorio2.racha, 1);

    await baseDatos.cerrar();
  });

  test('marca pendientes y luego sincronizados', () async {
    final baseDatos = BaseDatos(
      fabrica: databaseFactoryFfi,
      ruta: inMemoryDatabasePath,
    );
    final repositorio = ProgresoSqlite(baseDatos: baseDatos, usuarioId: 'test');

    await repositorio.guardar(
      ProgresoLeccion(
        leccionId: 'l1',
        titulo: 'Uno',
        aciertos: 1,
        total: 2,
        actualizadoEn: DateTime.now(),
      ),
    );

    expect((await repositorio.pendientesDeSincronizar()).length, 1);

    await repositorio.marcarSincronizadas(['l1']);
    expect(await repositorio.pendientesDeSincronizar(), isEmpty);

    await baseDatos.cerrar();
  });

  test('borrarTodo deja la base vacía', () async {
    final baseDatos = BaseDatos(
      fabrica: databaseFactoryFfi,
      ruta: inMemoryDatabasePath,
    );
    final repositorio = ProgresoSqlite(baseDatos: baseDatos, usuarioId: 'test');

    await repositorio.guardar(
      ProgresoLeccion(
        leccionId: 'l1',
        titulo: 'Uno',
        aciertos: 1,
        total: 1,
        actualizadoEn: DateTime.now(),
      ),
    );
    await repositorio.borrarTodo();

    expect(repositorio.todo, isEmpty);
    expect(await repositorio.pendientesDeSincronizar(), isEmpty);

    await baseDatos.cerrar();
  });
}
