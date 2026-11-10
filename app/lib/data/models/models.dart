/// Contratos de datos del MVP — punto de coordinación entre secciones.
///
/// Sección A puede modificarlos, pero todo cambio se documenta en
/// `docs/contratos-datos.md` y se avisa a B y C.
library;

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
  final int grado; // 1..6 primaria, 1..3 secundaria, 1..3 bachillerato
  final String nivel; // primaria | secundaria | bachillerato
  final String idioma; // es | lengua indígena
}

class Unidad {
  const Unidad({
    required this.id,
    required this.materiaId,
    required this.grado,
    required this.titulo,
    required this.orden,
    this.descargada = false,
  });

  final String id;
  final String materiaId;
  final int grado;
  final String titulo;
  final int orden;
  final bool descargada;

  factory Unidad.fromJson(Map<String, dynamic> json) => Unidad(
        id: json['id'] as String,
        materiaId: json['materia'] as String,
        grado: json['grado'] as int,
        titulo: json['titulo'] as String,
        orden: (json['orden'] as int?) ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'materiaId': materiaId,
        'grado': grado,
        'titulo': titulo,
        'orden': orden,
        'descargada': descargada ? 1 : 0,
      };
}

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
  final String? video; // ruta relativa en assets o ruta local descargada
  final List<Ejercicio> ejercicios;
}

class Ejercicio {
  const Ejercicio({
    required this.id,
    required this.leccionId,
    required this.pregunta,
    required this.opciones,
    required this.correcta,
    this.explicacion = '',
    this.imagen,
  });

  final String id;
  final String leccionId;
  final String pregunta;
  final List<String> opciones;
  final int correcta;
  final String explicacion;
  final String? imagen;
}

enum EstadoLeccion { bloqueada, disponible, enCurso, completada }

class Progreso {
  const Progreso({
    required this.usuarioId,
    required this.leccionId,
    required this.estado,
    this.intentos = 0,
    this.aciertos = 0,
  });

  final String usuarioId;
  final String leccionId;
  final EstadoLeccion estado;
  final int intentos;
  final int aciertos;
}
