/// Valores fijos que se usan en varias partes de la app.
class Constantes {
  const Constantes._();

  static const String nombreApp = 'SaberMóvil';
  static const String rutaManifest = 'assets/content/manifest.json';
  /// La app atiende solo educación primaria (1.º a 6.º), conforme a la
  /// Nueva Escuela Mexicana. Ver `nucleo/nem.dart`.
  static const String nivel = 'primaria';
  static const int gradoDemo = 6;

  /// Dirección del servidor de sincronización.
  ///
  /// - Emulador Android: 10.0.2.2 apunta a la computadora.
  /// - Celular físico: usa la IP de tu computadora, por ejemplo:
  ///   flutter run --dart-define=URL_SERVIDOR=http://192.168.1.20:8000
  static const String urlServidor = String.fromEnvironment(
    'URL_SERVIDOR',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
