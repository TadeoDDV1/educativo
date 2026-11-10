import 'package:flutter/material.dart';

import '../nucleo/servicios.dart';
import '../nucleo/tema/tema_app.dart';

/// Franja que recuerda que el avance se guarda en el dispositivo.
/// Se despliega y se pliega con una animación suave.
class AvisoSinConexion extends StatelessWidget {
  const AvisoSinConexion({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: Servicios.instancia.hayConexion,
      builder: (context, hayConexion, _) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: hayConexion
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorAmarilloSuave,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colorAmarillo, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 20,
                        color: colorAmarilloOscuro,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Sin conexión. Tu avance se guarda en este dispositivo.',
                          style: TextStyle(
                            color: colorTinta,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
