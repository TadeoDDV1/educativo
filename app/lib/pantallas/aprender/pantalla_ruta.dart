import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../nucleo/servicios.dart';
import '../../nucleo/tema/tema_app.dart';
import '../../widgets/entrada_animada.dart';
import '../../widgets/mascota.dart';
import '../../widgets/tarjeta_leccion.dart';
import 'pantalla_leccion.dart';

/// Muestra las unidades y sus lecciones en orden.
/// Una lección se desbloquea cuando la anterior está completada.
class PantallaRuta extends StatefulWidget {
  const PantallaRuta({super.key});

  @override
  State<PantallaRuta> createState() => _PantallaRutaState();
}

class _PantallaRutaState extends State<PantallaRuta> {
  late final Future<List<Unidad>> _unidades = Servicios.instancia.contenido
      .cargarUnidades();
  late final Future<Usuario?> _usuario = Servicios.instancia.usuario.cargar();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Unidad>>(
      future: _unidades,
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

        final unidades = snapshot.data ?? [];
        return ValueListenableBuilder<Map<String, ProgresoLeccion>>(
          valueListenable: Servicios.instancia.progreso.escuchar,
          builder: (context, _, _) {
            var totalLecciones = 0;
            var completadas = 0;
            for (final unidad in unidades) {
              for (final leccion in unidad.lecciones) {
                totalLecciones++;
                if (Servicios.instancia.progreso.estaCompletada(leccion.id)) {
                  completadas++;
                }
              }
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                EntradaAnimada(
                  child: _Encabezado(
                    usuario: _usuario,
                    completadas: completadas,
                    total: totalLecciones,
                  ),
                ),
                const SizedBox(height: 22),
                EntradaAnimada(
                  indice: 1,
                  child: Text(
                    'Mi ruta de aprendizaje',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 4),
                const EntradaAnimada(
                  indice: 1,
                  child: Text(
                    '6.º de primaria · Contenido descargado',
                    style: TextStyle(
                      color: colorTintaSuave,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._construirBloques(context, unidades),
              ],
            );
          },
        );
      },
    );
  }

  /// Arma las tarjetas de todas las unidades en orden.
  /// `desbloqueada` empieza en true: la primera lección siempre está abierta.
  List<Widget> _construirBloques(BuildContext context, List<Unidad> unidades) {
    var desbloqueada = true;
    var actualAsignada = false;
    final bloques = <Widget>[];

    for (var u = 0; u < unidades.length; u++) {
      final unidad = unidades[u];
      final estilo = estiloDeMateria(unidad.materia);
      final tarjetas = <Widget>[];
      var completadasUnidad = 0;

      for (var l = 0; l < unidad.lecciones.length; l++) {
        final leccion = unidad.lecciones[l];
        final completada = Servicios.instancia.progreso.estaCompletada(
          leccion.id,
        );
        if (completada) completadasUnidad++;

        // La primera lección abierta y sin terminar es la que "toca".
        final esActual = !completada && desbloqueada && !actualAsignada;
        if (esActual) actualAsignada = true;

        tarjetas.add(
          TarjetaLeccion(
            titulo: leccion.titulo,
            completada: completada,
            bloqueada: !desbloqueada,
            paleta: estilo.paleta,
            numero: l + 1,
            esActual: esActual,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PantallaLeccion(
                    leccion: leccion,
                    paleta: estilo.paleta,
                  ),
                ),
              );
            },
          ),
        );
        desbloqueada = completada;
      }

      bloques.add(
        EntradaAnimada(
          indice: u + 2,
          child: _BloqueUnidad(
            unidad: unidad,
            estilo: estilo,
            completadas: completadasUnidad,
            tarjetas: tarjetas,
          ),
        ),
      );
    }
    return bloques;
  }
}

/// Tarjeta de bienvenida con el saludo, la mascota y un anillo de avance.
class _Encabezado extends StatelessWidget {
  const _Encabezado({
    required this.usuario,
    required this.completadas,
    required this.total,
  });

  final Future<Usuario?> usuario;
  final int completadas;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraccion = total == 0 ? 0.0 : completadas / total;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B8BFF), colorAzul, colorAzulOscuro],
        ),
        boxShadow: const [
          BoxShadow(color: colorAzulOscuro, offset: Offset(0, 6)),
        ],
      ),
      child: Stack(
        children: [
          // Decoración: círculos de colores primarios.
          Positioned(
            top: -30,
            right: -20,
            child: _Circulo(110, colorAmarillo.withValues(alpha: 0.9)),
          ),
          Positioned(
            bottom: -34,
            left: 90,
            child: _Circulo(90, colorRojo.withValues(alpha: 0.85)),
          ),
          Positioned(
            top: 14,
            left: -26,
            child: _Circulo(64, colorVerde.withValues(alpha: 0.85)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Mascota(emoji: '🦉', tamano: 58),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Usuario?>(
                        future: usuario,
                        builder: (context, snapshot) {
                          final nombre = snapshot.data?.nombre.trim() ?? '';
                          return Text(
                            nombre.isEmpty ? '¡Hola!' : '¡Hola, $nombre!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      Text(
                        completadas == 0
                            ? '¿Listo para tu primera aventura?'
                            : completadas >= total && total > 0
                            ? '¡Terminaste todas las lecciones!'
                            : '$completadas de $total lecciones hechas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fraccion),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (context, valor, _) {
                    return SizedBox(
                      width: 62,
                      height: 62,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: valor,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                              color: colorAmarillo,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          Text(
                            '${(valor * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circulo extends StatelessWidget {
  const _Circulo(this.diametro, this.color);

  final double diametro;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.28),
      ),
    );
  }
}

class _BloqueUnidad extends StatelessWidget {
  const _BloqueUnidad({
    required this.unidad,
    required this.estilo,
    required this.completadas,
    required this.tarjetas,
  });

  final Unidad unidad;
  final EstiloMateria estilo;
  final int completadas;
  final List<Widget> tarjetas;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final paleta = estilo.paleta;
    final total = unidad.lecciones.length;
    final fraccion = total == 0 ? 0.0 : completadas / total;
    final textoSobreColor = paleta.base == colorAmarillo
        ? colorTinta
        : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: paleta.base, width: 2.5),
        boxShadow: [BoxShadow(color: paleta.oscuro, offset: const Offset(0, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Franja de color con la materia.
            Container(
              width: double.infinity,
              color: paleta.base,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      estilo.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unidad.materia.toUpperCase(),
                          style: tema.textTheme.labelSmall?.copyWith(
                            color: textoSobreColor.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          unidad.titulo,
                          style: tema.textTheme.titleLarge?.copyWith(
                            color: textoSobreColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$completadas/$total',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: paleta.oscuro,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unidad.objetivo.isNotEmpty) ...[
                    Text(
                      unidad.objetivo,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: colorTintaSuave,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Barra de avance de la unidad.
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: fraccion),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, valor, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: valor,
                        minHeight: 10,
                        color: paleta.base,
                        backgroundColor: paleta.suave,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...tarjetas,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
