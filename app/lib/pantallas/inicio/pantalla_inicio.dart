import 'package:flutter/material.dart';

import '../../nucleo/servicios.dart';
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
        title: const Text('SaberMóvil'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: Servicios.instancia.hayConexion,
            builder: (context, hayConexion, _) {
              return IconButton(
                tooltip: hayConexion ? 'Con conexión' : 'Sin conexión',
                onPressed: Servicios.instancia.alternarConexion,
                icon: Icon(
                  hayConexion ? Icons.wifi : Icons.wifi_off,
                  color: hayConexion ? null : Colors.orange.shade800,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const AvisoSinConexion(),
          Expanded(child: _pantallas[_seccion]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seccion,
        onDestinationSelected: (indice) => setState(() => _seccion = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Aprender',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'Progreso',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
