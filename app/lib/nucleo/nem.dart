import 'package:flutter/material.dart';

import '../datos/modelos/unidad.dart';

/// Estructura curricular de la Nueva Escuela Mexicana (Plan de Estudio 2022)
/// para educación primaria.
///
/// La primaria se organiza en tres fases y cuatro Campos formativos.
/// El contenido de cada unidad indica su `campo`, `fase` y `grado`.
class Nem {
  const Nem._();

  static const String nivel = 'primaria';
  static const int gradoMinimo = 1;
  static const int gradoMaximo = 6;

  /// Fase 3: 1.º y 2.º · Fase 4: 3.º y 4.º · Fase 5: 5.º y 6.º
  static int faseDeGrado(int grado) => Unidad.faseDeGrado(grado);

  /// Grados que forman una fase, por ejemplo `[3, 4]` para la Fase 4.
  static List<int> gradosDeFase(int fase) {
    final inicio = (fase - 3) * 2 + 1;
    return [inicio, inicio + 1];
  }

  /// Texto corto para la interfaz: «3.º de primaria · Fase 4».
  static String etiquetaGrado(int grado) =>
      '$grado.º de primaria · Fase ${faseDeGrado(grado)}';
}

/// Uno de los cuatro Campos formativos.
class CampoFormativo {
  const CampoFormativo({
    required this.id,
    required this.nombre,
    required this.nombreCorto,
    required this.icono,
    required this.color,
  });

  final String id;
  final String nombre;
  final String nombreCorto;
  final IconData icono;
  final Color color;

  static const CampoFormativo lenguajes = CampoFormativo(
    id: 'lenguajes',
    nombre: 'Lenguajes',
    nombreCorto: 'Lenguajes',
    icono: Icons.menu_book,
    color: Color(0xFF8E3B9E),
  );

  static const CampoFormativo saberes = CampoFormativo(
    id: 'saberes',
    nombre: 'Saberes y Pensamiento Científico',
    nombreCorto: 'Saberes',
    icono: Icons.science_outlined,
    color: Color(0xFF1565C0),
  );

  static const CampoFormativo etica = CampoFormativo(
    id: 'etica',
    nombre: 'Ética, Naturaleza y Sociedades',
    nombreCorto: 'Ética',
    icono: Icons.public,
    color: Color(0xFF2E7D32),
  );

  static const CampoFormativo humano = CampoFormativo(
    id: 'humano',
    nombre: 'De lo Humano y lo Comunitario',
    nombreCorto: 'Comunidad',
    icono: Icons.diversity_3,
    color: Color(0xFFD84315),
  );

  /// En el orden en que los presenta el Plan de Estudio.
  static const List<CampoFormativo> todos = [lenguajes, saberes, etica, humano];

  static CampoFormativo? buscar(String id) {
    for (final campo in todos) {
      if (campo.id == id) return campo;
    }
    return null;
  }

  /// Posición del campo para ordenar unidades; los desconocidos van al final.
  static int orden(String id) {
    final indice = todos.indexWhere((campo) => campo.id == id);
    return indice == -1 ? todos.length : indice;
  }
}

/// Los siete ejes articuladores del Plan de Estudio 2022.
const Map<String, String> ejesArticuladores = {
  'inclusion': 'Inclusión',
  'pensamiento_critico': 'Pensamiento crítico',
  'interculturalidad_critica': 'Interculturalidad crítica',
  'igualdad_genero': 'Igualdad de género',
  'vida_saludable': 'Vida saludable',
  'apropiacion_culturas':
      'Apropiación de las culturas a través de la lectura y la escritura',
  'artes': 'Artes y experiencias estéticas',
};
