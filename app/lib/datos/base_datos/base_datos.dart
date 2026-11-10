import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Capa de DATOS: abre y crea la base SQLite de la app.
///
/// La ruta y la fábrica se pueden cambiar desde los tests
/// (por ejemplo con `sqflite_common_ffi` en memoria).
class BaseDatos {
  BaseDatos({this.fabrica, this.ruta});

  /// Si es null se usa la fábrica normal de sqflite (la del celular).
  /// En tests se pasa `databaseFactoryFfi`.
  final DatabaseFactory? fabrica;
  final String? ruta;

  Database? _bd;

  /// Abre la base una sola vez y reutiliza la conexión.
  Future<Database> abrir() async {
    if (_bd != null) return _bd!;

    // Se resuelve aquí, no en el constructor: en tests no existe la fábrica real.
    final fabricaElegida = fabrica ?? databaseFactory;
    final rutaFinal =
        ruta ?? p.join(await fabricaElegida.getDatabasesPath(), 'sabermovil.db');

    _bd = await fabricaElegida.openDatabase(
      rutaFinal,
      options: OpenDatabaseOptions(version: 1, onCreate: _crearEsquema),
    );
    return _bd!;
  }

  /// Esquema v1. Si cambia, sube `version` y agrega una migración.
  static Future<void> _crearEsquema(Database bd, int version) async {
    await bd.execute('''
      CREATE TABLE usuario (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        grado INTEGER NOT NULL,
        nivel TEXT NOT NULL,
        idioma TEXT NOT NULL,
        creadoEn INTEGER NOT NULL
      )
    ''');

    await bd.execute('''
      CREATE TABLE progreso (
        usuarioId TEXT NOT NULL,
        leccionId TEXT NOT NULL,
        titulo TEXT NOT NULL,
        aciertos INTEGER NOT NULL,
        total INTEGER NOT NULL,
        actualizadoEn INTEGER NOT NULL,
        pendienteSync INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (usuarioId, leccionId)
      )
    ''');

    await bd.execute('''
      CREATE TABLE insignia (
        usuarioId TEXT NOT NULL,
        codigo TEXT NOT NULL,
        obtenidaEn INTEGER NOT NULL,
        PRIMARY KEY (usuarioId, codigo)
      )
    ''');

    await bd.execute('''
      CREATE TABLE descarga (
        unidadId TEXT PRIMARY KEY,
        estado TEXT NOT NULL,
        bytes INTEGER NOT NULL DEFAULT 0,
        actualizadoEn INTEGER NOT NULL
      )
    ''');
  }

  Future<void> cerrar() async {
    await _bd?.close();
    _bd = null;
  }
}
