import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../nucleo/nem.dart';
import '../../nucleo/servicios.dart';
import '../../widgets/tarjeta_leccion.dart';
import 'pantalla_leccion.dart';

/// Muestra las unidades del grado del estudiante, agrupadas por
/// Campo formativo de la Nueva Escuela Mexicana.
///
/// Cada unidad es independiente: su primera lección siempre está abierta
/// y las siguientes se desbloquean al completar la anterior.
class PantallaRuta extends StatefulWidget {
  const PantallaRuta({super.key});

  @override
  State<PantallaRuta> createState() => _PantallaRutaState();
}

class _DatosRuta {
  const _DatosRuta({required this.grado, required this.unidades});

  final int grado;
  final List<Unidad> unidades;
}

class _PantallaRutaState extends State<PantallaRuta> {
  late final Future<_DatosRuta> _datos = _cargar();

  /// null = todos los campos.
  String? _campoElegido;

  Future<_DatosRuta> _cargar() async {
    final usuario = await Servicios.instancia.usuario.cargar();
    final grado = usuario?.grado ?? Usuario.demo.grado;
    final unidades = await Servicios.instancia.contenido.cargarUnidadesDeGrado(
      grado,
    );
    unidades.sort(
      (a, b) =>
          CampoFormativo.orden(a.campo).compareTo(CampoFormativo.orden(b.campo)),
    );
    return _DatosRuta(grado: grado, unidades: unidades);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DatosRuta>(
      future: _datos,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No se pudo cargar el contenido:\n${snapshot.error}'),
            ),
          );
        }

        final datos = snapshot.data!;
        final campos = <String>{for (final u in datos.unidades) u.campo};
        final visibles = _campoElegido == null
            ? datos.unidades
            : datos.unidades.where((u) => u.campo == _campoElegido).toList();

        return ValueListenableBuilder<Map<String, ProgresoLeccion>>(
          valueListenable: Servicios.instancia.progreso.escuchar,
          builder: (context, _, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Mi ruta de aprendizaje',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(Nem.etiquetaGrado(datos.grado)),
                const SizedBox(height: 12),
                if (datos.unidades.isEmpty)
                  const _SinContenido()
                else ...[
                  _FiltroCampos(
                    campos: [
                      for (final campo in CampoFormativo.todos)
                        if (campos.contains(campo.id)) campo,
                    ],
                    elegido: _campoElegido,
                    onCambiar: (campo) => setState(() => _campoElegido = campo),
                  ),
                  const SizedBox(height: 16),
                  for (final unidad in visibles)
                    _BloqueUnidad(
                      unidad: unidad,
                      tarjetas: _tarjetasDe(context, unidad),
                    ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  /// Tarjetas de las lecciones de una unidad, con desbloqueo secuencial.
  List<Widget> _tarjetasDe(BuildContext context, Unidad unidad) {
    var desbloqueada = true;
    final tarjetas = <Widget>[];
    for (final leccion in unidad.lecciones) {
      final completada = Servicios.instancia.progreso.estaCompletada(
        leccion.id,
      );
      tarjetas.add(
        TarjetaLeccion(
          titulo: leccion.titulo,
          completada: completada,
          bloqueada: !desbloqueada,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PantallaLeccion(leccion: leccion),
              ),
            );
          },
        ),
      );
      desbloqueada = completada;
    }
    return tarjetas;
  }
}

/// Chips para mostrar todos los campos o solo uno.
class _FiltroCampos extends StatelessWidget {
  const _FiltroCampos({
    required this.campos,
    required this.elegido,
    required this.onCambiar,
  });

  final List<CampoFormativo> campos;
  final String? elegido;
  final ValueChanged<String?> onCambiar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Todos'),
          selected: elegido == null,
          onSelected: (_) => onCambiar(null),
        ),
        for (final campo in campos)
          ChoiceChip(
            avatar: Icon(campo.icono, size: 18, color: campo.color),
            label: Text(campo.nombreCorto),
            tooltip: campo.nombre,
            selected: elegido == campo.id,
            onSelected: (_) => onCambiar(campo.id),
          ),
      ],
    );
  }
}

class _BloqueUnidad extends StatelessWidget {
  const _BloqueUnidad({required this.unidad, required this.tarjetas});

  final Unidad unidad;
  final List<Widget> tarjetas;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final campo = CampoFormativo.buscar(unidad.campo);
    final color = campo?.color ?? tema.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(campo?.icono ?? Icons.school, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    (campo?.nombre ?? unidad.campo).toUpperCase(),
                    style: tema.textTheme.labelSmall?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(unidad.titulo, style: tema.textTheme.titleLarge),
            if (unidad.objetivo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(unidad.objetivo, style: tema.textTheme.bodySmall),
            ],
            if (unidad.contenido.isNotEmpty || unidad.pda.isNotEmpty)
              _DetalleCurricular(unidad: unidad),
            const SizedBox(height: 8),
            ...tarjetas,
          ],
        ),
      ),
    );
  }
}

/// Contenido del programa, PDA y ejes articuladores, plegados para
/// no saturar la pantalla del estudiante.
class _DetalleCurricular extends StatelessWidget {
  const _DetalleCurricular({required this.unidad});

  final Unidad unidad;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Theme(
      data: tema.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text('¿Qué voy a aprender?', style: tema.textTheme.labelLarge),
        children: [
          if (unidad.contenido.isNotEmpty) ...[
            Text('Contenido', style: tema.textTheme.labelMedium),
            Text(unidad.contenido, style: tema.textTheme.bodySmall),
            const SizedBox(height: 8),
          ],
          if (unidad.pda.isNotEmpty) ...[
            Text(
              'Procesos de desarrollo de aprendizaje',
              style: tema.textTheme.labelMedium,
            ),
            for (final pda in unidad.pda)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('• $pda', style: tema.textTheme.bodySmall),
              ),
            const SizedBox(height: 8),
          ],
          if (unidad.ejesArticuladores.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final eje in unidad.ejesArticuladores)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      ejesArticuladores[eje] ?? eje,
                      style: tema.textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SinContenido extends StatelessWidget {
  const _SinContenido();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Todavía no hay unidades para tu grado. '
          'Pide a tu maestra o maestro que descargue el contenido.',
        ),
      ),
    );
  }
}
