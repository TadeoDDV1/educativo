/// Persona que usa la app.
class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.grado,
    required this.idioma,
    this.nivel = 'primaria',
  });

  final String id;
  final String nombre;

  /// 1.º a 6.º de primaria.
  final int grado;

  /// La app es solo para primaria. El campo se conserva porque lo usan
  /// la base de datos y la API de sincronización.
  final String nivel;

  /// es | lengua indígena
  final String idioma;

  /// Usuario de ejemplo para la demo. Se reemplaza con el registro real.
  static const Usuario demo = Usuario(
    id: 'demo-1',
    nombre: 'Estudiante',
    grado: 6,
    idioma: 'es',
  );
}
