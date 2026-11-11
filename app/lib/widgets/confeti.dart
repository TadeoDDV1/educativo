import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../nucleo/tema/tema_app.dart';

/// Lluvia de confeti en los cuatro colores primarios.
/// Se reproduce una sola vez y no bloquea los toques de lo que hay debajo.
class Confeti extends StatefulWidget {
  const Confeti({
    super.key,
    this.cantidad = 80,
    this.duracion = const Duration(milliseconds: 3200),
  });

  final int cantidad;
  final Duration duracion;

  @override
  State<Confeti> createState() => _ConfetiState();
}

class _ConfetiState extends State<Confeti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;
  late final List<_Pieza> _piezas;

  @override
  void initState() {
    super.initState();
    final azar = math.Random(2024);
    const colores = [colorRojo, colorAzul, colorAmarillo, colorVerde];
    _piezas = List.generate(widget.cantidad, (i) {
      return _Pieza(
        x: azar.nextDouble(),
        retraso: azar.nextDouble() * 0.35,
        velocidad: 0.75 + azar.nextDouble() * 0.5,
        ancho: 6 + azar.nextDouble() * 7,
        alto: 8 + azar.nextDouble() * 9,
        color: colores[i % colores.length],
        giro: (azar.nextDouble() - 0.5) * 14,
        fase: azar.nextDouble() * math.pi * 2,
        balanceo: 10 + azar.nextDouble() * 26,
        redonda: azar.nextDouble() < 0.3,
      );
    });
    _controlador = AnimationController(vsync: this, duration: widget.duracion);
    _controlador.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controlador.value = 1;
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _PintorConfeti(_piezas, _controlador),
        ),
      ),
    );
  }
}

class _Pieza {
  const _Pieza({
    required this.x,
    required this.retraso,
    required this.velocidad,
    required this.ancho,
    required this.alto,
    required this.color,
    required this.giro,
    required this.fase,
    required this.balanceo,
    required this.redonda,
  });

  final double x;
  final double retraso;
  final double velocidad;
  final double ancho;
  final double alto;
  final Color color;
  final double giro;
  final double fase;
  final double balanceo;
  final bool redonda;
}

class _PintorConfeti extends CustomPainter {
  _PintorConfeti(this.piezas, this.animacion) : super(repaint: animacion);

  final List<_Pieza> piezas;
  final Animation<double> animacion;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint();
    for (final pieza in piezas) {
      final double t = ((animacion.value - pieza.retraso) / (1 - pieza.retraso))
          .clamp(0.0, 1.0)
          .toDouble();
      if (t <= 0 || t >= 1) continue;

      final y = -20 + (size.height + 40) * t * pieza.velocidad;
      final x =
          pieza.x * size.width +
          math.sin(t * math.pi * 3 + pieza.fase) * pieza.balanceo;
      final double opacidad = t > 0.8 ? (1 - t) / 0.2 : 1.0;

      pincel.color = pieza.color.withValues(
        alpha: opacidad.clamp(0.0, 1.0).toDouble(),
      );
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * pieza.giro);
      if (pieza.redonda) {
        canvas.drawCircle(Offset.zero, pieza.ancho / 2, pincel);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: pieza.ancho,
              height: pieza.alto,
            ),
            const Radius.circular(2),
          ),
          pincel,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PintorConfeti anterior) => false;
}
