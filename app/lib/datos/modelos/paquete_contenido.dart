import 'unidad.dart';

/// Entrada del manifest: dice qué archivo de contenido se puede cargar.
class PaqueteContenido {
  const PaqueteContenido({
    required this.id,
    required this.titulo,
    required this.campo,
    required this.grado,
    required this.fase,
    required this.archivo,
  });

  final String id;
  final String titulo;

  /// Campo formativo: lenguajes | saberes | etica | humano
  final String campo;

  final int grado;
  final int fase;

  /// Ruta del JSON dentro de assets.
  final String archivo;

  factory PaqueteContenido.fromJson(Map<String, dynamic> json) {
    final grado = (json['grado'] as int?) ?? 0;
    return PaqueteContenido(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      campo:
          (json['campo'] as String?) ??
          Unidad.campoDesdeMateria((json['materia'] as String?) ?? 'general'),
      grado: grado,
      fase: (json['fase'] as int?) ?? Unidad.faseDeGrado(grado),
      archivo: json['archivo'] as String,
    );
  }
}
