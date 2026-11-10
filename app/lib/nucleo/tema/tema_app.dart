import 'package:flutter/material.dart';

/// Colores y estilos de toda la app. Si cambias algo aquí,
/// cambia en todas las pantallas a la vez.
///
/// La paleta usa los cuatro colores primarios de los bloques de juguete:
/// azul, rojo, amarillo y verde, sobre un fondo crema cálido.
const Color colorAzul = Color(0xFF1E6FE8);
const Color colorRojo = Color(0xFFEF3E36);
const Color colorAmarillo = Color(0xFFFFC21A);
const Color colorVerde = Color(0xFF22B45E);

/// Versiones oscuras: se usan como "sombra" de los botones y tarjetas
/// para darles volumen, como una pieza de plástico.
const Color colorAzulOscuro = Color(0xFF1450B0);
const Color colorRojoOscuro = Color(0xFFB92A24);
const Color colorAmarilloOscuro = Color(0xFFD99A00);
const Color colorVerdeOscuro = Color(0xFF158643);

/// Versiones suaves: fondos de tarjetas y chips.
const Color colorAzulSuave = Color(0xFFE3EEFF);
const Color colorRojoSuave = Color(0xFFFFE7E5);
const Color colorAmarilloSuave = Color(0xFFFFF3C9);
const Color colorVerdeSuave = Color(0xFFDDF7E8);

const Color colorTinta = Color(0xFF1B2A4A);
const Color colorTintaSuave = Color(0xFF5B6B8C);
const Color colorFondo = Color(0xFFFFF8E8);

// Nombres anteriores: se mantienen para no romper código existente.
const Color colorPrincipal = colorAzul;
const Color colorAcento = colorAmarillo;
const Color colorCorrecto = colorVerde;
const Color colorError = colorRojo;

/// Un color primario con su sombra y su fondo suave.
class PaletaColor {
  const PaletaColor(this.base, this.oscuro, this.suave);

  final Color base;
  final Color oscuro;
  final Color suave;
}

const PaletaColor paletaAzul = PaletaColor(
  colorAzul,
  colorAzulOscuro,
  colorAzulSuave,
);
const PaletaColor paletaRoja = PaletaColor(
  colorRojo,
  colorRojoOscuro,
  colorRojoSuave,
);
const PaletaColor paletaAmarilla = PaletaColor(
  colorAmarillo,
  colorAmarilloOscuro,
  colorAmarilloSuave,
);
const PaletaColor paletaVerde = PaletaColor(
  colorVerde,
  colorVerdeOscuro,
  colorVerdeSuave,
);

/// Orden de los cuatro colores, para repartirlos en listas (A, B, C, D...).
const List<PaletaColor> paletasPrimarias = [
  paletaRoja,
  paletaAzul,
  paletaAmarilla,
  paletaVerde,
];

/// Color, emoji y nombre corto de cada materia.
class EstiloMateria {
  const EstiloMateria({
    required this.paleta,
    required this.emoji,
    required this.nombre,
  });

  final PaletaColor paleta;
  final String emoji;
  final String nombre;
}

EstiloMateria estiloDeMateria(String materia) {
  switch (materia.toLowerCase()) {
    case 'matematicas':
    case 'matemáticas':
      return const EstiloMateria(
        paleta: paletaAzul,
        emoji: '🧮',
        nombre: 'Matemáticas',
      );
    case 'espanol':
    case 'español':
      return const EstiloMateria(
        paleta: paletaRoja,
        emoji: '📖',
        nombre: 'Español',
      );
    case 'ciencias':
      return const EstiloMateria(
        paleta: paletaVerde,
        emoji: '🔬',
        nombre: 'Ciencias',
      );
    default:
      return EstiloMateria(
        paleta: paletaAmarilla,
        emoji: '⭐',
        nombre: materia.isEmpty
            ? 'General'
            : materia[0].toUpperCase() + materia.substring(1),
      );
  }
}

/// Sombra suave y de color para las tarjetas.
List<BoxShadow> sombraTarjeta([Color color = colorTinta]) => [
  BoxShadow(
    color: color.withValues(alpha: 0.12),
    blurRadius: 18,
    offset: const Offset(0, 8),
  ),
];

ThemeData temaApp() {
  final esquema =
      ColorScheme.fromSeed(
        seedColor: colorAzul,
        brightness: Brightness.light,
      ).copyWith(
        primary: colorAzul,
        onPrimary: Colors.white,
        primaryContainer: colorAzulSuave,
        onPrimaryContainer: colorAzulOscuro,
        secondary: colorRojo,
        onSecondary: Colors.white,
        secondaryContainer: colorRojoSuave,
        onSecondaryContainer: colorRojoOscuro,
        tertiary: colorAmarillo,
        onTertiary: colorTinta,
        tertiaryContainer: colorAmarilloSuave,
        onTertiaryContainer: colorTinta,
        surface: Colors.white,
        onSurface: colorTinta,
        error: colorRojo,
      );

  final base = ThemeData(
    colorScheme: esquema,
    useMaterial3: true,
    visualDensity: VisualDensity.comfortable,
  );

  // Letras más gordas y redondeadas a la vista: se ven más amigables.
  // Se parte de los estilos base (que ya traen el tamaño) y solo se cambia
  // el grosor, para no perder los tamaños de Material 3.
  final basico = base.textTheme.apply(
    bodyColor: colorTinta,
    displayColor: colorTinta,
  );
  final texto = basico.copyWith(
    displaySmall: basico.displaySmall?.copyWith(fontWeight: FontWeight.w900),
    headlineMedium: basico.headlineMedium?.copyWith(
      fontWeight: FontWeight.w900,
    ),
    headlineSmall: basico.headlineSmall?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.3,
    ),
    titleLarge: basico.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    titleMedium: basico.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    labelLarge: basico.labelLarge?.copyWith(fontWeight: FontWeight.w800),
  );

  return base.copyWith(
    textTheme: texto,
    scaffoldBackgroundColor: colorFondo,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: colorAzul,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dividerTheme: DividerThemeData(
      color: colorTinta.withValues(alpha: 0.08),
      thickness: 1.5,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorAzul,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorAzul,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      labelStyle: const TextStyle(
        color: colorTintaSuave,
        fontWeight: FontWeight.w700,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: colorTinta.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorTinta.withValues(alpha: 0.15),
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: colorAzul, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: colorRojo, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: colorRojo, width: 2.5),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: colorAzul,
      linearTrackColor: colorAzulSuave,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (estados) =>
            estados.contains(WidgetState.selected) ? Colors.white : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (estados) =>
            estados.contains(WidgetState.selected) ? colorVerde : null,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorTinta,
      contentTextStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
  );
}
