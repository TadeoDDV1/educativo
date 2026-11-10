import 'package:flutter/material.dart';

/// Colores y estilos de toda la app. Si cambias algo aquí,
/// cambia en todas las pantallas a la vez.
const Color colorPrincipal = Color(0xFF1F7A5C);
const Color colorAcento = Color(0xFFF2A93B);
const Color colorCorrecto = Color(0xFF2E7D32);
const Color colorError = Color(0xFFC62828);

ThemeData temaApp() {
  final esquema = ColorScheme.fromSeed(
    seedColor: colorPrincipal,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: esquema,
    useMaterial3: true,
    visualDensity: VisualDensity.comfortable,
    scaffoldBackgroundColor: const Color(0xFFF7F8F5),
    appBarTheme: const AppBarTheme(centerTitle: false),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
