import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../nucleo/servicios.dart';
import '../../nucleo/tema/tema_app.dart';
import '../../widgets/boton_principal.dart';
import '../../widgets/entrada_animada.dart';
import '../../widgets/ficha_opcion.dart';
import '../../widgets/logo_bloques.dart';
import '../inicio/pantalla_inicio.dart';

/// Bienvenida de dos pasos: nombre y datos escolares.
///
/// Si [esEdicion] es verdadero, la pantalla se abre desde el perfil y al
/// guardar vuelve atrás. En el primer uso guarda y abre [PantallaInicio].
class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({
    super.key,
    this.usuarioInicial,
    this.esEdicion = false,
  });

  final Usuario? usuarioInicial;
  final bool esEdicion;

  @override
  State<PantallaBienvenida> createState() => _PantallaBienvenidaState();
}

class _PantallaBienvenidaState extends State<PantallaBienvenida> {
  late final TextEditingController _nombre;
  late String _nivel;
  late int _grado;
  late String _idioma;

  int _paso = 0;
  String? _errorNombre;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final inicial = widget.usuarioInicial;
    _nombre = TextEditingController(text: inicial?.nombre ?? '');
    _nivel = inicial?.nivel ?? 'primaria';
    _grado = inicial?.grado ?? 1;
    _idioma = inicial?.idioma ?? 'es';
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  int get _gradosDelNivel => _nivel == 'primaria' ? 6 : 3;

  void _continuar() {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _errorNombre = 'Escribe tu nombre para continuar');
      return;
    }
    setState(() {
      _errorNombre = null;
      _paso = 1;
    });
  }

  void _atras() => setState(() => _paso = 0);

  void _cambiarNivel(String nivel) {
    setState(() {
      _nivel = nivel;
      if (_grado > _gradosDelNivel) _grado = _gradosDelNivel;
    });
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() {
        _errorNombre = 'Escribe tu nombre para continuar';
        _paso = 0;
      });
      return;
    }

    setState(() => _guardando = true);

    final usuario = Usuario(
      id:
          widget.usuarioInicial?.id ??
          'demo-${DateTime.now().millisecondsSinceEpoch}',
      nombre: nombre,
      grado: _grado,
      nivel: _nivel,
      idioma: _idioma,
    );

    try {
      await Servicios.instancia.usuario.guardar(usuario);
      if (!mounted) return;

      if (widget.esEdicion) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PantallaInicio()),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: widget.esEdicion
          ? AppBar(title: const Text('Editar mis datos'))
          : null,
      body: Stack(
        children: [
          const Positioned.fill(child: _FondoBloques()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: LogoBloques(tamano: 104)),
                      const SizedBox(height: 18),
                      EntradaAnimada(
                        indice: 1,
                        child: Text(
                          'Bienvenido a SaberMóvil',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 4),
                      EntradaAnimada(
                        indice: 2,
                        child: Text(
                          'Aprende a tu ritmo, incluso sin internet.',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodyLarge?.copyWith(
                            color: colorTintaSuave,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _Pasos(paso: _paso),
                      const SizedBox(height: 16),
                      EntradaAnimada(
                        indice: 3,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: colorTinta.withValues(alpha: 0.08),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorAzul.withValues(alpha: 0.18),
                                offset: const Offset(0, 8),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topCenter,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (hijo, animacion) {
                                return FadeTransition(
                                  opacity: animacion,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.08, 0),
                                      end: Offset.zero,
                                    ).animate(animacion),
                                    child: hijo,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey<int>(_paso),
                                child: _paso == 0
                                    ? _pasoNombre(tema)
                                    : _pasoEscolar(tema),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const EntradaAnimada(
                        indice: 4,
                        child: _NotaDispositivo(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pasoNombre(ThemeData tema) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _EtiquetaPaso(texto: 'Paso 1 de 2', paleta: paletaRoja),
        const SizedBox(height: 10),
        Text('¿Cómo te llamas?', style: tema.textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: _nombre,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _continuar(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          decoration: InputDecoration(
            labelText: 'Nombre del estudiante',
            hintText: 'Escribe tu nombre',
            errorText: _errorNombre,
            prefixIcon: const Icon(Icons.face_rounded, color: colorAzul),
          ),
        ),
        const SizedBox(height: 22),
        BotonPrincipal(
          texto: 'Continuar',
          icono: Icons.arrow_forward_rounded,
          onPressed: _continuar,
        ),
      ],
    );
  }

  Widget _pasoEscolar(ThemeData tema) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _EtiquetaPaso(texto: 'Paso 2 de 2', paleta: paletaAzul),
        const SizedBox(height: 10),
        Text('Tu nivel y tu grado', style: tema.textTheme.titleLarge),
        const SizedBox(height: 16),
        Text('Nivel', style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _opcionNivel('primaria', 'Primaria'),
            _opcionNivel('secundaria', 'Secundaria'),
            _opcionNivel('bachillerato', 'Bachillerato'),
          ],
        ),
        const SizedBox(height: 18),
        Text('Grado', style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var grado = 1; grado <= _gradosDelNivel; grado++)
              _opcionGrado(grado),
          ],
        ),
        const SizedBox(height: 18),
        Text('Idioma', style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _opcionIdioma('es', 'Español'),
            _opcionIdioma('lengua indígena', 'Lengua indígena'),
          ],
        ),
        const SizedBox(height: 22),
        BotonPrincipal(
          texto: 'Empezar a aprender',
          icono: Icons.rocket_launch_rounded,
          paleta: paletaVerde,
          onPressed: _guardar,
          habilitado: !_guardando,
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: _guardando ? null : _atras,
          child: const Text('Atrás'),
        ),
      ],
    );
  }

  Widget _opcionNivel(String valor, String etiqueta) {
    return FichaOpcion(
      etiqueta: etiqueta,
      seleccionada: _nivel == valor,
      paleta: paletaRoja,
      onTap: () => _cambiarNivel(valor),
    );
  }

  Widget _opcionGrado(int grado) {
    return FichaOpcion(
      etiqueta: '$grado.º',
      seleccionada: _grado == grado,
      paleta: paletaAmarilla,
      onTap: () => setState(() => _grado = grado),
    );
  }

  Widget _opcionIdioma(String valor, String etiqueta) {
    return FichaOpcion(
      etiqueta: etiqueta,
      seleccionada: _idioma == valor,
      paleta: paletaVerde,
      onTap: () => setState(() => _idioma = valor),
    );
  }
}

/// Dos barritas de colores que se llenan según el paso en el que vas.
class _Pasos extends StatelessWidget {
  const _Pasos({required this.paso});

  final int paso;

  @override
  Widget build(BuildContext context) {
    const colores = [colorRojo, colorAzul];
    return Row(
      children: [
        for (var i = 0; i < 2; i++) ...[
          if (i == 1) const SizedBox(width: 8),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              height: 12,
              decoration: BoxDecoration(
                color: i <= paso ? colores[i] : const Color(0xFFEADFC8),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EtiquetaPaso extends StatelessWidget {
  const _EtiquetaPaso({required this.texto, required this.paleta});

  final String texto;
  final PaletaColor paleta;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: paleta.suave,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: paleta.oscuro,
          ),
        ),
      ),
    );
  }
}

/// Burbujas de colores primarios que decoran el fondo.
class _FondoBloques extends StatelessWidget {
  const _FondoBloques();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(top: -60, left: -50, child: _Burbuja(170, colorAmarillo)),
        Positioned(top: 50, right: -70, child: _Burbuja(150, colorRojo)),
        Positioned(bottom: 110, left: -80, child: _Burbuja(170, colorAzul)),
        Positioned(bottom: -50, right: -40, child: _Burbuja(150, colorVerde)),
      ],
    );
  }
}

class _Burbuja extends StatelessWidget {
  const _Burbuja(this.diametro, this.color);

  final double diametro;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.17),
      ),
    );
  }
}

/// Recuerda al estudiante que sus datos quedan en el dispositivo.
class _NotaDispositivo extends StatelessWidget {
  const _NotaDispositivo();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: colorVerdeSuave,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_rounded,
            size: 16,
            color: colorVerdeOscuro,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'Se guarda en tu dispositivo, no necesitas internet',
            style: tema.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorTintaSuave,
            ),
          ),
        ),
      ],
    );
  }
}
