import 'dart:convert';

import 'package:flutter/services.dart';

import '../modelos/modelos.dart';

/// Capa de DATOS: la única que sabe de dónde sale el contenido.
/// Hoy lee los JSON empaquetados en la app (assets).
/// Mañana la Sección A puede cambiarlo por SQLite sin tocar las pantallas.
class RepositorioContenido {
  const RepositorioContenido();

  /// Lee el manifest y devuelve la lista de unidades disponibles.
  Future<List<Unidad>> cargarUnidades() async {
    final textoManifest = await rootBundle.loadString(
      'assets/content/manifest.json',
    );
    final manifest = jsonDecode(textoManifest) as Map<String, dynamic>;
    final paquetes = (manifest['paquetes'] as List<dynamic>)
        .map((item) => PaqueteContenido.fromJson(item as Map<String, dynamic>))
        .toList();

    final unidades = <Unidad>[];
    for (final paquete in paquetes) {
      unidades.add(await cargarUnidad(paquete));
    }
    return unidades;
  }

  /// Lee un archivo de unidad y lo convierte en un objeto Unidad.
  Future<Unidad> cargarUnidad(PaqueteContenido paquete) async {
    final texto = await rootBundle.loadString(paquete.archivo);
    final json = jsonDecode(texto) as Map<String, dynamic>;
    return Unidad.fromJson(json);
  }
}
