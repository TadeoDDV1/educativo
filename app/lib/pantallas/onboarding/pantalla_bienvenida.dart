import 'package:flutter/material.dart';

import '../../datos/modelos/modelos.dart';
import '../../nucleo/servicios.dart';
import '../../widgets/boton_principal.dart';
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
      appBar: AppBar(
        title: Text(widget.esEdicion ? 'Editar mis datos' : 'Bienvenida'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: (_paso + 1) / 2),
              const SizedBox(height: 24),
              Icon(Icons.school, size: 56, color: tema.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                'Bienvenido a SaberMóvil',
                textAlign: TextAlign.center,
                style: tema.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Aprende a tu ritmo, incluso sin internet.',
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              if (_paso == 0) _pasoNombre(tema) else _pasoEscolar(tema),
              const SizedBox(height: 24),
              const _NotaDispositivo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pasoNombre(ThemeData tema) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Paso 1 de 2', style: tema.textTheme.labelLarge),
        const SizedBox(height: 8),
        Text('¿Cómo te llamas?', style: tema.textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: _nombre,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _continuar(),
          decoration: InputDecoration(
            labelText: 'Nombre del estudiante',
            hintText: 'Escribe tu nombre',
            errorText: _errorNombre,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 20),
        BotonPrincipal(texto: 'Continuar', onPressed: _continuar),
      ],
    );
  }

  Widget _pasoEscolar(ThemeData tema) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Paso 2 de 2', style: tema.textTheme.labelLarge),
        const SizedBox(height: 8),
        Text('Tu nivel y tu grado', style: tema.textTheme.titleLarge),
        const SizedBox(height: 16),
        Text('Nivel', style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _opcionNivel('primaria', 'Primaria'),
            _opcionNivel('secundaria', 'Secundaria'),
            _opcionNivel('bachillerato', 'Bachillerato'),
          ],
        ),
        const SizedBox(height: 16),
        Text('Grado', style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var grado = 1; grado <= _gradosDelNivel; grado++)
              _opcionGrado(grado),
          ],
        ),
        const SizedBox(height: 16),
        Text('Idioma', style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _opcionIdioma('es', 'Español'),
            _opcionIdioma('lengua indígena', 'Lengua indígena'),
          ],
        ),
        const SizedBox(height: 20),
        BotonPrincipal(
          texto: 'Empezar a aprender',
          onPressed: _guardar,
          habilitado: !_guardando,
        ),
        TextButton(
          onPressed: _guardando ? null : _atras,
          child: const Text('Atrás'),
        ),
      ],
    );
  }

  Widget _opcionNivel(String valor, String etiqueta) {
    return ChoiceChip(
      label: Text(etiqueta),
      selected: _nivel == valor,
      onSelected: (_) => _cambiarNivel(valor),
    );
  }

  Widget _opcionGrado(int grado) {
    return ChoiceChip(
      label: Text('$grado.º'),
      selected: _grado == grado,
      onSelected: (_) => setState(() => _grado = grado),
    );
  }

  Widget _opcionIdioma(String valor, String etiqueta) {
    return ChoiceChip(
      label: Text(etiqueta),
      selected: _idioma == valor,
      onSelected: (_) => setState(() => _idioma = valor),
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
      children: [
        Icon(Icons.lock_outline, size: 18, color: tema.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Se guarda en tu dispositivo, no necesitas internet',
            style: tema.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
