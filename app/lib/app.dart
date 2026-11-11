import 'package:flutter/material.dart';

import 'datos/modelos/usuario.dart';
import 'nucleo/servicios.dart';
import 'nucleo/tema/tema_app.dart';
import 'pantallas/inicio/pantalla_inicio.dart';
import 'pantallas/onboarding/pantalla_bienvenida.dart';
import 'widgets/logo_bloques.dart';

/// Punto de entrada de la interfaz.
/// Configura la app y decide si mostrar la bienvenida o el inicio.
class AppSaberMovil extends StatefulWidget {
  const AppSaberMovil({super.key});

  @override
  State<AppSaberMovil> createState() => _AppSaberMovilState();
}

class _AppSaberMovilState extends State<AppSaberMovil> {
  late final Future<Usuario?> _usuario = Servicios.instancia.usuario.cargar();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaberMóvil',
      debugShowCheckedModeBanner: false,
      theme: temaApp(),
      home: FutureBuilder<Usuario?>(
        future: _usuario,
        builder: (context, resultado) {
          if (resultado.connectionState != ConnectionState.done) {
            return const _PantallaCargando();
          }

          final usuario = resultado.data;
          if (usuario == null) return const PantallaBienvenida();
          return const PantallaInicio();
        },
      ),
    );
  }
}

/// Pantalla mínima mientras se leen los datos guardados.
class _PantallaCargando extends StatelessWidget {
  const _PantallaCargando();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LogoBloques(tamano: 96),
            SizedBox(height: 28),
            SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
