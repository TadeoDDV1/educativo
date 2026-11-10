/// Resultado de una lección terminada.
class ProgresoLeccion {
  const ProgresoLeccion({
    required this.leccionId,
    required this.titulo,
    required this.aciertos,
    required this.total,
  });

  final String leccionId;
  final String titulo;
  final int aciertos;
  final int total;

  bool get completada => total > 0;

  /// Calificación de 0 a 100.
  int get calificacion => total == 0 ? 0 : (aciertos * 100 ~/ total);
}
