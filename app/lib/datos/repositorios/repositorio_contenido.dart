import 'dart:convert';

import 'package:flutter/services.dart';

import '../modelos/modelos.dart';

/// Capa de DATOS: la única que sabe de dónde sale el contenido.
/// Hoy lee los JSON empaquetados en la app (assets).
/// Mañana la Sección A puede cambiarlo por SQLite sin tocar las pantallas.
class RepositorioContenido {
  const RepositorioContenido();

  static const String _rutaManifest = 'assets/content/manifest.json';

  /// Lee el manifest y devuelve los paquetes disponibles.
  Future<List<PaqueteContenido>> cargarPaquetes() async {
    final textoManifest = await rootBundle.loadString(_rutaManifest);
    final manifest = jsonDecode(textoManifest) as Map<String, dynamic>;
    return (manifest['paquetes'] as List<dynamic>)
        .map((item) => PaqueteContenido.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Devuelve todas las unidades de primaria (1.º a 6.º).
  Future<List<Unidad>> cargarUnidades() async {
    final paquetes = await cargarPaquetes();
    return _cargarVarias(paquetes);
  }

  /// Devuelve solo las unidades de un grado. Lee únicamente los archivos
  /// de ese grado para no cargar todo el contenido en memoria.
  Future<List<Unidad>> cargarUnidadesDeGrado(int grado) async {
    final paquetes = await cargarPaquetes();
    return _cargarVarias(paquetes.where((p) => p.grado == grado).toList());
  }

  /// Lee un archivo de unidad y lo convierte en un objeto Unidad.
  Future<Unidad> cargarUnidad(PaqueteContenido paquete) async {
    final texto = await rootBundle.loadString(paquete.archivo);
    final json = jsonDecode(texto) as Map<String, dynamic>;
    return Unidad.fromJson(json);
  }

  Future<List<Unidad>> _cargarVarias(List<PaqueteContenido> paquetes) async {
    final unidades = <Unidad>[];
    for (final paquete in paquetes) {
      unidades.add(await cargarUnidad(paquete));
    }
    return unidades;
  }
}
