import 'package:flutter/material.dart';

import '../nucleo/tema/tema_app.dart';

/// Ficha de colores para elegir una opción (nivel, grado, idioma...).
/// Al seleccionarla se pinta, sube un poco y se agranda con un rebote.
class FichaOpcion extends StatelessWidget {
  const FichaOpcion({
    super.key,
    required this.etiqueta,
    required this.seleccionada,
    required this.onTap,
    this.paleta = paletaAzul,
  });

  final String etiqueta;
  final bool seleccionada;
  final VoidCallback onTap;
  final PaletaColor paleta;

  @override
  Widget build(BuildContext context) {
    final colorTexto = !seleccionada
        ? colorTinta
        : paleta.base == colorAmarillo
        ? colorTinta
        : Colors.white;

    return Semantics(
      button: true,
      selected: seleccionada,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: seleccionada ? 1.06 : 1,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: seleccionada ? paleta.base : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: seleccionada
                    ? paleta.oscuro
                    : colorTinta.withValues(alpha: 0.15),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: seleccionada
                      ? paleta.oscuro
                      : colorTinta.withValues(alpha: 0.10),
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (seleccionada) ...[
                  Icon(Icons.check_rounded, size: 18, color: colorTexto),
                  const SizedBox(width: 4),
                ],
                Text(
                  etiqueta,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: colorTexto,
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
