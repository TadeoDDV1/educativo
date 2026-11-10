import 'package:flutter/material.dart';

import '../nucleo/tema/tema_app.dart';

/// Logo de la app: cuatro bloques de colores primarios que "saltan" al
/// aparecer, con un birrete de graduación en el centro.
class LogoBloques extends StatelessWidget {
  const LogoBloques({super.key, this.tamano = 110});

  final double tamano;

  static const List<PaletaColor> _colores = [
    paletaRoja,
    paletaAzul,
    paletaAmarilla,
    paletaVerde,
  ];

  @override
  Widget build(BuildContext context) {
    const separacion = 6.0;
    final lado = (tamano - separacion) / 2;
    final grande = lado * 0.62;
    final chica = lado * 0.16;

    // La esquina grande de cada bloque mira hacia afuera.
    final radios = <BorderRadius>[
      BorderRadius.only(
        topLeft: Radius.circular(grande),
        topRight: Radius.circular(chica),
        bottomLeft: Radius.circular(chica),
        bottomRight: Radius.circular(chica),
      ),
      BorderRadius.only(
        topLeft: Radius.circular(chica),
        topRight: Radius.circular(grande),
        bottomLeft: Radius.circular(chica),
        bottomRight: Radius.circular(chica),
      ),
      BorderRadius.only(
        topLeft: Radius.circular(chica),
        topRight: Radius.circular(chica),
        bottomLeft: Radius.circular(grande),
        bottomRight: Radius.circular(chica),
      ),
      BorderRadius.only(
        topLeft: Radius.circular(chica),
        topRight: Radius.circular(chica),
        bottomLeft: Radius.circular(chica),
        bottomRight: Radius.circular(grande),
      ),
    ];

    return SizedBox(
      width: tamano,
      height: tamano,
      child: Stack(
        children: [
          for (var i = 0; i < 4; i++)
            Positioned(
              left: (i % 2) * (lado + separacion),
              top: (i ~/ 2) * (lado + separacion),
              width: lado,
              height: lado,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 600 + i * 140),
                curve: Curves.elasticOut,
                builder: (context, valor, hijo) =>
                    Transform.scale(scale: valor, child: hijo),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _colores[i].base,
                    borderRadius: radios[i],
                    boxShadow: [
                      BoxShadow(
                        color: _colores[i].oscuro,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.elasticOut,
              builder: (context, valor, hijo) =>
                  Transform.scale(scale: valor, child: hijo),
              child: Container(
                width: tamano * 0.44,
                height: tamano * 0.44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x33000000), blurRadius: 8),
                  ],
                ),
                child: Icon(
                  Icons.school_rounded,
                  size: tamano * 0.28,
                  color: colorTinta,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
