# SaberMóvil

Plataforma educativa **gamificada, offline-first y bilingüe** para estudiantes de
**educación primaria (1.º a 6.º)** de comunidades rurales e indígenas con poca
conectividad, alineada a la **Nueva Escuela Mexicana** (Plan de Estudio 2022).

> Aprende por Campo formativo y grado con lecciones cortas, ejercicios
> interactivos y progreso que se guarda en el dispositivo.

## Currículo: Nueva Escuela Mexicana

El contenido se organiza como lo marca el Plan de Estudio 2022, no por materias:

| Fase | Grados | Fuente usada |
|---|---|---|
| 3 | 1.º y 2.º | Programa Sintético de la Fase 3 (SEP, 2024) |
| 4 | 3.º y 4.º | Programa Sintético de la Fase 4 (SEP, 2024) |
| 5 | 5.º y 6.º | Plan de Estudio 2022 — *pendiente de cotejar con el Programa Sintético de la Fase 5* |

Cada grado tiene unidades de los **cuatro Campos formativos**: Lenguajes;
Saberes y Pensamiento Científico; Ética, Naturaleza y Sociedades; y De lo Humano
y lo Comunitario. Cada unidad declara el **contenido** del programa, sus **PDA**
(Procesos de Desarrollo de Aprendizaje) y los **ejes articuladores** que trabaja.
Las lecciones de ortografía de Lenguajes (3.º a 5.º) toman como referencia la
secuencia temática de una guía de ortografía (sílabas, acentuación, b/v, c/s/z,
g/j, homófonas, puntuación), adaptada y redactada para primaria.

Mapa completo: [`app/docs/contenido/mapa-curricular-nem.md`](app/docs/contenido/mapa-curricular-nem.md).
Todas las unidades están en estado `borrador` hasta que una o un docente las valide.

## Estructura

```text
concurso/
├── app/                    # Aplicación Flutter (Android, iOS, web)
│   ├── lib/
│   │   ├── pantallas/      # interfaz
│   │   ├── logica/         # reglas del juego
│   │   ├── datos/          # modelos y repositorios
│   │   ├── nucleo/         # tema, constantes, servicios
│   │   └── widgets/        # piezas reutilizables
│   ├── assets/content/     # JSON de unidades + manifest + media
│   ├── test/               # pruebas de lógica, datos y pantallas
│   └── docs/               # arquitectura, contratos, contenido, entrega
├── server/                 # API FastAPI + SQLite (Sección D)
├── .github/workflows/      # CI: analyze, test y APK
└── PLAN.md                 # plan de trabajo y reparto por secciones
```

## Empezar

```bash
cd app
flutter pub get
flutter test
flutter run                 # con un dispositivo conectado
```

Compilar APK para instalar en el celular:

```bash
cd app
flutter build apk --release
# build/app/outputs/flutter-apk/app-release.apk
```

API (opcional, para sincronizar avance):

```bash
cd server
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## Documentación

- [`PLAN.md`](PLAN.md) — plan, cronograma y reparto de las 4 secciones.
- [`app/docs/arquitectura.md`](app/docs/arquitectura.md) — arquitectura de 3 capas.
- [`app/docs/contratos-datos.md`](app/docs/contratos-datos.md) — modelos, JSON y SQLite.
- [`app/docs/entrega/pitch.md`](app/docs/entrega/pitch.md) — guion para el jurado.

## Estado

MVP funcionando sin internet: 30 unidades de 1.º a 6.º de primaria (63 lecciones,
227 ejercicios) organizadas por Campo formativo, lecciones con video/texto,
ejercicios con retroalimentación, progreso y perfil. En curso: persistencia SQLite,
insignias, onboarding y panel docente.
