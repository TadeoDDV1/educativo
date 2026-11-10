# SaberMóvil

Plataforma educativa **gamificada, offline-first y bilingüe** para estudiantes de
primaria, secundaria y bachillerato de comunidades rurales e indígenas con poca
conectividad.

> Aprende por materia, grado y nivel con videos de docentes certificados,
> ejercicios interactivos y progreso que se guarda en el dispositivo.

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

MVP funcionando sin internet: rutas por unidad, lecciones con video/texto,
ejercicios con retroalimentación, progreso y perfil. En curso: persistencia SQLite,
insignias, onboarding y panel docente.
