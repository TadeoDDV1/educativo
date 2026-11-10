import 'package:flutter/material.dart';

/// Botón grande y único, fácil de tocar en pantallas pequeñas.
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.habilitado = true,
  });

  final String texto;
  final VoidCallback onPressed;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: habilitado ? onPressed : null,
        child: Text(texto, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
