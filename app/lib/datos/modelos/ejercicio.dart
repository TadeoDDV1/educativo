/// Una pregunta de una lección.
class Ejercicio {
  const Ejercicio({
    required this.id,
    required this.pregunta,
    required this.opciones,
    required this.correcta,
    this.explicacion = '',
    this.imagen,
  });

  final String id;
  final String pregunta;
  final List<String> opciones;
  final int correcta;
  final String explicacion;
  final String? imagen;

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    return Ejercicio(
      id: json['id'] as String,
      pregunta: json['pregunta'] as String,
      opciones: (json['opciones'] as List<dynamic>)
          .map((opcion) => opcion as String)
          .toList(),
      correcta: json['correcta'] as int,
      explicacion: (json['explicacion'] as String?) ?? '',
      imagen: json['imagen'] as String?,
    );
  }
}
