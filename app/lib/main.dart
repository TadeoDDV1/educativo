import 'package:flutter/material.dart';

import 'app.dart';
import 'nucleo/servicios.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Recupera de SQLite el avance guardado antes de dibujar la app.
  try {
    await Servicios.instancia.iniciar();
  } catch (error) {
    debugPrint('No se pudo abrir la base de datos: $error');
  }

  runApp(const AppSaberMovil());
}
