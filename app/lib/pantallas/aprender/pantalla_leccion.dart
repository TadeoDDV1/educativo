import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../logica/controlador_leccion.dart';
import '../../widgets/boton_principal.dart';
import 'pantalla_resultado.dart';

/// Pantalla donde el estudiante ve el contenido y responde los ejercicios.
class PantallaLeccion extends StatefulWidget {
  const PantallaLeccion({super.key, required this.leccion});

  final Leccion leccion;

  @override
  State<PantallaLeccion> createState() => _PantallaLeccionState();
}

class _PantallaLeccionState extends State<PantallaLeccion> {
  late final ControladorLeccion controlador;

  @override
  void initState() {
    super.initState();
    controlador = ControladorLeccion(widget.leccion);
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  void _avanzar() {
    if (controlador.esUltima) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PantallaResultado(
            leccion: widget.leccion,
            aciertos: controlador.aciertos,
            total: controlador.total,
          ),
        ),
      );
      return;
    }
    controlador.siguiente();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.leccion.titulo)),
      body: ListenableBuilder(
        listenable: controlador,
        builder: (context, _) {
          final tema = Theme.of(context);
          final ejercicio = controlador.ejercicioActual;

          return SafeArea(
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: controlador.total == 0
                      ? 0
                      : (controlador.indice + 1) / controlador.total,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _VideoPlaceholder(ruta: widget.leccion.video),
                      if (widget.leccion.texto.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(widget.leccion.texto, style: tema.textTheme.bodyLarge),
                      ],
                      if (ejercicio != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Pregunta ${controlador.indice + 1} de ${controlador.total}',
                          style: tema.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(ejercicio.pregunta,
                            style: tema.textTheme.titleMedium),
                        const SizedBox(height: 16),
                        for (var i = 0; i < ejercicio.opciones.length; i++)
                          _Opcion(
                            texto: ejercicio.opciones[i],
                            elegida: controlador.opcionElegida == i,
                            correcta: ejercicio.correcta == i,
                            mostrarResultado: controlador.respondida,
                            onTap: () => controlador.responder(i),
                          ),
                        if (controlador.respondida &&
                            ejercicio.explicacion.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _Retroalimentacion(
                            correcta: controlador.opcionElegida ==
                                ejercicio.correcta,
                            explicacion: ejercicio.explicacion,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: BotonPrincipal(
                    texto: controlador.esUltima ? 'Ver resultado' : 'Continuar',
                    habilitado: controlador.respondida ||
                        !controlador.hayEjercicios,
                    onPressed: _avanzar,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.texto,
    required this.elegida,
    required this.correcta,
    required this.mostrarResultado,
    required this.onTap,
  });

  final String texto;
  final bool elegida;
  final bool correcta;
  final bool mostrarResultado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    Color? colorFondo;
    Color? colorBorde;

    if (mostrarResultado && correcta) {
      colorFondo = Colors.green.shade50;
      colorBorde = Colors.green;
    } else if (mostrarResultado && elegida && !correcta) {
      colorFondo = Colors.red.shade50;
      colorBorde = Colors.red;
    } else if (elegida) {
      colorFondo = tema.colorScheme.primaryContainer;
      colorBorde = tema.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: mostrarResultado ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorFondo ?? tema.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorBorde ?? tema.dividerColor,
              width: 1.5,
            ),
          ),
          child: Text(texto),
        ),
      ),
    );
  }
}

class _Retroalimentacion extends StatelessWidget {
  const _Retroalimentacion({required this.correcta, required this.explicacion});

  final bool correcta;
  final String explicacion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: correcta ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correcta ? Icons.check_circle : Icons.lightbulb_outline,
            color: correcta ? Colors.green : Colors.orange.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              correcta ? '¡Correcto! $explicacion' : 'Casi. $explicacion',
            ),
          ),
        ],
      ),
    );
  }
}

/// Espacio del video. Sección C lo reemplaza por `video_player`
/// cuando existan los archivos de la Sección B.
class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({this.ruta});

  final String? ruta;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          Text(
            ruta == null ? 'Lección sin video' : 'Video de la lección',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
