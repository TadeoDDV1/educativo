import 'leccion.dart';

/// Una unidad de un Campo formativo de la Nueva Escuela Mexicana
/// (por ejemplo: "Fracciones en la vida diaria" en Saberes y Pensamiento
/// Científico, 4.º de primaria, Fase 4).
class Unidad {
  const Unidad({
    required this.id,
    required this.titulo,
    required this.campo,
    required this.grado,
    required this.fase,
    required this.objetivo,
    required this.lecciones,
    this.contenido = '',
    this.pda = const [],
    this.ejesArticuladores = const [],
    this.fuente = '',
  });

  final String id;
  final String titulo;

  /// lenguajes | saberes | etica | humano
  final String campo;

  /// 1 a 6 (solo primaria).
  final int grado;

  /// 3 (1.º–2.º), 4 (3.º–4.º) o 5 (5.º–6.º).
  final int fase;

  final String objetivo;
  final List<Leccion> lecciones;

  /// Contenido del Programa Sintético al que corresponde la unidad.
  final String contenido;

  /// Procesos de Desarrollo de Aprendizaje (PDA) que trabaja la unidad.
  final List<String> pda;

  /// Claves de los ejes articuladores (ver `nucleo/nem.dart`).
  final List<String> ejesArticuladores;

  /// Documento curricular del que se tomó el contenido.
  final String fuente;

  factory Unidad.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final grado = (json['grado'] as int?) ?? 0;
    return Unidad(
      id: id,
      titulo: json['titulo'] as String,
      campo:
          (json['campo'] as String?) ??
          campoDesdeMateria((json['materia'] as String?) ?? 'general'),
      grado: grado,
      fase: (json['fase'] as int?) ?? faseDeGrado(grado),
      objetivo: (json['objetivo'] as String?) ?? '',
      contenido: (json['contenido'] as String?) ?? '',
      pda: _listaDeTextos(json['pda']),
      ejesArticuladores: _listaDeTextos(json['ejesArticuladores']),
      fuente: (json['fuente'] as String?) ?? '',
      lecciones: (json['lecciones'] as List<dynamic>? ?? [])
          .map((item) => Leccion.fromJson(item as Map<String, dynamic>, id))
          .toList(),
    );
  }

  /// Fase 3: 1.º–2.º · Fase 4: 3.º–4.º · Fase 5: 5.º–6.º
  static int faseDeGrado(int grado) {
    if (grado <= 2) return 3;
    if (grado <= 4) return 4;
    return 5;
  }

  /// Traduce las materias del contrato v1 a su Campo formativo.
  static String campoDesdeMateria(String materia) {
    switch (materia) {
      case 'espanol':
        return 'lenguajes';
      case 'matematicas':
      case 'ciencias':
        return 'saberes';
      case 'historia':
      case 'geografia':
      case 'civica':
        return 'etica';
      default:
        return materia;
    }
  }

  static List<String> _listaDeTextos(Object? valor) {
    if (valor is! List) return const [];
    return valor.whereType<String>().toList();
  }
}
