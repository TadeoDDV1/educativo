# SaberMóvil — Plan de trabajo (Flutter + SQLite)

Plataforma educativa gamificada, offline-first y bilingüe para primaria, secundaria y bachillerato en comunidades rurales e indígenas.

- **Proyecto Flutter:** `app/` (nombre `sabermovil`, org `com.raicesdelsaber`)
- **Stack base:** Flutter 3.44 · Dart 3.12 · SQLite (`sqflite`) · almacenamiento local de archivos · sincronización opcional
- **Arquitectura:** 3 capas simples — `pantallas` → `logica` → `datos` (ver `app/docs/arquitectura.md`)
- **Meta del MVP:** 1 grado (6.º de primaria) · 3 materias · 2 unidades por materia · video + ejercicios + progreso + insignias · **funciona 100 % sin internet**

## Estado actual (arranque)

Ya está funcionando y con tests: shell de 3 pestañas, ruta de aprendizaje con
desbloqueo secuencial, lección con ejercicios y retroalimentación, resultado con
guardado, pantalla de progreso, perfil, aviso de "sin conexión" y una unidad real
de ejemplo (`prim-6-mate-u1`). Falta lo que está marcado en cada sección.

---

## 0. Reglas del juego (leer antes de escribir código)

> **Arquitectura completa en `app/docs/arquitectura.md`.** Resumen: 3 capas
> (`pantallas` → `logica` → `datos`) y todo nombrado en español.

### Estructura de carpetas

```text
app/
├── lib/
│   ├── main.dart                  # solo llama a runApp
│   ├── app.dart                   # MaterialApp, tema y pantalla inicial (C)
│   ├── nucleo/                    # común a todos
│   │   ├── constantes.dart
│   │   ├── servicios.dart         # Servicios.instancia → repositorios
│   │   └── tema/tema_app.dart
│   ├── datos/                     # Sección A
│   │   ├── modelos/               # contratos compartidos (A define, B y C usan)
│   │   ├── repositorios/          # contenido y progreso
│   │   ├── base_datos/            # esquema, migraciones, DAOs (A)
│   │   └── sincronizacion/        # cola de envío (A)
│   ├── logica/                    # Sección C (controladores, reglas del juego)
│   ├── pantallas/                 # Sección C, una carpeta por pantalla
│   │   ├── inicio/
│   │   ├── aprender/
│   │   ├── progreso/
│   │   └── perfil/
│   └── widgets/                   # piezas visuales reutilizables (C)
├── assets/
│   ├── content/                   # Sección B: JSON + manifest
│   │   └── media/                 # videos y audios (no van a Git)
│   └── images/                    # ilustraciones de los ejercicios (B)
├── test/                          # test/logica, test/pantallas, test/datos
└── docs/                          # arquitectura, contratos, contenido, entrega
```

### Flujo con Git

| Rama | Quién | Regla |
|---|---|---|
| `main` | Nadie directo | Solo merges de PR aprobados |
| `feat/datos-offline` | Sección A | Solo toca `lib/datos/**`, `test/datos/**` |
| `feat/contenido` | Sección B | Solo toca `assets/content/**`, `assets/images/**`, `app/docs/contenido/**` |
| `feat/ui` | Sección C | Solo toca `lib/pantallas/**`, `lib/widgets/**`, `lib/logica/**`, `lib/nucleo/tema/**`, `lib/app.dart` |
| `feat/backend-panel` | Sección D | Solo toca `server/**`, `app/docs/entrega/**`, `.github/**` |

**Reglas de oro**
1. Nadie edita archivos de otra sección. Si necesitas un cambio en el contrato de datos, se pide a la Sección A y se versiona.
2. Un PR = una tarea del tablero. Título: `[A2] DAO de lecciones`.
3. Todo PR debe pasar `flutter analyze` y `flutter test` antes de pedir revisión.
4. Commits pequeños y en español: `feat(datos): agrega tabla progreso`.
5. Los videos NUNCA se suben a Git si pesan más de 5 MB: van a `assets/content/media/` ignorado, con un `media/README.md` que dice de dónde bajarlos.

### Contrato de contenido (lo define A, lo llena B, lo pinta C)

Un archivo `assets/content/manifest.json` lista los paquetes descargables:

```json
{
  "version": 1,
  "paquetes": [
    {
      "id": "prim-6-mate-u1",
      "grado": 6,
      "nivel": "primaria",
      "materia": "matematicas",
      "titulo": "Fracciones",
      "archivo": "content/prim-6-mate-u1.json",
      "tamanoKb": 480,
      "idioma": "es",
      "version": 1
    }
  ]
}
```

Un paquete de unidad:

```json
{
  "id": "prim-6-mate-u1",
  "titulo": "Fracciones",
  "materia": "matematicas",
  "grado": 6,
  "nivel": "primaria",
  "objetivo": "Comprender y operar fracciones equivalentes",
  "lecciones": [
    {
      "id": "l1",
      "titulo": "¿Qué es una fracción?",
      "video": "media/prim-6-mate-u1-l1.mp4",
      "duracionSeg": 240,
      "guionDocente": "docs/contenido/prim-6-mate-u1-l1.md",
      "autor": "Profa. Ana López",
      "validadoPor": "Coord. Académica",
      "texto": "Una fracción representa...",
      "ejercicios": [
        {
          "id": "e1",
          "tipo": "opcion_multiple",
          "pregunta": "¿Qué fracción está sombreada?",
          "imagen": "images/fraccion1.png",
          "opciones": ["1/2", "1/3", "2/3", "3/4"],
          "correcta": 0,
          "explicacion": "Hay 1 parte sombreada de 2 totales."
        }
      ]
    }
  ]
}
```

### Esquema SQLite (borrador que A confirma en la semana 1)

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

---

## 1. Sección A — Núcleo de datos offline, descargas y sincronización

**Misión:** que la app funcione completa sin internet y que nada se pierda.

**Perfil:** 1–2 personas con gusto por arquitectura, SQL y estado.

**Entregables**
- [ ] Proyecto Flutter con dependencias agregadas y compilando en Android.
- [ ] Esquema SQLite + migraciones versionadas + apertura de BD.
- [ ] Modelos inmutables con `fromJson` / `toMap` (contratos congelados y documentados).
- [ ] Repositorios: `RepositorioUsuario`, `RepositorioContenido`, `RepositorioProgreso`, `RepositorioInsignia`.
- [ ] Carga inicial (seed) del contenido desde `assets/content/`.
- [ ] Servicio de descarga de unidades: copiar JSON + media a almacenamiento interno, marcar `descargada`, calcular tamaño y permitir borrar.
- [ ] Cálculo de progreso y rachas a partir de `progreso`.
- [ ] Cola de sincronización (`pendienteSync`) con reintentos y simulación de envío (endpoint de D o mock).
- [ ] 15+ tests unitarios de repositorios y progreso.

**Archivos que posee:** `lib/datos/**`, `test/datos/**`, `app/docs/contratos-datos.md`

**Criterios de aceptación**
1. Insertar 40 ejercicios, responder, cerrar la app y ver el progreso intacto.
2. Descargar una unidad, apagar el WiFi y completarla sin errores.
3. `flutter test` verde y cobertura de `lib/datos` ≥ 60 %.

**Dependencias sugeridas:** `sqflite`, `path`, `path_provider`, `shared_preferences`, `connectivity_plus`, `uuid`, `sqflite_common_ffi` (tests).

**Tareas del tablero**
| ID | Tarea | Est. |
|---|---|---|
| A1 | Modelo de datos y `docs/contratos-datos.md` | 4 h |
| A2 | Apertura de BD, esquema y migración v1 | 4 h |
| A3 | DAOs + repositorios de contenido | 8 h |
| A4 | Repositorio de progreso, rachas e insignias | 6 h |
| A5 | Seed desde assets y validación de JSON | 4 h |
| A6 | Descarga/borrado de unidades y espacio usado | 6 h |
| A7 | Cola de sincronización con reintentos | 6 h |
| A8 | Tests de datos | 6 h |

---

## 2. Sección B — Contenido educativo, videos y enfoque intercultural

**Misión:** que lo que se aprende sea correcto, útil y culturalmente pertinente.

**Perfil:** 1–2 personas (ideal: alguien de pedagogía + alguien de guion/edición).

**Entregables**
- [ ] Mapa curricular del MVP: 6.º primaria · Matemáticas, Español, Ciencias Naturales.
- [ ] 6 unidades (2 por materia) con objetivo, 3 lecciones cada una y 5–8 ejercicios por lección, en el **JSON del contrato**.
- [ ] 18 videos cortos (3–6 min) o, si no hay tiempo, 6 videos reales + 12 con guion listo y `video: null`.
- [ ] Guion pedagógico por lección (`docs/contenido/*.md`).
- [ ] Ficha de validación: quién grabó, quién revisó, fecha, licencia.
- [ ] Glosario español–lengua indígena de 30 términos + 2 lecciones con audio narrado.
- [ ] Versión ligera de cada video (480p) y opción audio-only.
- [ ] `manifest.json` completo y validado por A.

**Archivos que posee:** `assets/content/**`, `assets/images/**`, `app/docs/contenido/**`

**Criterios de aceptación**
1. El JSON pasa el validador de A sin errores.
2. Cada video tiene autor y revisor certificado registrados.
3. Cada lección se completa en ≤ 10 min y tiene al menos 5 ejercicios.
4. Un hablante nativo revisó las traducciones y audios.

**Tareas del tablero**
| ID | Tarea | Est. |
|---|---|---|
| B1 | Mapa curricular y plantilla de lección | 4 h |
| B2 | Unidad 1 Matemáticas (guion + ejercicios) | 8 h |
| B3 | Unidad 2 Matemáticas | 8 h |
| B4 | Unidad 1 Español | 8 h |
| B5 | Unidad 2 Español | 8 h |
| B6 | Unidad 1 Ciencias | 8 h |
| B7 | Unidad 2 Ciencias | 8 h |
| B8 | Grabación y edición de videos + 480p | 12 h |
| B9 | Glosario bilingüe y audios | 8 h |
| B10 | Fichas de validación y licencias | 3 h |

---

## 3. Sección C — Interfaz, gamificación y accesibilidad

**Misión:** que se sienta como Duolingo y que se entienda sin manual.

**Perfil:** 1–2 personas fuertes en Flutter/UI.

**Entregables**
- [ ] Design system: colores, tipografías, botones, tarjetas, estados vacíos y de error (`lib/nucleo/tema/`).
- [ ] `app.dart` + `pantalla_inicio.dart` con las tres secciones (Aprender · Progreso · Perfil).
- [ ] Onboarding: nivel, grado, idioma, diagnóstico corto.
- [ ] Ruta de aprendizaje tipo Duolingo (nodos, candados, estrellas, racha).
- [ ] Pantalla de lección: video (`video_player`), texto, ejercicio de opción múltiple, retroalimentación y explicación.
- [ ] Pantalla de resultados con puntaje, insignias y "continuar".
- [ ] Panel de progreso: unidades, aciertos, racha, tiempo de estudio.
- [ ] Perfil + selector de idioma + borrar descargas.
- [ ] Indicadores de offline ("sin conexión, tu avance se guarda").
- [ ] Widgets reutilizables y tests de widgets de las pantallas clave.

**Archivos que posee:** `lib/pantallas/**`, `lib/widgets/**`, `lib/logica/**`, `lib/nucleo/tema/**`, `lib/app.dart`, `test/pantallas/**`

**Criterios de aceptación**
1. Flujo completo: onboarding → ruta → lección → resultados → progreso, sin tocar código de datos.
2. Funciona con datos reales de A y contenido de B.
3. Contraste AA, textos escalables, botones ≥ 48 dp, todo en español.
4. Sin conexión no aparece ningún error bloqueante.

**Dependencias sugeridas:** `video_player`, `google_fonts`, `flutter_svg`, `lottie` (opcional), `percent_indicator`.

**Tareas del tablero**
| ID | Tarea | Est. |
|---|---|---|
| C1 | Tema, tipografía y catálogo de widgets | 6 h |
| C2 | Shell de navegación y ruteo | 4 h |
| C3 | Onboarding y diagnóstico | 6 h |
| C4 | Ruta de aprendizaje gamificada | 8 h |
| C5 | Reproductor de video + lección | 10 h |
| C6 | Ejercicios y retroalimentación | 8 h |
| C7 | Resultados e insignias | 6 h |
| C8 | Progreso y perfil | 6 h |
| C9 | Estados offline/error/vacío | 4 h |
| C10 | Tests de widgets del flujo | 6 h |

---

## 4. Sección D — Backend, panel docente, calidad y entrega

**Misión:** que el proyecto se vea profesional, se pueda demostrar y sobreviva a preguntas del jurado.

**Perfil:** 1–2 personas (backend + QA/documentación).

**Entregables**
- [ ] API mínima (`server/`, FastAPI o Node/Express) con: `POST /auth`, `GET /manifest`, `POST /sync/progreso`, `GET /docente/grupo/{id}`.
- [ ] Almacenamiento de videos con URLs firmadas y guía de compresión (`ffmpeg`).
- [ ] Panel docente web mínimo (o pantalla Flutter `teacher`): lista de estudiantes, avance por unidad, alertas de rezago.
- [ ] Modo demo sin backend: datos mock para presentar aunque falle el WiFi.
- [ ] CI en GitHub Actions: `flutter analyze`, `flutter test`, build APK.
- [ ] Plan de pruebas: matriz de casos, pruebas en dispositivo real, checklist de demo.
- [ ] Documentación de entrega: README, arquitectura, licencias, manual de usuario de 2 páginas.
- [ ] Guion del pitch (5 min) + diapositivas + video de respaldo de la demo.
- [ ] Instalador/APK firmado y publicado en Release.

**Archivos que posee:** `server/**`, `app/docs/entrega/**`, `.github/**`, `README.md`

**Criterios de aceptación**
1. `docker compose up` levanta el backend y el panel en < 2 min.
2. La demo funciona en modo avión de principio a fin.
3. APK instalable en un dispositivo de gama baja sin fallos.
4. CI verde y release publicado.

**Tareas del tablero**
| ID | Tarea | Est. |
|---|---|---|
| D1 | Contratos de API y esqueleto del servidor | 6 h |
| D2 | Endpoint de sincronización + almacenamiento | 8 h |
| D3 | Panel docente mínimo | 8 h |
| D4 | Datos mock y modo demo | 4 h |
| D5 | CI + build APK | 4 h |
| D6 | Matriz de pruebas y pruebas en dispositivo | 6 h |
| D7 | Documentación y licencias | 4 h |
| D8 | Guion del pitch, diapositivas y video de respaldo | 6 h |

---

## 5. Cronograma sugerido (4 semanas)

| Semana | A | B | C | D |
|---|---|---|---|---|
| 1 | Modelo, BD, contratos | Mapa curricular, guiones | Tema, shell, onboarding | API, CI, repo |
| 2 | Repos, seed, test | Unidades 1–3, videos | Ruta + lección | Sync, panel |
| 3 | Descargas, sync | Unidades 4–6, audios | Ejercicios, resultados, progreso | Panel, mock demo |
| 4 | Integración y bugs | Validación y licencias | Pulido y accesibilidad | QA, APK, pitch |

**Hito de integración:** fin de semana 2, la app debe mostrar la ruta y abrir una lección con datos reales.
**Congelamiento de features:** 72 h antes de la entrega. Solo bugs.

---

## 6. Tablero compartido (copiar a Trello/Notion/GitHub Projects)

Columnas: **Por hacer · En curso · En revisión · Hecho**
Etiquetas: `A-datos` `B-contenido` `C-ui` `D-entrega` `bug` `bloqueante`
Cada tarjeta: ID del plan, criterio de aceptación y responsable.

Reuniones:
- **Daily async** (5 min, por chat): qué hice, qué sigue, qué me bloquea.
- **Revisión semanal** (30 min): demo funcional, no diapositivas.
- **Bloqueos de contrato:** los resuelve A en ≤ 24 h.

---

## 7. Definition of Done (aplica a todo)

- [ ] Código formateado (`dart format`) y sin warnings en `flutter analyze`.
- [ ] Tests de la sección pasando.
- [ ] PR revisado por otra sección.
- [ ] Funciona en modo avión (si toca UI o datos).
- [ ] Documentado en `docs/` si cambia un contrato o un flujo.
- [ ] Sin `print()` sueltos, sin credenciales en el repo.

---

## 8. Riesgos y dueño

| Riesgo | Dueño | Mitigación |
|---|---|---|
| Videos muy pesados | B + D | 480p, audio-only, compresión ffmpeg |
| Contratos cambian tarde | A | Congelar en semana 1, versionado |
| Nadie integra | Todos | Hito de semana 2 y demo diaria |
| Falla el WiFi en la demo | D | Modo avión + APK local + video respaldo |
| Contenido sin validar | B | Ficha de validación obligatoria |
