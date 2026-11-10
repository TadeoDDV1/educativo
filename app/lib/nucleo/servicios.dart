import 'package:flutter/foundation.dart';

import '../datos/repositorios/repositorio_contenido.dart';
import '../datos/repositorios/repositorio_progreso_sqlite.dart';
import '../datos/repositorios/repositorio_usuario.dart';
import '../datos/sincronizacion/servicio_sincronizacion.dart';
import 'constantes.dart';

/// Une los repositorios en un solo lugar para no pasarlos
/// de pantalla en pantalla.
///
/// Es un singleton sencillo: `Servicios.instancia.progreso`.
/// Si el proyecto crece, se puede cambiar por provider o riverpod.
class Servicios {
  Servicios._();

  static final Servicios instancia = Servicios._();

  final RepositorioContenido contenido = const RepositorioContenido();

  /// Guarda los datos del estudiante en el dispositivo.
  final RepositorioUsuario usuario = const RepositorioUsuario();

  /// Guarda el avance en SQLite.
  final ProgresoSqlite progreso = ProgresoSqlite();

  late final ServicioSincronizacion sincronizacion = ServicioSincronizacion(
    progreso: progreso,
    urlBase: Constantes.urlServidor,
  );

  /// Simula el estado de internet para poder demostrar el modo
  /// sin conexión durante el concurso.
  final ValueNotifier<bool> hayConexion = ValueNotifier<bool>(false);

  /// Se llama una vez al abrir la app: recupera el avance guardado.
  Future<void> iniciar() => progreso.iniciar();

  void alternarConexion() => hayConexion.value = !hayConexion.value;
}
