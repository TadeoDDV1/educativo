from __future__ import annotations

import os
import sys
import tempfile
import time
from pathlib import Path

os.environ.setdefault(
    "DB_PATH", os.path.join(tempfile.mkdtemp(), "pruebas.db")
)
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402

cliente = TestClient(app)


def test_salud():
    respuesta = cliente.get("/salud")
    assert respuesta.status_code == 200
    assert respuesta.json()["estado"] == "ok"


def test_manifest_tiene_unidades():
    respuesta = cliente.get("/manifest")
    assert respuesta.status_code == 200
    paquetes = respuesta.json()["paquetes"]
    assert len(paquetes) >= 3
    assert any(paquete["id"] == "prim-6-mate-u1" for paquete in paquetes)


def test_unidad_inexistente_da_404():
    assert cliente.get("/unidades/no-existe").status_code == 404


def test_panel_docente_responde_html():
    respuesta = cliente.get("/panel")
    assert respuesta.status_code == 200
    assert "text/html" in respuesta.headers["content-type"]
    assert "Panel docente" in respuesta.text


def test_flujo_registro_sincronizacion_y_panel():
    registro = cliente.post(
        "/auth",
        json={
            "nombre": "Estudiante de prueba",
            "grado": 6,
            "nivel": "primaria",
            "idioma": "es",
        },
    )
    assert registro.status_code == 201
    usuario_id = registro.json()["usuarioId"]

    sincronizacion = cliente.post(
        "/sync/progreso",
        json={
            "usuarioId": usuario_id,
            "progresos": [
                {
                    "leccionId": "l1",
                    "titulo": "Inicio, desarrollo y final",
                    "aciertos": 2,
                    "total": 2,
                    "actualizadoEn": int(time.time()),
                }
            ],
        },
    )
    assert sincronizacion.status_code == 200
    assert sincronizacion.json()["sincronizados"] == 1

    estudiantes = cliente.get("/docente/estudiantes").json()
    estudiante = next(item for item in estudiantes if item["usuarioId"] == usuario_id)
    assert estudiante["lecciones"] == 1
    assert estudiante["aciertos"] == 2

    resumen = cliente.get("/docente/resumen").json()
    assert resumen["estudiantes"] >= 1


def test_sincronizar_usuario_nuevo_lo_crea():
    respuesta = cliente.post(
        "/sync/progreso",
        json={
            "usuarioId": "u-nuevo",
            "progresos": [
                {"leccionId": "l1", "titulo": "Uno", "aciertos": 1, "total": 1}
            ],
        },
    )
    assert respuesta.status_code == 200
    assert respuesta.json()["sincronizados"] == 1

    estudiantes = cliente.get("/docente/estudiantes").json()
    assert any(item["usuarioId"] == "u-nuevo" for item in estudiantes)


def test_manifest_solo_primaria_por_campo_formativo():
    paquetes = cliente.get("/manifest").json()["paquetes"]
    campos = {"lenguajes", "saberes", "etica", "humano"}
    for paquete in paquetes:
        assert paquete["nivel"] == "primaria"
        assert 1 <= paquete["grado"] <= 6
        assert paquete["campo"] in campos
    for grado in range(1, 7):
        assert {p["campo"] for p in paquetes if p["grado"] == grado} == campos


def test_registro_rechaza_niveles_que_no_son_primaria():
    for nivel in ("secundaria", "bachillerato"):
        respuesta = cliente.post(
            "/auth",
            json={"nombre": "Prueba", "grado": 2, "nivel": nivel},
        )
        assert respuesta.status_code == 422


def test_registro_sin_nivel_usa_primaria():
    respuesta = cliente.post("/auth", json={"nombre": "Prueba", "grado": 1})
    assert respuesta.status_code == 201
