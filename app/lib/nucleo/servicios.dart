import 'package:flutter/foundation.dart';

import '../datos/repositorios/repositorio_contenido.dart';
import '../datos/repositorios/repositorio_progreso.dart';

/// Une los repositorios en un solo lugar para no pasarlos
/// de pantalla en pantalla.
///
/// Es un singleton sencillo: `Servicios.instancia.progreso`.
/// Si el proyecto crece, se puede cambiar por provider o riverpod.
class Servicios {
  Servicios._();

  static final Servicios instancia = Servicios._();

  final RepositorioContenido contenido = const RepositorioContenido();
  final RepositorioProgreso progreso = RepositorioProgreso();

  /// Simula el estado de internet para poder demostrar el modo
  /// sin conexión durante el concurso.
  final ValueNotifier<bool> hayConexion = ValueNotifier<bool>(false);

  void alternarConexion() => hayConexion.value = !hayConexion.value;
}
