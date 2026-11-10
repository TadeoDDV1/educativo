import 'package:flutter/material.dart';

import '../nucleo/tema/tema_app.dart';

/// Botón grande con volumen, como una pieza de juguete: al tocarlo se
/// "hunde". Fácil de tocar en pantallas pequeñas.
class BotonPrincipal extends StatefulWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.habilitado = true,
    this.paleta = paletaAzul,
    this.icono,
  });

  final String texto;
  final VoidCallback onPressed;
  final bool habilitado;
  final PaletaColor paleta;
  final IconData? icono;

  @override
  State<BotonPrincipal> createState() => _BotonPrincipalState();
}

class _BotonPrincipalState extends State<BotonPrincipal> {
  static const double _alto = 54;
  static const double _grosor = 6;

  bool _presionado = false;

  void _cambiar(bool valor) {
    if (_presionado != valor) setState(() => _presionado = valor);
  }

  @override
  Widget build(BuildContext context) {
    final activo = widget.habilitado;
    final colorTexto = !activo
        ? const Color(0xFF9AA3B5)
        : widget.paleta.base == colorAmarillo
        ? colorTinta
        : Colors.white;
    final colorCara = activo ? widget.paleta.base : const Color(0xFFE3E6EE);
    final colorBorde = activo ? widget.paleta.oscuro : const Color(0xFFC9CEDB);

    return Semantics(
      button: true,
      enabled: activo,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: activo ? (_) => _cambiar(true) : null,
        onTapCancel: () => _cambiar(false),
        onTapUp: (_) => _cambiar(false),
        onTap: activo ? widget.onPressed : null,
        child: SizedBox(
          width: double.infinity,
          height: _alto + _grosor,
          child: Stack(
            children: [
              // Capa de abajo: la "sombra" sólida que da el volumen.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _alto,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorBorde,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              // Capa de arriba: la cara del botón, que baja al presionar.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 80),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                top: _presionado ? _grosor - 1 : 0,
                height: _alto,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorCara,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icono != null) ...[
                          Icon(widget.icono, color: colorTexto, size: 22),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.texto,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            color: colorTexto,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
