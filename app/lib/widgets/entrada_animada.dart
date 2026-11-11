import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Hace aparecer a su hijo con un fundido y un pequeño salto hacia arriba.
///
/// [indice] escalona la entrada: el elemento 0 aparece primero, el 1 un poco
/// después, etc. Así las listas "cobran vida" una pieza a la vez.
/// Si el sistema pide menos animaciones, aparece de golpe.
class EntradaAnimada extends StatefulWidget {
  const EntradaAnimada({
    super.key,
    required this.child,
    this.indice = 0,
    this.desplazamiento = 28,
  });

  final Widget child;
  final int indice;
  final double desplazamiento;

  @override
  State<EntradaAnimada> createState() => _EntradaAnimadaState();
}

class _EntradaAnimadaState extends State<EntradaAnimada>
    with SingleTickerProviderStateMixin {
  static const int _msBase = 480;
  static const int _msPorIndice = 80;

  late final AnimationController _controlador;
  late final Animation<double> _progreso;

  @override
  void initState() {
    super.initState();
    final retraso = math.min(widget.indice, 10) * _msPorIndice;
    final total = _msBase + retraso;
    _controlador = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: total),
    );
    _progreso = CurvedAnimation(
      parent: _controlador,
      curve: Interval(retraso / total, 1, curve: Curves.easeOutCubic),
    );
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
    return AnimatedBuilder(
      animation: _progreso,
      child: widget.child,
      builder: (context, hijo) {
        final valor = _progreso.value;
        return Opacity(
          opacity: valor.clamp(0.0, 1.0).toDouble(),
          child: Transform.translate(
            offset: Offset(0, (1 - valor) * widget.desplazamiento),
            child: hijo,
          ),
        );
      },
    );
  }
}
