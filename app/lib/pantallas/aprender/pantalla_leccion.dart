import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../logica/controlador_leccion.dart';
import '../../nucleo/tema/tema_app.dart';
import '../../widgets/boton_principal.dart';
import '../../widgets/entrada_animada.dart';
import 'pantalla_resultado.dart';

/// Pantalla donde el estudiante ve el contenido y responde los ejercicios.
///
/// [paleta] es el color de la materia: pinta la barra superior y los
/// detalles de la lección.
class PantallaLeccion extends StatefulWidget {
  const PantallaLeccion({
    super.key,
    required this.leccion,
    this.paleta = paletaAzul,
  });

  final Leccion leccion;
  final PaletaColor paleta;

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
    final paleta = widget.paleta;
    final colorSobre = paleta.base == colorAmarillo
        ? colorTinta
        : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: paleta.base,
        foregroundColor: colorSobre,
        title: Text(
          widget.leccion.titulo,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: colorSobre,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: controlador,
        builder: (context, _) {
          final tema = Theme.of(context);
          final ejercicio = controlador.ejercicioActual;
          final acerto =
              ejercicio != null &&
              controlador.opcionElegida == ejercicio.correcta;

          final double fraccion;
          if (!controlador.hayEjercicios) {
            fraccion = 1;
          } else {
            fraccion =
                (controlador.indice + (controlador.respondida ? 1 : 0)) /
                controlador.total;
          }

          final PaletaColor paletaBoton;
          if (controlador.respondida) {
            paletaBoton = acerto ? paletaVerde : paletaAmarilla;
          } else {
            paletaBoton = paleta;
          }

          return SafeArea(
            child: Column(
              children: [
                // Barra de avance, pegada a la barra superior.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                  decoration: BoxDecoration(
                    color: paleta.base,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(26),
                    ),
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: fraccion),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutCubic,
                    builder: (context, valor, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: valor,
                        minHeight: 14,
                        color: paleta.base == colorAmarillo
                            ? Colors.white
                            : colorAmarillo,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      EntradaAnimada(
                        child: _VideoPlaceholder(
                          ruta: widget.leccion.video,
                          paleta: paleta,
                        ),
                      ),
                      if (widget.leccion.texto.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        EntradaAnimada(
                          indice: 1,
                          child: _TextoLeccion(
                            texto: widget.leccion.texto,
                            paleta: paleta,
                          ),
                        ),
                      ],
                      if (ejercicio != null) ...[
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (hijo, animacion) =>
                              FadeTransition(
                                opacity: animacion,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.1, 0),
                                    end: Offset.zero,
                                  ).animate(animacion),
                                  child: hijo,
                                ),
                              ),
                          child: Column(
                            key: ValueKey<int>(controlador.indice),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: colorAmarilloSuave,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  'Pregunta ${controlador.indice + 1} de ${controlador.total}',
                                  style: tema.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: colorTinta,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                ejercicio.pregunta,
                                style: tema.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              for (var i = 0; i < ejercicio.opciones.length; i++)
                                _Opcion(
                                  key: ValueKey<String>(
                                    'opcion-${controlador.indice}-$i',
                                  ),
                                  indice: i,
                                  texto: ejercicio.opciones[i],
                                  elegida: controlador.opcionElegida == i,
                                  correcta: ejercicio.correcta == i,
                                  mostrarResultado: controlador.respondida,
                                  onTap: () => controlador.responder(i),
                                ),
                              if (controlador.respondida &&
                                  ejercicio.explicacion.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _Retroalimentacion(
                                  key: ValueKey<String>(
                                    'fb-${controlador.indice}',
                                  ),
                                  correcta: acerto,
                                  explicacion: ejercicio.explicacion,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: BotonPrincipal(
                    texto: controlador.esUltima ? 'Ver resultado' : 'Continuar',
                    icono: controlador.esUltima
                        ? Icons.emoji_events_rounded
                        : Icons.arrow_forward_rounded,
                    paleta: paletaBoton,
                    habilitado:
                        controlador.respondida || !controlador.hayEjercicios,
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

/// Explicación de la lección dentro de una tarjeta suave del color de la materia.
class _TextoLeccion extends StatelessWidget {
  const _TextoLeccion({required this.texto, required this.paleta});

  final String texto;
  final PaletaColor paleta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: paleta.suave,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: paleta.base.withValues(alpha: 0.35), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text(
                'Aprende',
                style: tema.textTheme.labelLarge?.copyWith(
                  color: paleta.oscuro,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: tema.textTheme.bodyLarge?.copyWith(
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Una respuesta posible. Cada letra (A, B, C, D) tiene su color primario.
/// Al responder, la correcta se pinta de verde con un saltito y la
/// equivocada de rojo con una sacudida.
class _Opcion extends StatelessWidget {
  const _Opcion({
    super.key,
    required this.indice,
    required this.texto,
    required this.elegida,
    required this.correcta,
    required this.mostrarResultado,
    required this.onTap,
  });

  final int indice;
  final String texto;
  final bool elegida;
  final bool correcta;
  final bool mostrarResultado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final letraPaleta = paletasPrimarias[indice % paletasPrimarias.length];
    final letra = String.fromCharCode(65 + indice);

    final acierto = mostrarResultado && correcta;
    final fallo = mostrarResultado && elegida && !correcta;
    final apagada = mostrarResultado && !correcta && !elegida;

    Color fondo = Colors.white;
    Color borde = colorTinta.withValues(alpha: 0.14);
    Color sombra = colorTinta.withValues(alpha: 0.10);
    if (acierto) {
      fondo = colorVerdeSuave;
      borde = colorVerde;
      sombra = colorVerdeOscuro;
    } else if (fallo) {
      fondo = colorRojoSuave;
      borde = colorRojo;
      sombra = colorRojoOscuro;
    }

    final Widget insignia;
    if (acierto) {
      insignia = const _InsigniaLetra(
        color: colorVerde,
        child: Icon(Icons.check_rounded, color: Colors.white, size: 22),
      );
    } else if (fallo) {
      insignia = const _InsigniaLetra(
        color: colorRojo,
        child: Icon(Icons.close_rounded, color: Colors.white, size: 22),
      );
    } else {
      insignia = _InsigniaLetra(
        color: letraPaleta.base,
        child: Text(
          letra,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: letraPaleta.base == colorAmarillo
                ? colorTinta
                : Colors.white,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: (fallo || (acierto && elegida)) ? 1 : 0),
        duration: const Duration(milliseconds: 550),
        builder: (context, valor, hijo) {
          final dx = fallo ? math.sin(valor * math.pi * 6) * (1 - valor) * 12 : 0.0;
          final escala = (acierto && elegida)
              ? 1 + math.sin(valor * math.pi) * 0.05
              : 1.0;
          return Transform.translate(
            offset: Offset(dx, 0),
            child: Transform.scale(scale: escala, child: hijo),
          );
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: apagada ? 0.55 : 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: mostrarResultado ? null : onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borde, width: 2.5),
                boxShadow: [BoxShadow(color: sombra, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  insignia,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      texto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorTinta,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InsigniaLetra extends StatelessWidget {
  const _InsigniaLetra({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(13),
      ),
      child: child,
    );
  }
}

class _Retroalimentacion extends StatelessWidget {
  const _Retroalimentacion({
    super.key,
    required this.correcta,
    required this.explicacion,
  });

  final bool correcta;
  final String explicacion;

  @override
  Widget build(BuildContext context) {
    final fondo = correcta ? colorVerdeSuave : colorAmarilloSuave;
    final borde = correcta ? colorVerde : colorAmarillo;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, valor, hijo) {
        final opacidad = Curves.easeOut.transform(valor);
        final escala = 0.9 + 0.1 * Curves.easeOutBack.transform(valor);
        return Opacity(
          opacity: opacidad.clamp(0.0, 1.0).toDouble(),
          child: Transform.scale(scale: escala, child: hijo),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borde, width: 2.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(correcta ? '🎉' : '💡', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                correcta ? '¡Correcto! $explicacion' : 'Casi. $explicacion',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colorTinta,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Espacio del video. Sección C lo reemplaza por `video_player`
/// cuando existan los archivos de la Sección B.
class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({this.ruta, required this.paleta});

  final String? ruta;
  final PaletaColor paleta;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorTinta, paleta.oscuro],
        ),
        boxShadow: const [BoxShadow(color: colorTinta, offset: Offset(0, 5))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -24,
            left: -20,
            child: _Punto(90, paleta.base.withValues(alpha: 0.35)),
          ),
          Positioned(
            bottom: -30,
            right: -10,
            child: _Punto(110, colorAmarillo.withValues(alpha: 0.22)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: colorAmarillo,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorAmarilloOscuro,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: colorTinta,
                  size: 44,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ruta == null ? 'Lección sin video' : 'Video de la lección',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto(this.diametro, this.color);

  final double diametro;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
