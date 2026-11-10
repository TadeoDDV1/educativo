import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../nucleo/servicios.dart';
import '../onboarding/pantalla_bienvenida.dart';

/// Datos del estudiante y opciones básicas de la app.
class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  bool _sincronizando = false;
  Usuario? _usuario;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final usuario = await Servicios.instancia.usuario.cargar();
    if (!mounted) return;
    setState(() {
      _usuario = usuario;
      _cargando = false;
    });
  }

  Future<void> _editarDatos() async {
    final actualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            PantallaBienvenida(usuarioInicial: _usuario, esEdicion: true),
      ),
    );
    if (actualizado == true) await _cargarUsuario();
  }

  Future<void> _sincronizar() async {
    setState(() => _sincronizando = true);
    final resultado = await Servicios.instancia.sincronizacion.sincronizar();
    if (!mounted) return;
    setState(() => _sincronizando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultado.mensaje),
        backgroundColor: resultado.exito ? Colors.green.shade700 : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario;
    final tema = Theme.of(context);

    if (_cargando || usuario == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final inicial = usuario.nombre.trim().isEmpty
        ? '?'
        : usuario.nombre.trim()[0].toUpperCase();

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
                child: Text(inicial, style: tema.textTheme.headlineMedium),
              ),
              const SizedBox(height: 8),
              Text(usuario.nombre, style: tema.textTheme.titleLarge),
              Text('${usuario.grado}.º de ${_etiquetaNivel(usuario.nivel)}'),
              const SizedBox(height: 16),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Idioma'),
                subtitle: Text(_etiquetaIdioma(usuario.idioma)),
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
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar mis datos'),
                subtitle: const Text('Nombre, nivel, grado e idioma'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _editarDatos,
              ),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sincronizar avance'),
                subtitle: const Text('Envía lo pendiente cuando haya internet'),
                trailing: _sincronizando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _sincronizando ? null : _sincronizar,
              ),
              ValueListenableBuilder<bool>(
                valueListenable: Servicios.instancia.hayConexion,
                builder: (context, hayConexion, _) {
                  return SwitchListTile(
                    secondary: Icon(hayConexion ? Icons.wifi : Icons.wifi_off),
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

  String _etiquetaNivel(String nivel) {
    switch (nivel) {
      case 'primaria':
        return 'primaria';
      case 'secundaria':
        return 'secundaria';
      case 'bachillerato':
        return 'bachillerato';
      default:
        return nivel;
    }
  }

  String _etiquetaIdioma(String idioma) {
    if (idioma == 'es') return 'Español';
    if (idioma == 'lengua indígena') return 'Lengua indígena';
    return idioma;
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
      await Servicios.instancia.progreso.borrarTodo();
    }
  }
}
