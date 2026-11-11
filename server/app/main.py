"""
SaberMóvil — API mínima para el MVP.

Endpoints:
  GET  /salud
  POST /auth
  GET  /manifest
  GET  /unidades/{paquete_id}
  POST /sync/progreso
  GET  /docente/estudiantes
  GET  /docente/resumen
  GET  /panel
  GET  /media/{archivo}

Ejecutar en desarrollo:
  pip install -r requirements.txt
  uvicorn app.main:app --reload --port 8000
"""

from __future__ import annotations

import json
import os
import sqlite3
import time
import uuid
from pathlib import Path

from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

DIRECTORIO = Path(__file__).resolve().parent
ESTATICOS = DIRECTORIO.parent / "static"
CONTENIDO = Path(
    os.environ.get(
        "CONTENIDO_DIR",
        DIRECTORIO.parent.parent / "app" / "assets" / "content",
    )
)
MEDIA = CONTENIDO / "media"
RUTA_BD = Path(os.environ.get("DB_PATH", DIRECTORIO.parent / "datos.db"))

app = FastAPI(title="SaberMóvil API", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Videos, audios e imágenes del contenido educativo.
# check_dir=False evita que la API falle si el volumen aún no está montado.
app.mount(
    "/media",
    StaticFiles(directory=MEDIA, check_dir=False),
    name="media",
)


# --------------------------------------------------------------------------
# Base de datos
# --------------------------------------------------------------------------
def abrir_bd() -> sqlite3.Connection:
    conexion = sqlite3.connect(RUTA_BD)
    conexion.row_factory = sqlite3.Row
    return conexion


def preparar_bd() -> None:
    with abrir_bd() as conexion:
        conexion.executescript(
            """
            CREATE TABLE IF NOT EXISTS usuario (
                id TEXT PRIMARY KEY,
                nombre TEXT NOT NULL,
                grado INTEGER NOT NULL,
                nivel TEXT NOT NULL,
                idioma TEXT NOT NULL,
                creado_en INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS progreso (
                usuario_id TEXT NOT NULL,
                leccion_id TEXT NOT NULL,
                titulo TEXT NOT NULL,
                aciertos INTEGER NOT NULL,
                total INTEGER NOT NULL,
                actualizado_en INTEGER NOT NULL,
                PRIMARY KEY (usuario_id, leccion_id),
                FOREIGN KEY (usuario_id) REFERENCES usuario(id)
            );
            """
        )


preparar_bd()


def bd() -> sqlite3.Connection:
    conexion = abrir_bd()
    try:
        yield conexion
    finally:
        conexion.close()


# --------------------------------------------------------------------------
# Modelos de entrada y salida
# --------------------------------------------------------------------------
class RegistroEntrada(BaseModel):
    nombre: str = Field(min_length=1, max_length=80)
    grado: int = Field(ge=1, le=6)
    # Solo educación primaria (Nueva Escuela Mexicana, 1.º a 6.º).
    nivel: str = Field(default="primaria", pattern="^primaria$")
    idioma: str = "es"


class UsuarioSalida(BaseModel):
    usuarioId: str
    nombre: str
    token: str


class ProgresoEntrada(BaseModel):
    leccionId: str
    titulo: str = ""
    aciertos: int = Field(ge=0)
    total: int = Field(ge=0)
    actualizadoEn: int | None = None


class SincronizacionEntrada(BaseModel):
    usuarioId: str
    progresos: list[ProgresoEntrada]


class EstudianteSalida(BaseModel):
    usuarioId: str
    nombre: str
    grado: int
    nivel: str
    lecciones: int
    aciertos: int
    preguntas: int


# --------------------------------------------------------------------------
# Endpoints
# --------------------------------------------------------------------------
@app.get("/panel", include_in_schema=False)
def panel_docente() -> FileResponse:
    """Panel web del docente (HTML + CSS + JS, sin dependencias externas)."""
    ruta = ESTATICOS / "panel.html"
    if not ruta.exists():
        raise HTTPException(status_code=404, detail="Panel no encontrado")
    return FileResponse(ruta, media_type="text/html; charset=utf-8")


@app.get("/salud")
def salud() -> dict[str, str]:
    return {"estado": "ok", "servicio": "sabermovil-api"}


@app.post("/auth", response_model=UsuarioSalida, status_code=201)
def registrar(datos: RegistroEntrada, conexion: sqlite3.Connection = Depends(bd)):
    usuario_id = f"u-{uuid.uuid4().hex[:10]}"
    conexion.execute(
        "INSERT INTO usuario (id, nombre, grado, nivel, idioma, creado_en) "
        "VALUES (?, ?, ?, ?, ?, ?)",
        (
            usuario_id,
            datos.nombre,
            datos.grado,
            datos.nivel,
            datos.idioma,
            int(time.time()),
        ),
    )
    conexion.commit()
    return UsuarioSalida(
        usuarioId=usuario_id,
        nombre=datos.nombre,
        token=f"demo-{usuario_id}",
    )


@app.get("/manifest")
def manifest() -> dict:
    ruta = CONTENIDO / "manifest.json"
    if not ruta.exists():
        raise HTTPException(status_code=404, detail="No hay manifest de contenido")
    return json.loads(ruta.read_text(encoding="utf-8"))


@app.get("/unidades/{paquete_id}")
def unidad(paquete_id: str) -> dict:
    manifest_data = manifest()
    paquete = next(
        (item for item in manifest_data["paquetes"] if item["id"] == paquete_id),
        None,
    )
    if paquete is None:
        raise HTTPException(status_code=404, detail="Unidad no encontrada")

    archivo = Path(paquete["archivo"]).name
    ruta = CONTENIDO / archivo
    if not ruta.exists():
        raise HTTPException(status_code=404, detail="Archivo de unidad no encontrado")
    return json.loads(ruta.read_text(encoding="utf-8"))


@app.post("/sync/progreso")
def sincronizar(
    datos: SincronizacionEntrada,
    conexion: sqlite3.Connection = Depends(bd),
) -> dict[str, int]:
    ahora = int(time.time())

    # Si el estudiante aún no se registró, lo creamos con datos mínimos.
    # Así la demo funciona aunque la app nunca haya llamado a /auth.
    conexion.execute(
        "INSERT OR IGNORE INTO usuario "
        "(id, nombre, grado, nivel, idioma, creado_en) "
        "VALUES (?, 'Estudiante', 6, 'primaria', 'es', ?)",
        (datos.usuarioId, ahora),
    )

    for progreso in datos.progresos:
        conexion.execute(
            """
            INSERT INTO progreso
                (usuario_id, leccion_id, titulo, aciertos, total, actualizado_en)
            VALUES (?, ?, ?, ?, ?, ?)
            ON CONFLICT(usuario_id, leccion_id) DO UPDATE SET
                aciertos = excluded.aciertos,
                total = excluded.total,
                actualizado_en = excluded.actualizado_en
            """,
            (
                datos.usuarioId,
                progreso.leccionId,
                progreso.titulo,
                progreso.aciertos,
                progreso.total,
                progreso.actualizadoEn or ahora,
            ),
        )
    conexion.commit()
    return {"sincronizados": len(datos.progresos)}


@app.get("/docente/estudiantes", response_model=list[EstudianteSalida])
def estudiantes(conexion: sqlite3.Connection = Depends(bd)):
    filas = conexion.execute(
        """
        SELECT u.id, u.nombre, u.grado, u.nivel,
               COUNT(p.leccion_id) AS lecciones,
               COALESCE(SUM(p.aciertos), 0) AS aciertos,
               COALESCE(SUM(p.total), 0) AS preguntas
        FROM usuario u
        LEFT JOIN progreso p ON p.usuario_id = u.id
        GROUP BY u.id
        ORDER BY u.creado_en DESC
        """
    ).fetchall()
    return [
        EstudianteSalida(
            usuarioId=fila["id"],
            nombre=fila["nombre"],
            grado=fila["grado"],
            nivel=fila["nivel"],
            lecciones=fila["lecciones"],
            aciertos=fila["aciertos"],
            preguntas=fila["preguntas"],
        )
        for fila in filas
    ]


@app.get("/docente/resumen")
def resumen(conexion: sqlite3.Connection = Depends(bd)) -> dict:
    total_estudiantes = conexion.execute(
        "SELECT COUNT(*) AS total FROM usuario"
    ).fetchone()["total"]
    total_progresos = conexion.execute(
        "SELECT COUNT(*) AS total FROM progreso"
    ).fetchone()["total"]
    return {
        "estudiantes": total_estudiantes,
        "leccionesCompletadas": total_progresos,
    }
