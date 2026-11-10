import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../nucleo/servicios.dart';

/// Datos del estudiante y opciones básicas de la app.
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    const usuario = Usuario.demo;
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Mi perfil', style: tema.textTheme.headlineSmall),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 36,
                backgroundColor: tema.colorScheme.primaryContainer,
                child: Text(
                  usuario.nombre[0],
                  style: tema.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(usuario.nombre, style: tema.textTheme.titleLarge),
              Text('${usuario.grado}.º de ${usuario.nivel}'),
              const SizedBox(height: 16),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Idioma'),
                subtitle: Text(usuario.idioma),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Contenido descargado'),
                subtitle: const Text('Disponible sin conexión'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: Servicios.instancia.hayConexion,
                builder: (context, hayConexion, _) {
                  return SwitchListTile(
                    secondary: Icon(
                      hayConexion ? Icons.wifi : Icons.wifi_off,
                    ),
                    title: const Text('Conexión a internet'),
                    subtitle: const Text(
                      'Apágala para probar el modo sin conexión',
                    ),
                    value: hayConexion,
                    onChanged: (_) => Servicios.instancia.alternarConexion(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Borrar mi progreso'),
                onTap: () => _confirmarBorrado(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'SaberMóvil · versión 0.1',
            style: tema.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmarBorrado(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar progreso?'),
        content: const Text('Se perderán las lecciones completadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      Servicios.instancia.progreso.borrarTodo();
    }
  }
}
