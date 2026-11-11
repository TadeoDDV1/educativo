import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/usuario.dart';

/// Capa de DATOS: guarda los datos del estudiante en el dispositivo.
///
/// Usa `shared_preferences` con claves simples para que la app funcione
/// sin internet y sin depender de un servidor.
class RepositorioUsuario {
  const RepositorioUsuario();

  static const String _claveId = 'usuario_id';
  static const String _claveNombre = 'usuario_nombre';
  static const String _claveGrado = 'usuario_grado';
  static const String _claveNivel = 'usuario_nivel';
  static const String _claveIdioma = 'usuario_idioma';

  /// Devuelve el usuario guardado o `null` si todavía no se registró.
  Future<Usuario?> cargar() async {
    final preferencias = await SharedPreferences.getInstance();
    final nombre = preferencias.getString(_claveNombre);

    // Sin nombre no hay usuario válido: la app debe mostrar la bienvenida.
    if (nombre == null || nombre.trim().isEmpty) return null;

    // La app es solo de primaria: si quedó guardado un perfil antiguo de
    // secundaria o bachillerato, se ajusta a un grado válido (1.º a 6.º).
    final grado = (preferencias.getInt(_claveGrado) ?? 1).clamp(1, 6);

    return Usuario(
      id: preferencias.getString(_claveId) ?? 'demo-1',
      nombre: nombre,
      grado: grado,
      idioma: preferencias.getString(_claveIdioma) ?? 'es',
    );
  }

  /// Guarda o reemplaza los datos del estudiante.
  Future<void> guardar(Usuario usuario) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(_claveId, usuario.id);
    await preferencias.setString(_claveNombre, usuario.nombre);
    await preferencias.setInt(_claveGrado, usuario.grado.clamp(1, 6));
    await preferencias.setString(_claveNivel, 'primaria');
    await preferencias.setString(_claveIdioma, usuario.idioma);
  }

  /// Borra los datos del estudiante del dispositivo.
  Future<void> borrar() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(_claveId);
    await preferencias.remove(_claveNombre);
    await preferencias.remove(_claveGrado);
    await preferencias.remove(_claveNivel);
    await preferencias.remove(_claveIdioma);
  }
}
