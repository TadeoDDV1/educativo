import 'package:flutter/material.dart';

void main() => runApp(const SaberMovilApp());

/// Shell de navegación del MVP.
/// Sección C es dueña de este archivo: aquí se conectan onboarding, ruta,
/// lección, progreso y perfil. Las demás secciones exponen servicios y
/// contenido que este shell consume.
class SaberMovilApp extends StatelessWidget {
  const SaberMovilApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F7A5C),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'SaberMóvil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        visualDensity: VisualDensity.comfortable,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    _Placeholder(
      icon: Icons.route_outlined,
      title: 'Ruta de aprendizaje',
      body: 'Aquí va la ruta por materia, grado y nivel (Sección C).',
    ),
    _Placeholder(
      icon: Icons.insights_outlined,
      title: 'Mi progreso',
      body: 'Aciertos, racha e insignias leídos desde SQLite (Sección A).',
    ),
    _Placeholder(
      icon: Icons.person_outline,
      title: 'Perfil',
      body: 'Idioma, grado y descargas del estudiante.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SaberMóvil'),
        actions: [
          IconButton(
            tooltip: 'Estado de conexión',
            onPressed: () {},
            icon: const Icon(Icons.cloud_off_outlined),
          ),
        ],
      ),
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Aprender',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'Progreso',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
