import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../logica/insignias.dart';
import '../../nucleo/servicios.dart';
import '../../nucleo/tema/tema_app.dart';
import '../../widgets/entrada_animada.dart';
import '../../widgets/mascota.dart';

/// Muestra el avance guardado en el dispositivo.
class PantallaProgreso extends StatelessWidget {
  const PantallaProgreso({super.key});

  @override
  Widget build(BuildContext context) {
    final progreso = Servicios.instancia.progreso;
    final tema = Theme.of(context);

    return ValueListenableBuilder<Map<String, ProgresoLeccion>>(
      valueListenable: progreso.escuchar,
      builder: (context, datos, _) {
        if (datos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Mascota(emoji: '🌱', tamano: 84),
                  const SizedBox(height: 18),
                  Text(
                    'Todavía no has completado lecciones.\n'
                    'Entra a "Aprender" para empezar.',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.titleMedium?.copyWith(
                      color: colorTintaSuave,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final aciertos = progreso.aciertosTotales;
        final total = progreso.preguntasTotales;
        final porcentaje = total == 0 ? 0 : aciertos * 100 ~/ total;
        final ganadas = calcularInsignias(
          progresos: datos.values,
          racha: progreso.racha,
        );
        final codigosGanados = ganadas.map((i) => i.codigo).toSet();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            EntradaAnimada(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mi progreso',
                      style: tema.textTheme.headlineSmall,
                    ),
                  ),
                  _Racha(dias: progreso.racha),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: EntradaAnimada(
                    indice: 1,
                    child: _Dato(
                      valor: '${datos.length}',
                      etiqueta: 'Lecciones',
                      icono: Icons.menu_book_rounded,
                      paleta: paletaAzul,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: EntradaAnimada(
                    indice: 2,
                    child: _Dato(
                      valor: '$aciertos/$total',
                      etiqueta: 'Aciertos',
                      icono: Icons.check_circle_rounded,
                      paleta: paletaVerde,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: EntradaAnimada(
                    indice: 3,
                    child: _Dato(
                      valor: '$porcentaje %',
                      etiqueta: 'Promedio',
                      icono: Icons.percent_rounded,
                      paleta: paletaRoja,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            EntradaAnimada(
              indice: 4,
              child: Text('Mis insignias', style: tema.textTheme.titleLarge),
            ),
            const SizedBox(height: 10),
            if (ganadas.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Completa lecciones para ganar tu primera insignia.',
                  style: TextStyle(
                    color: colorTintaSuave,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            // Se muestran todas: las ganadas con color y las que faltan en gris.
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < catalogoInsignias.length; i++)
                  EntradaAnimada(
                    indice: 5 + i,
                    child: _TarjetaInsignia(
                      insignia: catalogoInsignias[i],
                      ganada: codigosGanados.contains(
                        catalogoInsignias[i].codigo,
                      ),
                      paleta: paletasPrimarias[i % paletasPrimarias.length],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            Text('Lecciones completadas', style: tema.textTheme.titleLarge),
            const SizedBox(height: 10),
            for (final item in datos.values)
              _TarjetaResultado(item: item),
          ],
        );
      },
    );
  }
}

/// Pastilla con la llama de la racha de días.
class _Racha extends StatelessWidget {
  const _Racha({required this.dias});

  final int dias;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorAmarillo,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(color: colorAmarilloOscuro, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(
            '$dias días',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: colorTinta,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.valor,
    required this.etiqueta,
    required this.icono,
    required this.paleta,
  });

  final String valor;
  final String etiqueta;
  final IconData icono;
  final PaletaColor paleta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: paleta.base,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: paleta.oscuro, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Insignia: a color si ya se ganó, en gris con candado si todavía no.
class _TarjetaInsignia extends StatelessWidget {
  const _TarjetaInsignia({
    required this.insignia,
    required this.ganada,
    required this.paleta,
  });

  final Insignia insignia;
  final bool ganada;
  final PaletaColor paleta;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: insignia.descripcion,
      child: Container(
        width: 156,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ganada ? paleta.suave : const Color(0xFFF1EFE9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: ganada ? paleta.base : const Color(0xFFDAD6CB),
            width: 2.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ganada ? Colors.white : const Color(0xFFE2DFD6),
                shape: BoxShape.circle,
              ),
              child: ganada
                  ? Text(insignia.emoji, style: const TextStyle(fontSize: 24))
                  : const Icon(
                      Icons.lock_rounded,
                      size: 20,
                      color: Color(0xFFA8A396),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                insignia.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: ganada ? colorTinta : const Color(0xFFA8A396),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Una lección terminada, con barra del color de su nota.
class _TarjetaResultado extends StatelessWidget {
  const _TarjetaResultado({required this.item});

  final ProgresoLeccion item;

  @override
  Widget build(BuildContext context) {
    final nota = item.calificacion;
    final PaletaColor paleta;
    if (nota >= 80) {
      paleta = paletaVerde;
    } else if (nota >= 60) {
      paleta = paletaAmarilla;
    } else {
      paleta = paletaRoja;
    }
    final fraccion = item.total == 0 ? 0.0 : item.aciertos / item.total;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: sombraTarjeta(),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: paleta.base,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: paleta.oscuro, offset: const Offset(0, 3)),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              color: paleta.base == colorAmarillo ? colorTinta : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titulo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.aciertos} de ${item.total} · ${item.calificacion} %',
                  style: const TextStyle(
                    color: colorTintaSuave,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fraccion),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, valor, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: valor,
                      minHeight: 8,
                      color: paleta.base,
                      backgroundColor: paleta.suave,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
