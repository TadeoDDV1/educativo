import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../base_datos/base_datos.dart';
import '../modelos/progreso_leccion.dart';
import 'repositorio_progreso.dart';

/// Guarda el avance en SQLite para que no se pierda al cerrar la app.
///
/// La pantalla no cambia: sigue usando `escuchar`, `guardar`, `buscar`...
class ProgresoSqlite implements RepositorioProgreso {
  ProgresoSqlite({
    BaseDatos? baseDatos,
    this.usuarioId = 'demo-1',
  }) : _baseDatos = baseDatos ?? BaseDatos();

  final BaseDatos _baseDatos;
  final String usuarioId;

  final ValueNotifier<Map<String, ProgresoLeccion>> _progreso =
      ValueNotifier(<String, ProgresoLeccion>{});

  @override
  ValueListenable<Map<String, ProgresoLeccion>> get escuchar => _progreso;

  @override
  Map<String, ProgresoLeccion> get todo => _progreso.value;

  @override
  Future<void> iniciar() async {
    final bd = await _baseDatos.abrir();
    final filas = await bd.query(
      'progreso',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );

    final datos = <String, ProgresoLeccion>{};
    for (final fila in filas) {
      final progreso = ProgresoLeccion(
        leccionId: fila['leccionId'] as String,
        titulo: fila['titulo'] as String,
        aciertos: fila['aciertos'] as int,
        total: fila['total'] as int,
        actualizadoEn: DateTime.fromMillisecondsSinceEpoch(
          fila['actualizadoEn'] as int,
        ),
      );
      datos[progreso.leccionId] = progreso;
    }
    _progreso.value = datos;
  }

  @override
  ProgresoLeccion? buscar(String leccionId) => _progreso.value[leccionId];

  @override
  bool estaCompletada(String leccionId) =>
      _progreso.value[leccionId]?.completada ?? false;

  @override
  Future<void> guardar(ProgresoLeccion progreso) async {
    // 1) Actualiza la pantalla de inmediato.
    _progreso.value = {..._progreso.value, progreso.leccionId: progreso};

    // 2) Guarda en disco sin bloquear la interfaz.
    final bd = await _baseDatos.abrir();
    await bd.insert(
      'progreso',
      {
        'usuarioId': usuarioId,
        'leccionId': progreso.leccionId,
        'titulo': progreso.titulo,
        'aciertos': progreso.aciertos,
        'total': progreso.total,
        'actualizadoEn': progreso.actualizadoEn.millisecondsSinceEpoch,
        'pendienteSync': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> borrarTodo() async {
    _progreso.value = {};
    final bd = await _baseDatos.abrir();
    await bd.delete('progreso', where: 'usuarioId = ?', whereArgs: [usuarioId]);
  }

  @override
  int get aciertosTotales =>
      _progreso.value.values.fold(0, (suma, item) => suma + item.aciertos);

  @override
  int get preguntasTotales =>
      _progreso.value.values.fold(0, (suma, item) => suma + item.total);

  @override
  int get racha => calcularRacha(_progreso.value.values);

  /// Progresos que todavía no se han enviado al servidor.
  Future<List<ProgresoLeccion>> pendientesDeSincronizar() async {
    final bd = await _baseDatos.abrir();
    final filas = await bd.query(
      'progreso',
      where: 'usuarioId = ? AND pendienteSync = 1',
      whereArgs: [usuarioId],
    );
    return [
      for (final fila in filas)
        ProgresoLeccion(
          leccionId: fila['leccionId'] as String,
          titulo: fila['titulo'] as String,
          aciertos: fila['aciertos'] as int,
          total: fila['total'] as int,
          actualizadoEn: DateTime.fromMillisecondsSinceEpoch(
            fila['actualizadoEn'] as int,
          ),
        ),
    ];
  }

  /// Marca como enviadas las lecciones que el servidor ya recibió.
  Future<void> marcarSincronizadas(List<String> lecciones) async {
    if (lecciones.isEmpty) return;
    final bd = await _baseDatos.abrir();
    final marcadores = List.filled(lecciones.length, '?').join(',');
    await bd.update(
      'progreso',
      {'pendienteSync': 0},
      where: 'usuarioId = ? AND leccionId IN ($marcadores)',
      whereArgs: [usuarioId, ...lecciones],
    );
  }
}
