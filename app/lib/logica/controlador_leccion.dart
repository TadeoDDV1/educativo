import 'package:flutter/foundation.dart';

import '../datos/modelos/modelos.dart';

/// Capa de LÓGICA: controla una lección mientras el estudiante la responde.
/// No conoce widgets ni bases de datos: solo reglas del juego.
class ControladorLeccion extends ChangeNotifier {
  ControladorLeccion(this.leccion);

  final Leccion leccion;

  int _indice = 0;
  int _aciertos = 0;
  int? _opcionElegida;

  int get indice => _indice;
  int get aciertos => _aciertos;
  int get total => leccion.ejercicios.length;
  int? get opcionElegida => _opcionElegida;

  bool get hayEjercicios => leccion.ejercicios.isNotEmpty;
  bool get respondida => _opcionElegida != null;
  bool get esUltima =>
      !hayEjercicios || _indice >= leccion.ejercicios.length - 1;

  Ejercicio? get ejercicioActual =>
      hayEjercicios ? leccion.ejercicios[_indice] : null;

  /// Marca la opción elegida. Solo cuenta un intento por pregunta.
  void responder(int opcion) {
    if (respondida) return;
    _opcionElegida = opcion;
    if (opcion == ejercicioActual?.correcta) _aciertos++;
    notifyListeners();
  }

  /// Pasa a la siguiente pregunta.
  void siguiente() {
    if (!respondida || esUltima) return;
    _indice++;
    _opcionElegida = null;
    notifyListeners();
  }

  void reiniciar() {
    _indice = 0;
    _aciertos = 0;
    _opcionElegida = null;
    notifyListeners();
  }
}
