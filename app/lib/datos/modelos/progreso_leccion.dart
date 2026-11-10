/// Resultado de una lección terminada.
class ProgresoLeccion {
  const ProgresoLeccion({
    required this.leccionId,
    required this.titulo,
    required this.aciertos,
    required this.total,
    required this.actualizadoEn,
  });

  final String leccionId;
  final String titulo;
  final int aciertos;
  final int total;
  final DateTime actualizadoEn;

  bool get completada => total > 0;

  /// Calificación de 0 a 100.
  int get calificacion => total == 0 ? 0 : (aciertos * 100 ~/ total);
}
