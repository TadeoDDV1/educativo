import 'package:flutter/material.dart';

import '../../nucleo/servicios.dart';
import '../../nucleo/tema/tema_app.dart';
import '../aprender/pantalla_ruta.dart';
import '../perfil/pantalla_perfil.dart';
import '../progreso/pantalla_progreso.dart';
import '../../widgets/aviso_sin_conexion.dart';

/// Pantalla contenedora: barra superior y las tres secciones de la app.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  int _seccion = 0;

  static const List<Widget> _pantallas = [
    PantallaRuta(),
    PantallaProgreso(),
    PantallaPerfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            _MiniLogo(),
            SizedBox(width: 10),
            Text('SaberMóvil'),
          ],
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: Servicios.instancia.hayConexion,
            builder: (context, hayConexion, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Tooltip(
                  message: hayConexion ? 'Con conexión' : 'Sin conexión',
                  child: GestureDetector(
                    onTap: Servicios.instancia.alternarConexion,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: hayConexion ? colorVerde : colorAmarillo,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hayConexion
                                ? Icons.wifi_rounded
                                : Icons.wifi_off_rounded,
                            size: 18,
                            color: hayConexion ? Colors.white : colorTinta,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hayConexion ? 'En línea' : 'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: hayConexion ? Colors.white : colorTinta,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const AvisoSinConexion(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              child: KeyedSubtree(
                key: ValueKey<int>(_seccion),
                child: _pantallas[_seccion],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BarraInferior(
        seleccion: _seccion,
        alCambiar: (indice) => setState(() => _seccion = indice),
      ),
    );
  }
}

/// Cuatro cuadritos de colores: versión pequeña del logo para la barra.
class _MiniLogo extends StatelessWidget {
  const _MiniLogo();

  @override
  Widget build(BuildContext context) {
    Widget cuadro(Color color) => Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              cuadro(colorRojo),
              const SizedBox(width: 3),
              cuadro(colorAmarillo),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              cuadro(colorAzul),
              const SizedBox(width: 3),
              cuadro(colorVerde),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatosPestana {
  const _DatosPestana(this.icono, this.etiqueta, this.paleta);

  final IconData icono;
  final String etiqueta;
  final PaletaColor paleta;
}

/// Barra de navegación propia: cada pestaña tiene su color primario y la
/// elegida se "infla" con una pastilla de fondo.
class _BarraInferior extends StatelessWidget {
  const _BarraInferior({required this.seleccion, required this.alCambiar});

  final int seleccion;
  final ValueChanged<int> alCambiar;

  static const List<_DatosPestana> _pestanas = [
    _DatosPestana(Icons.school_rounded, 'Aprender', paletaAzul),
    _DatosPestana(Icons.insights_rounded, 'Progreso', paletaVerde),
    _DatosPestana(Icons.face_rounded, 'Perfil', paletaRoja),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: colorTinta.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              for (var i = 0; i < _pestanas.length; i++)
                Expanded(
                  child: _ItemBarra(
                    datos: _pestanas[i],
                    seleccionado: i == seleccion,
                    onTap: () => alCambiar(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemBarra extends StatelessWidget {
  const _ItemBarra({
    required this.datos,
    required this.seleccionado,
    required this.onTap,
  });

  final _DatosPestana datos;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = seleccionado ? datos.paleta.base : colorTintaSuave;

    return Semantics(
      button: true,
      selected: seleccionado,
      label: datos.etiqueta,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: seleccionado ? datos.paleta.suave : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: seleccionado ? 1.22 : 1,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                child: Icon(datos.icono, size: 26, color: color),
              ),
              const SizedBox(height: 3),
              Text(
                datos.etiqueta,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: seleccionado ? FontWeight.w900 : FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
