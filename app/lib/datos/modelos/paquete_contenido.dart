/// Entrada del manifest: dice qué archivo de contenido se puede cargar.
class PaqueteContenido {
  const PaqueteContenido({
    required this.id,
    required this.titulo,
    required this.materia,
    required this.grado,
    required this.archivo,
  });

  final String id;
  final String titulo;
  final String materia;
  final int grado;

  /// Ruta del JSON dentro de assets.
  final String archivo;

  factory PaqueteContenido.fromJson(Map<String, dynamic> json) {
    return PaqueteContenido(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      materia: (json['materia'] as String?) ?? 'general',
      grado: (json['grado'] as int?) ?? 0,
      archivo: json['archivo'] as String,
    );
  }
}
