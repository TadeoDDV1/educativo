# Arquitectura de SaberMóvil

La app está dividida en **3 capas**. La regla es una sola: cada capa solo habla con la de al lado.

```text
┌─────────────────────────────────────────┐
│  PANTALLAS (lo que se ve)               │  lib/pantallas/ + lib/widgets/
│  Botones, textos, listas, colores       │
└──────────────────┬──────────────────────┘
                   │ usa
┌──────────────────▼──────────────────────┐
│  LÓGICA (reglas del juego)              │  lib/logica/
│  ¿Acertó? ¿Sigue? ¿Cuánto lleva?        │
└──────────────────┬──────────────────────┘
                   │ pide datos
┌──────────────────▼──────────────────────┐
│  DATOS (de dónde sale todo)             │  lib/datos/
│  JSON, SQLite, archivos, sincronización │
└─────────────────────────────────────────┘
```

Más dos carpetas de apoyo:

- **`lib/nucleo/`** → cosas comunes: tema, constantes y el objeto `Servicios`
  (que reúne los repositorios).
- **`lib/widgets/`** → piezas visuales reutilizables (botón, tarjeta, aviso).

## Árbol de carpetas

```text
lib/
├── main.dart                    # solo llama a runApp
├── app.dart                     # MaterialApp, tema y pantalla inicial
├── nucleo/
│   ├── constantes.dart          # textos y rutas fijas
│   ├── servicios.dart           # Servicios.instancia → repositorios
│   └── tema/tema_app.dart       # colores y estilos
├── datos/                       # CAPA DE DATOS
│   ├── modelos/                 # clases simples (Unidad, Leccion, ...)
│   │   ├── ejercicio.dart
│   │   ├── leccion.dart
│   │   ├── modelos.dart         # importa todos de una vez
│   │   ├── paquete_contenido.dart
│   │   ├── progreso_leccion.dart
│   │   ├── unidad.dart
│   │   └── usuario.dart
│   ├── repositorios/
│   │   ├── repositorio_contenido.dart   # lee los JSON de assets
│   │   ├── repositorio_progreso.dart    # interfaz + versión en memoria
│   │   └── repositorio_progreso_sqlite.dart  # guarda en SQLite
│   ├── base_datos/              # (Sección A) apertura y esquema SQLite
│   ├── descargas/               # (Sección A) unidades descargadas a disco
│   └── sincronizacion/          # (Sección A) envío del avance pendiente
├── logica/                      # CAPA DE LÓGICA
│   └── controlador_leccion.dart # estado de una lección
├── pantallas/                   # CAPA DE PANTALLAS
│   ├── inicio/pantalla_inicio.dart
│   ├── aprender/
│   │   ├── pantalla_ruta.dart
│   │   ├── pantalla_leccion.dart
│   │   └── pantalla_resultado.dart
│   ├── progreso/pantalla_progreso.dart
│   └── perfil/pantalla_perfil.dart
└── widgets/
    ├── aviso_sin_conexion.dart
    ├── boton_principal.dart
    └── tarjeta_leccion.dart
```

## Reglas (las 6 que hay que respetar)

1. **De arriba hacia abajo, nunca al revés.**
   Una pantalla puede usar lógica y datos. Los datos **no** pueden importar pantallas.
2. **Las pantallas no escriben SQL ni leen JSON.** Piden a un repositorio.
3. **La lógica no conoce widgets.** `controlador_leccion.dart` no importa
   `material.dart`; así se puede probar sin dibujar nada.
4. **Todo en español:** carpetas, archivos, clases, variables y comentarios.
5. **Nombres claros y completos:** `pantalla_leccion.dart`, no `pl.dart`.
6. **Un archivo = una responsabilidad.** Si un archivo pasa de ~200 líneas,
   probablemente se puede separar.

## Flujo de una lección (ejemplo real del código)

```text
Estudiante toca "Fracciones"
        │
PantallaRuta  ──push──►  PantallaLeccion
                              │ crea
                              ▼
                    ControladorLeccion
                    (indice, aciertos, opción elegida)
                              │ al terminar
                              ▼
                    PantallaResultado
                              │ guarda
                              ▼
                    RepositorioProgreso
                    (hoy en memoria, mañana SQLite)
                              │ notifica
                              ▼
        La ruta y "Mi progreso" se actualizan solas
```

## Cómo se actualiza la pantalla sin librerías extra

No usamos provider, bloc ni riverpod. Flutter ya trae lo necesario:

- `ChangeNotifier` + `ListenableBuilder` → para una lección en curso.
- `ValueNotifier` + `ValueListenableBuilder` → para el progreso y la conexión.

Si el proyecto crece mucho, se puede migrar a provider sin reescribir los datos.

## Cómo agregar una pantalla nueva (receta)

1. Crea `lib/pantallas/mi_cosa/pantalla_mi_cosa.dart`.
2. Consume datos **solo** a través de `Servicios.instancia`.
3. Agrega el archivo a `pantallas/inicio/pantalla_inicio.dart` si va en una pestaña.
4. Escribe un test de widget en `test/pantallas/`.

## Dónde entra SQLite (Sección A)

`RepositorioProgreso` es una interfaz con dos implementaciones:

- `ProgresoMemoria` — para tests y como respaldo.
- `ProgresoSqlite` — la que usa la app (`Servicios.instancia.progreso`).

`ProgresoSqlite` actualiza la pantalla al instante y guarda en disco con
`pendienteSync = 1`. La sincronización (`ServicioSincronizacion`) envía esos
pendientes y los marca como sincronizados. Las pantallas no se tocan: esa es la
ventaja de la capa de datos.

Lo mismo con el contenido: `RepositorioContenido` puede pasar de leer `assets/`
a leer de una base local y descargar unidades, sin cambiar la UI.

## Convenciones de nombres

| Elemento | Formato | Ejemplo |
|---|---|---|
| Archivos y carpetas | `snake_case` en español | `pantalla_leccion.dart` |
| Clases | `PascalCase` en español | `RepositorioProgreso` |
| Variables y métodos | `camelCase` en español | `cargarUnidades()` |
| Booleanos | empiezan con `es`, `hay`, `tiene` | `estaCompletada`, `hayConexion` |
| Constantes | `camelCase` | `colorPrincipal` |
| Tests | `test/<capa>/<archivo>_test.dart` | `test/logica/controlador_leccion_test.dart` |

## Qué NO hacer

- ❌ Poner `http.get` o `db.query` dentro de una pantalla.
- ❌ Guardar estado de negocio en el `State` de un widget.
- ❌ Importar `material.dart` en `lib/logica/` o `lib/datos/`.
- ❌ Crear una carpeta nueva sin avisar en el chat del equipo.
- ❌ Duplicar el color o el texto de la app: va en `nucleo/`.
