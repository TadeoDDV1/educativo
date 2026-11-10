import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../nucleo/servicios.dart';
import '../../widgets/boton_principal.dart';

/// Se muestra al terminar una lección. Guarda el resultado una sola vez.
class PantallaResultado extends StatefulWidget {
  const PantallaResultado({
    super.key,
    required this.leccion,
    required this.aciertos,
    required this.total,
  });

  final Leccion leccion;
  final int aciertos;
  final int total;

  @override
  State<PantallaResultado> createState() => _PantallaResultadoState();
}

class _PantallaResultadoState extends State<PantallaResultado> {
  @override
  void initState() {
    super.initState();
    Servicios.instancia.progreso.guardar(
      ProgresoLeccion(
        leccionId: widget.leccion.id,
        titulo: widget.leccion.titulo,
        aciertos: widget.aciertos,
        total: widget.total,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final porcentaje =
        widget.total == 0 ? 100 : (widget.aciertos * 100 ~/ widget.total);
    final aprobado = porcentaje >= 60;

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                aprobado ? Icons.emoji_events : Icons.refresh,
                size: 96,
                color: aprobado ? Colors.amber.shade700 : tema.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                aprobado ? '¡Lección completada!' : '¡Sigue practicando!',
                style: tema.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Acertaste ${widget.aciertos} de ${widget.total}',
                style: tema.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('$porcentaje %', style: tema.textTheme.displaySmall),
              const SizedBox(height: 32),
              BotonPrincipal(
                texto: 'Volver a mi ruta',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
