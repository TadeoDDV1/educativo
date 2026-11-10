import 'package:flutter/foundation.dart';

import '../modelos/progreso_leccion.dart';

/// Contrato de lo que debe saber hacer cualquier repositorio de progreso.
/// La UI solo conoce esta interfaz, no si guarda en memoria o en SQLite.
abstract class RepositorioProgreso {
  ValueListenable<Map<String, ProgresoLeccion>> get escuchar;
  Map<String, ProgresoLeccion> get todo;

  /// Carga lo que ya estaba guardado. Se llama al iniciar la app.
  Future<void> iniciar();

  ProgresoLeccion? buscar(String leccionId);
  bool estaCompletada(String leccionId);
  Future<void> guardar(ProgresoLeccion progreso);
  Future<void> borrarTodo();

  int get aciertosTotales;
  int get preguntasTotales;

  /// Días seguidos con al menos una lección completada.
  int get racha;
}

/// Implementación en memoria: sirve para tests y como respaldo.
class ProgresoMemoria implements RepositorioProgreso {
  final ValueNotifier<Map<String, ProgresoLeccion>> _progreso =
      ValueNotifier(<String, ProgresoLeccion>{});

  @override
  ValueListenable<Map<String, ProgresoLeccion>> get escuchar => _progreso;

  @override
  Map<String, ProgresoLeccion> get todo => _progreso.value;

  @override
  Future<void> iniciar() async {}

  @override
  ProgresoLeccion? buscar(String leccionId) => _progreso.value[leccionId];

  @override
  bool estaCompletada(String leccionId) =>
      _progreso.value[leccionId]?.completada ?? false;

  @override
  Future<void> guardar(ProgresoLeccion progreso) async {
    _progreso.value = {..._progreso.value, progreso.leccionId: progreso};
  }

  @override
  Future<void> borrarTodo() async => _progreso.value = {};

  @override
  int get aciertosTotales =>
      _progreso.value.values.fold(0, (suma, item) => suma + item.aciertos);

  @override
  int get preguntasTotales =>
      _progreso.value.values.fold(0, (suma, item) => suma + item.total);

  @override
  int get racha => calcularRacha(_progreso.value.values);
}

/// Cuenta días consecutivos con actividad, empezando por hoy o ayer.
int calcularRacha(Iterable<ProgresoLeccion> progresos) {
  final dias = progresos
      .map((item) {
        final fecha = item.actualizadoEn;
        return DateTime(fecha.year, fecha.month, fecha.day);
      })
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  if (dias.isEmpty) return 0;

  final hoy = DateTime.now();
  final diaHoy = DateTime(hoy.year, hoy.month, hoy.day);
  final diferencia = diaHoy.difference(dias.first).inDays;
  if (diferencia > 1) return 0;

  var racha = 1;
  for (var i = 1; i < dias.length; i++) {
    if (dias[i - 1].difference(dias[i]).inDays == 1) {
      racha++;
    } else {
      break;
    }
  }
  return racha;
}
