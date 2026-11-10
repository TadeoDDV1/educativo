import 'leccion.dart';

/// Una unidad de una materia (por ejemplo: "Fracciones" en 6.º de primaria).
class Unidad {
  const Unidad({
    required this.id,
    required this.titulo,
    required this.materia,
    required this.grado,
    required this.objetivo,
    required this.lecciones,
  });

  final String id;
  final String titulo;
  final String materia;
  final int grado;
  final String objetivo;
  final List<Leccion> lecciones;

  factory Unidad.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return Unidad(
      id: id,
      titulo: json['titulo'] as String,
      materia: (json['materia'] as String?) ?? 'general',
      grado: (json['grado'] as int?) ?? 0,
      objetivo: (json['objetivo'] as String?) ?? '',
      lecciones: (json['lecciones'] as List<dynamic>? ?? [])
          .map((item) => Leccion.fromJson(item as Map<String, dynamic>, id))
          .toList(),
    );
  }
}
