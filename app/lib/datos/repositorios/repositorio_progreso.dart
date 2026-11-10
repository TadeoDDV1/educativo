import 'package:flutter/foundation.dart';

import '../modelos/progreso_leccion.dart';

/// Capa de DATOS: guarda el avance del estudiante.
///
/// Por ahora vive en memoria para que el prototipo funcione hoy.
/// Sección A lo reemplaza por SQLite manteniendo estos mismos métodos.
class RepositorioProgreso {
  final ValueNotifier<Map<String, ProgresoLeccion>> _progreso =
      ValueNotifier(<String, ProgresoLeccion>{});

  /// Las pantallas escuchan este valor para actualizarse solas.
  ValueListenable<Map<String, ProgresoLeccion>> get escuchar => _progreso;

  Map<String, ProgresoLeccion> get todo => _progreso.value;

  ProgresoLeccion? buscar(String leccionId) => _progreso.value[leccionId];

  bool estaCompletada(String leccionId) =>
      _progreso.value[leccionId]?.completada ?? false;

  void guardar(ProgresoLeccion progreso) {
    _progreso.value = {..._progreso.value, progreso.leccionId: progreso};
    // TODO Sección A: insertar en SQLite con pendienteSync = 1.
  }

  void borrarTodo() {
    _progreso.value = {};
    // TODO Sección A: DELETE FROM progreso.
  }

  /// Total de aciertos de todas las lecciones completadas.
  int get aciertosTotales =>
      _progreso.value.values.fold(0, (suma, item) => suma + item.aciertos);

  /// Total de preguntas respondidas.
  int get preguntasTotales =>
      _progreso.value.values.fold(0, (suma, item) => suma + item.total);
}
