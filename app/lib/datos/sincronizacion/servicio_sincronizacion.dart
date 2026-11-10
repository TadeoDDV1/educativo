import 'dart:convert';

import 'package:http/http.dart' as http;

import '../repositorios/repositorio_progreso_sqlite.dart';

/// Resultado de intentar sincronizar con el servidor.
class ResultadoSincronizacion {
  const ResultadoSincronizacion({
    required this.exito,
    required this.mensaje,
    this.enviados = 0,
  });

  final bool exito;
  final String mensaje;
  final int enviados;
}

/// Capa de DATOS: envía al servidor el avance guardado sin conexión.
///
/// Si no hay red, no borra nada: los datos siguen marcados como pendientes.
class ServicioSincronizacion {
  ServicioSincronizacion({
    required this.progreso,
    this.urlBase = 'http://10.0.2.2:8000',
    this.usuarioId = 'demo-1',
  });

  final ProgresoSqlite progreso;
  final String urlBase;
  final String usuarioId;

  Future<ResultadoSincronizacion> sincronizar() async {
    try {
      final pendientes = await progreso.pendientesDeSincronizar();
      if (pendientes.isEmpty) {
        return const ResultadoSincronizacion(
          exito: true,
          mensaje: 'Todo está sincronizado.',
        );
      }

      final respuesta = await http
          .post(
            Uri.parse('$urlBase/sync/progreso'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'usuarioId': usuarioId,
              'progresos': [
                for (final item in pendientes)
                  {
                    'leccionId': item.leccionId,
                    'titulo': item.titulo,
                    'aciertos': item.aciertos,
                    'total': item.total,
                    'actualizadoEn':
                        item.actualizadoEn.millisecondsSinceEpoch ~/ 1000,
                  },
              ],
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (respuesta.statusCode != 200) {
        return ResultadoSincronizacion(
          exito: false,
          mensaje: 'El servidor respondió ${respuesta.statusCode}.',
        );
      }

      await progreso.marcarSincronizadas(
        pendientes.map((item) => item.leccionId).toList(),
      );
      return ResultadoSincronizacion(
        exito: true,
        mensaje: 'Se enviaron ${pendientes.length} lecciones.',
        enviados: pendientes.length,
      );
    } catch (_) {
      return const ResultadoSincronizacion(
        exito: false,
        mensaje: 'Sin conexión con el servidor. Tu avance sigue guardado.',
      );
    }
  }
}
