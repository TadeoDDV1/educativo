/// Persona que usa la app.
class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.grado,
    required this.nivel,
    required this.idioma,
  });

  final String id;
  final String nombre;
  final int grado;

  /// primaria | secundaria | bachillerato
  final String nivel;

  /// es | lengua indígena
  final String idioma;

  /// Usuario de ejemplo para la demo. Se reemplaza con el registro real.
  static const Usuario demo = Usuario(
    id: 'demo-1',
    nombre: 'Estudiante',
    grado: 6,
    nivel: 'primaria',
    idioma: 'es',
  );
}
