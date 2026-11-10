import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../nucleo/servicios.dart';
import '../../widgets/tarjeta_leccion.dart';
import 'pantalla_leccion.dart';

/// Muestra las unidades y sus lecciones en orden.
/// Una lección se desbloquea cuando la anterior está completada.
class PantallaRuta extends StatelessWidget {
  const PantallaRuta({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Unidad>>(
      future: Servicios.instancia.contenido.cargarUnidades(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No se pudo cargar el contenido:\n${snapshot.error}'),
            ),
          );
        }

        final unidades = snapshot.data ?? [];
        return ValueListenableBuilder<Map<String, ProgresoLeccion>>(
          valueListenable: Servicios.instancia.progreso.escuchar,
          builder: (context, _, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Mi ruta de aprendizaje',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                const Text('6.º de primaria · Contenido descargado'),
                const SizedBox(height: 16),
                ..._construirBloques(context, unidades),
              ],
            );
          },
        );
      },
    );
  }

  /// Arma las tarjetas de todas las unidades en orden.
  /// `desbloqueada` empieza en true: la primera lección siempre está abierta.
  List<Widget> _construirBloques(BuildContext context, List<Unidad> unidades) {
    var desbloqueada = true;
    final bloques = <Widget>[];

    for (final unidad in unidades) {
      final tarjetas = <Widget>[];
      for (final leccion in unidad.lecciones) {
        final completada =
            Servicios.instancia.progreso.estaCompletada(leccion.id);
        tarjetas.add(
          TarjetaLeccion(
            titulo: leccion.titulo,
            completada: completada,
            bloqueada: !desbloqueada,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PantallaLeccion(leccion: leccion),
                ),
              );
            },
          ),
        );
        desbloqueada = completada;
      }
      bloques.add(_BloqueUnidad(unidad: unidad, tarjetas: tarjetas));
    }
    return bloques;
  }
}

class _BloqueUnidad extends StatelessWidget {
  const _BloqueUnidad({required this.unidad, required this.tarjetas});

  final Unidad unidad;
  final List<Widget> tarjetas;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(unidad.materia.toUpperCase(), style: tema.textTheme.labelSmall),
            Text(unidad.titulo, style: tema.textTheme.titleLarge),
            if (unidad.objetivo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(unidad.objetivo, style: tema.textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            ...tarjetas,
          ],
        ),
      ),
    );
  }
}
