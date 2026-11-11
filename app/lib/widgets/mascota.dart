import 'package:flutter/material.dart';

/// Un emoji que flota suavemente hacia arriba y abajo, como mascota.
/// Si el sistema pide menos animaciones, se queda quieto.
class Mascota extends StatefulWidget {
  const Mascota({super.key, this.emoji = '🦉', this.tamano = 56});

  final String emoji;
  final double tamano;

  @override
  State<Mascota> createState() => _MascotaState();
}

class _MascotaState extends State<Mascota>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controlador.stop();
    } else if (!_controlador.isAnimating) {
      _controlador.repeat(reverse: true);
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
      animation: _controlador,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controlador.value);
        return Transform.translate(
          offset: Offset(0, -8 * t),
          child: Transform.rotate(
            angle: (t - 0.5) * 0.18,
            child: Text(
              widget.emoji,
              style: TextStyle(fontSize: widget.tamano, height: 1),
            ),
          ),
        );
      },
    );
  }
}
