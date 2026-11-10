import 'package:flutter/material.dart';

import 'nucleo/tema/tema_app.dart';
import 'pantallas/inicio/pantalla_inicio.dart';

/// Punto de entrada de la interfaz.
/// Solo configura la app y abre la primera pantalla.
class AppSaberMovil extends StatelessWidget {
  const AppSaberMovil({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaberMóvil',
      debugShowCheckedModeBanner: false,
      theme: temaApp(),
      home: const PantallaInicio(),
    );
  }
}
