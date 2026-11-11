# Contrato de datos — v2 (primaria · Nueva Escuela Mexicana)

> **v2:** la app es solo de **primaria (1.º a 6.º)** y el contenido se organiza por
> **Campo formativo** en lugar de materia. Cambios respecto a v1:
>
> - `manifest.json` sube a `version: 2` y cada paquete agrega `fase` y `campo`.
> - Cada unidad agrega `fase`, `campo`, `contenido`, `pda` (lista),
>   `ejesArticuladores` (lista de claves), `fuente` y `estadoValidacion`.
> - `campo` ∈ `lenguajes | saberes | etica | humano`.
> - `fase` = 3 (1.º–2.º), 4 (3.º–4.º) o 5 (5.º–6.º).
> - Claves de ejes: `inclusion`, `pensamiento_critico`, `interculturalidad_critica`,
>   `igualdad_genero`, `vida_saludable`, `apropiacion_culturas`, `artes`.
> - Los `id` de lección son **únicos en toda la app**: `<idUnidad>-l<n>`
>   (en v1 todas las unidades usaban `l1`, `l2` y el progreso se mezclaba).
> - `nivel` siempre es `"primaria"` (app, SQLite y API).
> - Compatibilidad: si un JSON v1 trae `materia` y no `campo`, la app lo traduce
>   (`espanol` → `lenguajes`; `matematicas`/`ciencias` → `saberes`).
>
> Ejemplo de unidad v2: `app/assets/content/prim-3-leng-u1.json`.
> Mapa curricular: `app/docs/contenido/mapa-curricular-nem.md`.

---

## Historial: v1

Dueño: **Sección A**. Consumidores: **Sección B** (JSON de contenido) y **Sección C** (UI).

## Regla de cambio

1. Cualquier cambio se propone en una tarjeta con etiqueta `contrato`.
2. A lo implementa y sube la versión (`v1` → `v2`) en este archivo y en `manifest.json`.
3. A avisa a B y C; B regenera el JSON y C ajusta la UI.
4. Nunca se rompe una versión publicada: se agrega, no se renombra.

## Modelos Dart

`app/lib/datos/modelos/` (barrel: `modelos.dart`): `Usuario`, `PaqueteContenido`,
`Unidad`, `Leccion`, `Ejercicio`, `ProgresoLeccion`.

## Interfaz de repositorios (lo que A debe respetar)

```dart
// RepositorioContenido
Future<List<Unidad>> cargarUnidades();
Future<Unidad> cargarUnidad(PaqueteContenido paquete);

// RepositorioProgreso (interfaz; hay versión en memoria y en SQLite)
ValueListenable<Map<String, ProgresoLeccion>> get escuchar;
Future<void> iniciar();          // carga lo guardado al abrir la app
ProgresoLeccion? buscar(String leccionId);
bool estaCompletada(String leccionId);
Future<void> guardar(ProgresoLeccion progreso);
Future<void> borrarTodo();
int get aciertosTotales;
int get preguntasTotales;
int get racha;
```

`ProgresoSqlite` agrega dos métodos para la sincronización:
`pendientesDeSincronizar()` y `marcarSincronizadas(List<String>)`.

## Esquema SQLite (v1)

```sql
usuario(id TEXT PK, nombre TEXT, grado INT, nivel TEXT, idioma TEXT, avatar TEXT, creadoEn INT)
materia(id TEXT PK, nombre TEXT, icono TEXT, color TEXT)
unidad(id TEXT PK, materiaId TEXT, grado INT, titulo TEXT, orden INT, descargada INT DEFAULT 0)
leccion(id TEXT PK, unidadId TEXT, titulo TEXT, orden INT, videoPath TEXT, texto TEXT)
ejercicio(id TEXT PK, leccionId TEXT, tipo TEXT, pregunta TEXT, opcionesJson TEXT,
          correcta INT, explicacion TEXT, imagen TEXT)
progreso(id TEXT PK, usuarioId TEXT, leccionId TEXT, estado TEXT, intentos INT,
         aciertos INT, actualizadoEn INT, pendienteSync INT DEFAULT 1)
insignia(id TEXT PK, usuarioId TEXT, codigo TEXT, obtenidaEn INT)
descarga(id TEXT PK, unidadId TEXT, estado TEXT, bytes INT, actualizadoEn INT)
```

## Paquete de contenido

Ver `app/assets/content/prim-6-mate-u1.json` (ejemplo canónico) y
`app/assets/content/manifest.json` (índice de paquetes).

Campos obligatorios por lección: `id`, `titulo`, `orden`, `texto`, `ejercicios`.
Campos obligatorios por ejercicio: `id`, `tipo`, `pregunta`, `opciones`, `correcta`.
`video` puede ser `null` (lección solo texto/audio).

## Medios

- Videos: H.264/AAC, 480p, ≤ 8 MB por minuto, nombre `<unidad>-<leccion>.mp4`.
- Audio: MP3 64 kbps mono.
- Rutas relativas a `assets/content/`.
- No se versionan binarios > 5 MB; se guardan en `assets/content/media/` y se
  distribuyen por el release o el servidor de D.
