import 'package:flutter/material.dart';

/// Tarjeta de una lección dentro de la ruta.
class TarjetaLeccion extends StatelessWidget {
  const TarjetaLeccion({
    super.key,
    required this.titulo,
    required this.completada,
    required this.bloqueada,
    required this.onTap,
  });

  final String titulo;
  final bool completada;
  final bool bloqueada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final IconData icono;
    if (completada) {
      icono = Icons.check_circle;
    } else if (bloqueada) {
      icono = Icons.lock_outline;
    } else {
      icono = Icons.play_circle_outline;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: !bloqueada,
      leading: Icon(
        icono,
        color: completada
            ? Colors.green
            : bloqueada
                ? tema.disabledColor
                : tema.colorScheme.primary,
      ),
      title: Text(titulo),
      subtitle: Text(
        completada
            ? 'Completada'
            : bloqueada
                ? 'Termina la lección anterior'
                : 'Empezar',
      ),
      trailing: bloqueada ? null : const Icon(Icons.chevron_right),
      onTap: bloqueada ? null : onTap,
    );
  }
}
