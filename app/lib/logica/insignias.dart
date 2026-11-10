import '../datos/modelos/progreso_leccion.dart';

/// Una insignia que el estudiante puede ganar.
/// Se usa un emoji para que la lógica no dependa de Flutter.
class Insignia {
  const Insignia({
    required this.codigo,
    required this.titulo,
    required this.descripcion,
    required this.emoji,
  });

  final String codigo;
  final String titulo;
  final String descripcion;
  final String emoji;
}

const List<Insignia> catalogoInsignias = [
  Insignia(
    codigo: 'primera_leccion',
    titulo: 'Primer paso',
    descripcion: 'Completaste tu primera lección',
    emoji: '🌱',
  ),
  Insignia(
    codigo: 'perfecto',
    titulo: 'Sin errores',
    descripcion: 'Acertaste todo en una lección',
    emoji: '🎯',
  ),
  Insignia(
    codigo: 'racha_3',
    titulo: 'Constancia',
    descripcion: 'Estudiaste 3 días seguidos',
    emoji: '🔥',
  ),
  Insignia(
    codigo: 'cinco_lecciones',
    titulo: 'Explorador',
    descripcion: 'Completaste 5 lecciones',
    emoji: '📚',
  ),
];

/// Calcula qué insignias ya ganó el estudiante según su progreso.
/// Son reglas simples: no hace falta base de datos ni inteligencia artificial.
List<Insignia> calcularInsignias({
  required Iterable<ProgresoLeccion> progresos,
  required int racha,
}) {
  final completadas = progresos.where((item) => item.completada).toList();
  final ganadas = <Insignia>[];

  if (completadas.isNotEmpty) ganadas.add(catalogoInsignias[0]);
  if (completadas.any((item) => item.calificacion == 100)) {
    ganadas.add(catalogoInsignias[1]);
  }
  if (racha >= 3) ganadas.add(catalogoInsignias[2]);
  if (completadas.length >= 5) ganadas.add(catalogoInsignias[3]);

  return ganadas;
}
