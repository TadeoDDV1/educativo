import 'ejercicio.dart';

/// Un tema dentro de una unidad. Contiene el video, el texto
/// y los ejercicios que ve el estudiante.
class Leccion {
  const Leccion({
    required this.id,
    required this.unidadId,
    required this.titulo,
    required this.orden,
    required this.texto,
    this.video,
    this.ejercicios = const [],
  });

  final String id;
  final String unidadId;
  final String titulo;
  final int orden;
  final String texto;

  /// Ruta del video. Puede ser null si la lección es solo texto.
  final String? video;

  final List<Ejercicio> ejercicios;

  /// Una lección puede no tener ejercicios (solo video o lectura).
  bool get tieneEjercicios => ejercicios.isNotEmpty;

  factory Leccion.fromJson(Map<String, dynamic> json, String unidadId) {
    return Leccion(
      id: json['id'] as String,
      unidadId: unidadId,
      titulo: json['titulo'] as String,
      orden: (json['orden'] as int?) ?? 0,
      texto: (json['texto'] as String?) ?? '',
      video: json['video'] as String?,
      ejercicios: (json['ejercicios'] as List<dynamic>? ?? [])
          .map((item) => Ejercicio.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
