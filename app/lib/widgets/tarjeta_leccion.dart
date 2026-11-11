import 'package:flutter/material.dart';

import '../nucleo/tema/tema_app.dart';

/// Tarjeta de una lección dentro de la ruta.
///
/// - Completada: insignia verde con palomita.
/// - Bloqueada: gris con candado.
/// - Disponible: del color de su materia, con el número de la lección.
/// - [esActual]: la siguiente que toca hacer; late suavemente para llamar
///   la atención.
class TarjetaLeccion extends StatefulWidget {
  const TarjetaLeccion({
    super.key,
    required this.titulo,
    required this.completada,
    required this.bloqueada,
    required this.onTap,
    this.paleta = paletaAzul,
    this.numero = 1,
    this.esActual = false,
  });

  final String titulo;
  final bool completada;
  final bool bloqueada;
  final VoidCallback onTap;
  final PaletaColor paleta;
  final int numero;
  final bool esActual;

  @override
  State<TarjetaLeccion> createState() => _TarjetaLeccionState();
}

class _TarjetaLeccionState extends State<TarjetaLeccion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  bool _presionada = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sincronizarPulso();
  }

  @override
  void didUpdateWidget(covariant TarjetaLeccion anterior) {
    super.didUpdateWidget(anterior);
    _sincronizarPulso();
  }

  void _sincronizarPulso() {
    final animar =
        widget.esActual &&
        !widget.bloqueada &&
        !MediaQuery.disableAnimationsOf(context);
    if (animar) {
      if (!_pulso.isAnimating) _pulso.repeat(reverse: true);
    } else {
      _pulso.stop();
      _pulso.value = 0;
    }
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final paleta = widget.paleta;

    final Color fondo;
    final Color borde;
    if (widget.completada) {
      fondo = colorVerdeSuave;
      borde = colorVerde;
    } else if (widget.bloqueada) {
      fondo = const Color(0xFFF1EFE9);
      borde = const Color(0xFFDAD6CB);
    } else {
      fondo = Colors.white;
      borde = paleta.base;
    }

    final String subtitulo;
    if (widget.completada) {
      subtitulo = 'Completada';
    } else if (widget.bloqueada) {
      subtitulo = 'Termina la lección anterior';
    } else {
      subtitulo = 'Empezar';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedBuilder(
        animation: _pulso,
        builder: (context, hijo) {
          final latido = Curves.easeInOut.transform(_pulso.value);
          return Transform.scale(
            scale: (_presionada ? 0.97 : 1) + latido * 0.018,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: widget.esActual && !widget.bloqueada
                    ? [
                        BoxShadow(
                          color: paleta.base.withValues(
                            alpha: 0.25 + latido * 0.25,
                          ),
                          blurRadius: 10 + latido * 12,
                          spreadRadius: latido * 2,
                        ),
                      ]
                    : null,
              ),
              child: hijo,
            ),
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.bloqueada
              ? null
              : (_) => setState(() => _presionada = true),
          onTapCancel: () {
            if (_presionada) setState(() => _presionada = false);
          },
          onTapUp: (_) {
            if (_presionada) setState(() => _presionada = false);
          },
          onTap: widget.bloqueada ? null : widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borde, width: 2.5),
            ),
            child: Row(
              children: [
                _Insignia(
                  completada: widget.completada,
                  bloqueada: widget.bloqueada,
                  paleta: paleta,
                  numero: widget.numero,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.titulo,
                        style: tema.textTheme.titleMedium?.copyWith(
                          color: widget.bloqueada
                              ? colorTintaSuave.withValues(alpha: 0.7)
                              : colorTinta,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: widget.completada
                              ? colorVerdeOscuro
                              : widget.bloqueada
                              ? colorTintaSuave.withValues(alpha: 0.7)
                              : paleta.oscuro,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.bloqueada)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: widget.completada ? colorVerde : paleta.base,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.completada
                          ? Icons.replay_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                      color: paleta.base == colorAmarillo && !widget.completada
                          ? colorTinta
                          : Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Insignia extends StatelessWidget {
  const _Insignia({
    required this.completada,
    required this.bloqueada,
    required this.paleta,
    required this.numero,
  });

  final bool completada;
  final bool bloqueada;
  final PaletaColor paleta;
  final int numero;

  @override
  Widget build(BuildContext context) {
    final Color cara;
    final Color sombra;
    final Widget contenido;

    if (completada) {
      cara = colorVerde;
      sombra = colorVerdeOscuro;
      contenido = const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 28,
      );
    } else if (bloqueada) {
      cara = const Color(0xFFD9D5CA);
      sombra = const Color(0xFFBFBAAD);
      contenido = const Icon(
        Icons.lock_rounded,
        color: Colors.white,
        size: 22,
      );
    } else {
      cara = paleta.base;
      sombra = paleta.oscuro;
      contenido = Text(
        '$numero',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: paleta.base == colorAmarillo ? colorTinta : Colors.white,
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cara,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: sombra, offset: const Offset(0, 3))],
      ),
      child: contenido,
    );
  }
}
