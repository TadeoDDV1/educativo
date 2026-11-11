import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../nucleo/nem.dart';
import '../../nucleo/servicios.dart';
import '../../nucleo/tema/tema_app.dart';
import '../../widgets/entrada_animada.dart';
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
        backgroundColor: resultado.exito ? colorVerdeOscuro : null,
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
        EntradaAnimada(
          child: Text('Mi perfil', style: tema.textTheme.headlineSmall),
        ),
        const SizedBox(height: 16),
        EntradaAnimada(
          indice: 1,
          child: _TarjetaPerfil(
            inicial: inicial,
            nombre: usuario.nombre,
            detalle: Nem.etiquetaGrado(usuario.grado),
          ),
        ),
        const SizedBox(height: 16),
        EntradaAnimada(
          indice: 2,
          child: _GrupoOpciones(
            children: [
              ListTile(
                leading: const _IconoColor(Icons.translate_rounded, paletaAzul),
                title: const _Titulo('Idioma'),
                subtitle: Text(_etiquetaIdioma(usuario.idioma)),
              ),
              const ListTile(
                leading: _IconoColor(Icons.download_done_rounded, paletaVerde),
                title: _Titulo('Contenido descargado'),
                subtitle: Text('Disponible sin conexión'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EntradaAnimada(
          indice: 3,
          child: _GrupoOpciones(
            children: [
              ListTile(
                leading: const _IconoColor(Icons.edit_rounded, paletaAmarilla),
                title: const _Titulo('Editar mis datos'),
                subtitle: const Text('Nombre, grado e idioma'),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: colorTintaSuave,
                ),
                onTap: _editarDatos,
              ),
              ListTile(
                leading: const _IconoColor(Icons.sync_rounded, paletaAzul),
                title: const _Titulo('Sincronizar avance'),
                subtitle: const Text('Envía lo pendiente cuando haya internet'),
                trailing: _sincronizando
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          strokeCap: StrokeCap.round,
                        ),
                      )
                    : const Icon(
                        Icons.chevron_right_rounded,
                        color: colorTintaSuave,
                      ),
                onTap: _sincronizando ? null : _sincronizar,
              ),
              ValueListenableBuilder<bool>(
                valueListenable: Servicios.instancia.hayConexion,
                builder: (context, hayConexion, _) {
                  return SwitchListTile(
                    secondary: _IconoColor(
                      hayConexion
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      hayConexion ? paletaVerde : paletaAmarilla,
                    ),
                    title: const _Titulo('Conexión a internet'),
                    subtitle: const Text(
                      'Apágala para probar el modo sin conexión',
                    ),
                    value: hayConexion,
                    onChanged: (_) => Servicios.instancia.alternarConexion(),
                  );
                },
              ),
              ListTile(
                leading: const _IconoColor(Icons.delete_rounded, paletaRoja),
                title: const _Titulo('Borrar mi progreso'),
                onTap: () => _confirmarBorrado(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'SaberMóvil · Primaria · Nueva Escuela Mexicana · versión 0.2',
            style: tema.textTheme.bodySmall?.copyWith(
              color: colorTintaSuave,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
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
        icon: const Text('🗑️', style: TextStyle(fontSize: 36)),
        title: const Text('¿Borrar progreso?'),
        content: const Text('Se perderán las lecciones completadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorRojo),
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

/// Tarjeta principal: avatar con aro de los cuatro colores primarios.
class _TarjetaPerfil extends StatelessWidget {
  const _TarjetaPerfil({
    required this.inicial,
    required this.nombre,
    required this.detalle,
  });

  final String inicial;
  final String nombre;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorTinta.withValues(alpha: 0.08), width: 2),
        boxShadow: sombraTarjeta(),
      ),
      child: Column(
        children: [
          // Franja de cuatro colores arriba.
          const Row(
            children: [
              Expanded(child: SizedBox(height: 10, child: ColoredBox(color: colorRojo))),
              Expanded(child: SizedBox(height: 10, child: ColoredBox(color: colorAzul))),
              Expanded(child: SizedBox(height: 10, child: ColoredBox(color: colorAmarillo))),
              Expanded(child: SizedBox(height: 10, child: ColoredBox(color: colorVerde))),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: 104,
            height: 104,
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  colorRojo,
                  colorAmarillo,
                  colorVerde,
                  colorAzul,
                  colorRojo,
                ],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(5),
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: colorAzul,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  inicial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(nombre, style: tema.textTheme.headlineSmall),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: colorAmarilloSuave,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              detalle,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: colorTinta,
              ),
            ),
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }
}

/// Grupo de opciones en una tarjeta blanca redondeada.
class _GrupoOpciones extends StatelessWidget {
  const _GrupoOpciones({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: sombraTarjeta(),
      ),
      // Material para que los toques muestren el efecto de tinta.
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                  color: colorTinta.withValues(alpha: 0.07),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(fontWeight: FontWeight.w800, color: colorTinta),
    );
  }
}

/// Icono dentro de un cuadrito de color suave.
class _IconoColor extends StatelessWidget {
  const _IconoColor(this.icono, this.paleta);

  final IconData icono;
  final PaletaColor paleta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: paleta.suave,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icono, color: paleta.base == colorAmarillo ? paleta.oscuro : paleta.base),
    );
  }
}
