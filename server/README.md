# API de SaberMóvil (Sección D)

Backend mínimo para sincronizar el avance y alimentar el panel docente.
Funciona con SQLite y **no necesita internet** para la demo: la app sigue
trabajando offline y solo envía datos cuando hay red.

## Ejecutar

```bash
cd server
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
# panel docente: http://localhost:8000/panel
# documentación interactiva: http://localhost:8000/docs
```

El **panel docente** es una página web sin dependencias externas (funciona sin
internet) que muestra el resumen del grupo y la tabla con el avance de cada
estudiante. Se actualiza sola cada 10 segundos y tiene un botón **Actualizar**.

Con Docker:

```bash
cd server
docker compose up --build
# panel docente: http://localhost:8000/panel
```

El `docker-compose.yml` ya monta `app/assets/content` en `/contenido` (de ahí
sale `/media`) y guarda la base en el volumen `datos`. El panel viaja dentro de
la imagen porque el `Dockerfile` copia `app/` y `static/`. Si construyes la
imagen manualmente, usa el mismo contexto (`server/`):

```bash
docker build -t sabermovil-api .
docker run --rm -p 8000:8000 \
  -v "$PWD/../app/assets/content:/contenido:ro" \
  -e CONTENIDO_DIR=/contenido \
  sabermovil-api
```

## Endpoints

| Método | Ruta | Para qué |
|---|---|---|
| GET | `/salud` | Saber si el servicio está vivo |
| POST | `/auth` | Registrar estudiante (nombre, grado, nivel, idioma) |
| GET | `/manifest` | Índice de unidades disponibles |
| GET | `/unidades/{id}` | Contenido completo de una unidad |
| POST | `/sync/progreso` | Subir el avance guardado offline |
| GET | `/docente/estudiantes` | Lista con avance por estudiante |
| GET | `/docente/resumen` | Conteos generales del grupo |
| GET | `/panel` | Panel docente web (HTML autocontenido) |
| GET | `/media/{archivo}` | Videos, audios e imágenes del contenido |

## Ejemplo de sincronización

```bash
curl -X POST http://localhost:8000/sync/progreso \
  -H "Content-Type: application/json" \
  -d '{
    "usuarioId": "u-demo",
    "progresos": [
      {"leccionId": "l1", "titulo": "Inicio, desarrollo y final",
       "aciertos": 2, "total": 2}
    ]
  }'
```

## Pruebas

```bash
cd server
pip install pytest httpx
pytest -q
```

## Decisiones y pendientes

- El token es simulado (`demo-<usuario>`). En producción: JWT con expiración.
- La base es un SQLite local. Para varias escuelas: PostgreSQL y respaldo diario.
- Falta subida de videos: hoy se sirven desde `/media` o en el release de la app.
- El panel docente (`/panel`) es de solo lectura; la autenticación de docentes
  queda pendiente para producción.
