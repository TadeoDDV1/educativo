import 'package:flutter/material.dart';

import '../../nucleo/servicios.dart';

/// Franja que recuerda que el avance se guarda en el dispositivo.
class AvisoSinConexion extends StatelessWidget {
  const AvisoSinConexion({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: Servicios.instancia.hayConexion,
      builder: (context, hayConexion, _) {
        if (hayConexion) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: Colors.amber.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.cloud_off, size: 18, color: Colors.amber.shade900),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sin conexión. Tu avance se guarda en este dispositivo.',
                  style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
