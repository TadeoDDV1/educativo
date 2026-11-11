import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../nucleo/servicios.dart';
import '../../nucleo/tema/tema_app.dart';
import '../../widgets/boton_principal.dart';
import '../../widgets/confeti.dart';

/// Se muestra al terminar una lección. Guarda el resultado una sola vez.
class PantallaResultado extends StatefulWidget {
  const PantallaResultado({
    super.key,
    required this.leccion,
    required this.aciertos,
    required this.total,
  });

  final Leccion leccion;
  final int aciertos;
  final int total;

  @override
  State<PantallaResultado> createState() => _PantallaResultadoState();
}

class _PantallaResultadoState extends State<PantallaResultado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _escena = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    Servicios.instancia.progreso.guardar(
      ProgresoLeccion(
        leccionId: widget.leccion.id,
        titulo: widget.leccion.titulo,
        aciertos: widget.aciertos,
        total: widget.total,
        actualizadoEn: DateTime.now(),
      ),
    );
    _escena.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _escena.value = 1;
  }

  @override
  void dispose() {
    _escena.dispose();
    super.dispose();
  }

  /// Un tramo de la animación general: va de 0 a 1 entre [inicio] y [fin].
  Animation<double> _tramo(double inicio, double fin, Curve curva) {
    return CurvedAnimation(
      parent: _escena,
      curve: Interval(inicio, fin, curve: curva),
    );
  }

  /// Estrellas ganadas según el porcentaje.
  int _estrellas(int porcentaje) {
    if (porcentaje >= 90) return 3;
    if (porcentaje >= 60) return 2;
    if (porcentaje >= 30) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final porcentaje = widget.total == 0
        ? 100
        : (widget.aciertos * 100 ~/ widget.total);
    final aprobado = porcentaje >= 60;
    final estrellas = _estrellas(porcentaje);
    final paleta = aprobado ? paletaAmarilla : paletaAzul;

    final trofeo = _tramo(0.0, 0.40, Curves.elasticOut);
    final textos = _tramo(0.30, 0.55, Curves.easeOutCubic);
    final boton = _tramo(0.75, 1.0, Curves.easeOutCubic);

    return Scaffold(
      body: Stack(
        children: [
          // Fondo: degradado cálido con burbujas de colores.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    aprobado ? colorAmarilloSuave : colorAzulSuave,
                    colorFondo,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trofeo con halo de color.
                  ScaleTransition(
                    scale: trofeo,
                    child: Container(
                      width: 168,
                      height: 168,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            paleta.base.withValues(alpha: 0.95),
                            paleta.base.withValues(alpha: 0.35),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: paleta.base.withValues(alpha: 0.45),
                            blurRadius: 34,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        aprobado
                            ? Icons.emoji_events_rounded
                            : Icons.refresh_rounded,
                        size: 96,
                        color: aprobado ? colorTinta : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Estrellas: aparecen una a una con rebote.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 3; i++)
                        ScaleTransition(
                          scale: _tramo(
                            0.35 + i * 0.12,
                            0.60 + i * 0.12,
                            Curves.elasticOut,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 4,
                              right: 4,
                              top: i == 1 ? 0 : 10,
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              size: i == 1 ? 58 : 46,
                              color: i < estrellas
                                  ? colorAmarillo
                                  : colorTinta.withValues(alpha: 0.13),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FadeTransition(
                    opacity: textos,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.25),
                        end: Offset.zero,
                      ).animate(textos),
                      child: Column(
                        children: [
                          Text(
                            aprobado
                                ? '¡Lección completada!'
                                : '¡Sigue practicando!',
                            style: tema.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Acertaste ${widget.aciertos} de ${widget.total}',
                            style: tema.textTheme.titleMedium?.copyWith(
                              color: colorTintaSuave,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // El porcentaje cuenta hacia arriba.
                          TweenAnimationBuilder<int>(
                            tween: IntTween(begin: 0, end: porcentaje),
                            duration: const Duration(milliseconds: 1400),
                            curve: Curves.easeOutCubic,
                            builder: (context, valor, _) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 26,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: aprobado
                                      ? colorVerdeSuave
                                      : colorAzulSuave,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: aprobado ? colorVerde : colorAzul,
                                    width: 3,
                                  ),
                                ),
                                child: Text(
                                  '$valor %',
                                  style: tema.textTheme.displaySmall?.copyWith(
                                    color: aprobado
                                        ? colorVerdeOscuro
                                        : colorAzulOscuro,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: boton,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.6),
                        end: Offset.zero,
                      ).animate(boton),
                      child: BotonPrincipal(
                        texto: 'Volver a mi ruta',
                        icono: Icons.map_rounded,
                        paleta: aprobado ? paletaVerde : paletaAzul,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
          // Confeti por encima de todo, solo si aprobó.
          if (aprobado) const Positioned.fill(child: Confeti()),
        ],
      ),
    );
  }
}
