import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../nucleo/servicios.dart';

/// Muestra el avance guardado en el dispositivo.
class PantallaProgreso extends StatelessWidget {
  const PantallaProgreso({super.key});

  @override
  Widget build(BuildContext context) {
    final progreso = Servicios.instancia.progreso;
    final tema = Theme.of(context);

    return ValueListenableBuilder<Map<String, ProgresoLeccion>>(
      valueListenable: progreso.escuchar,
      builder: (context, datos, _) {
        if (datos.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Todavía no has completado lecciones.\n'
                'Entra a "Aprender" para empezar.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final aciertos = progreso.aciertosTotales;
        final total = progreso.preguntasTotales;
        final porcentaje = total == 0 ? 0 : aciertos * 100 ~/ total;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Mi progreso', style: tema.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Dato(
                    valor: '${datos.length}',
                    etiqueta: 'Lecciones',
                    icono: Icons.menu_book,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Dato(
                    valor: '$aciertos/$total',
                    etiqueta: 'Aciertos',
                    icono: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Dato(
                    valor: '$porcentaje %',
                    etiqueta: 'Promedio',
                    icono: Icons.percent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Lecciones completadas', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final item in datos.values)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(item.titulo),
                  subtitle: Text(
                    '${item.aciertos} de ${item.total} · ${item.calificacion} %',
                  ),
                  trailing: LinearProgressIndicator(
                    value: item.total == 0 ? 0 : item.aciertos / item.total,
                    minHeight: 6,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.valor,
    required this.etiqueta,
    required this.icono,
  });

  final String valor;
  final String etiqueta;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icono, color: tema.colorScheme.primary),
            const SizedBox(height: 8),
            Text(valor, style: tema.textTheme.titleLarge),
            Text(
              etiqueta,
              style: tema.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
