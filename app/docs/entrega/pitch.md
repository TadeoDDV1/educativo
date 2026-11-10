# Guion del pitch (5 minutos) — Sección D

## 1. Gancho (40 s)

> "En México, miles de estudiantes de comunidades rurales e indígenas siguen
> estudiando sin internet. Las plataformas educativas suponen conexión permanente.
> Nosotros hicimos lo contrario: **SaberMóvil aprende sin red**."

Presentar el problema con un dato local y uno nacional (rezago y escuelas sin
conectividad). No leer diapositivas.

## 2. La solución (50 s)

Mostrar la app en el celular, en modo avión:

1. Abrir SaberMóvil → se ve "Sin conexión. Tu avance se guarda en este dispositivo."
2. Entrar a Fracciones → video de la profesora → responder.
3. Ver el resultado y el progreso actualizado.

Frase clave: *"Todo lo que acaban de ver funcionó sin internet."*

## 3. Cómo funciona (60 s)

- Arquitectura de 3 capas: pantallas, lógica, datos.
- Contenido empaquetado en unidades descargables (JSON + video 480p).
- SQLite guarda el avance; cuando hay señal, se sincroniza.
- Videos validados por docentes certificados.
- Enfoque intercultural: glosario y audios en lengua indígena.
- Panel docente web en `http://localhost:8000/panel`: resumen del grupo y avance
  por estudiante, se actualiza solo cada 10 segundos.

## 4. Lo que nos hace distintos (50 s)

| Otras plataformas | SaberMóvil |
|---|---|
| Requieren internet | Funciona 100 % offline |
| Contenido general | Contenido validado por docentes y contextualizado |
| Solo español | Bilingüe e intercultural |
| Diseño para ciudades | Diseñado para gama baja y datos limitados |
| No hay seguimiento | Panel docente con alertas de rezago |

## 5. Impacto y modelo (50 s)

- Métrica principal: reducción del rezago en lectura y matemáticas.
- Indicadores: lecciones completadas, mejora en evaluaciones, constancia.
- Modelo: escuelas y municipios adoptan el servidor local; empresas o
  fundaciones patrocinan contenido y dispositivos.
- Costo por estudiante: casi cero en datos móviles, porque no consume internet.

## 6. Cierre (30 s)

> "No queremos que la falta de señal decida quién aprende. SaberMóvil lleva la
> escuela al dispositivo, y el progreso viaja cuando hay red."

Invitar a probar la app instalada en el celular.

---

## Checklist de demo (probar 30 min antes)

- [ ] APK instalado y abierto al menos una vez.
- [ ] Modo avión activado **antes** de empezar.
- [ ] Una lección completa con resultado guardado.
- [ ] Pantalla de progreso con datos.
- [ ] Celular cargado y con brillo alto.
- [ ] Video de respaldo de la demo (2 min) listo por si falla el equipo.
- [ ] Backend local corriendo solo si se va a mostrar el panel docente.
- [ ] Datos de ejemplo cargados (estudiante "Ana", 6.º).

## Preguntas probables del jurado

1. **¿Y si no tienen celular?** — Funciona en tabletas y computadoras vía web;
   la escuela puede prestar equipos y usar un servidor local.
2. **¿Cómo garantizan calidad del contenido?** — Ficha de validación con autor,
   revisor certificado y fecha; además reportes de estudiantes.
3. **¿Cómo se actualiza sin internet?** — La escuela descarga paquetes cuando
   tiene red y los distribuye por Wi-Fi local o tarjeta SD.
4. **¿Ya lo probaron con estudiantes?** — Plan de piloto con una escuela:
   diagnóstico inicial, 4 semanas de uso y evaluación comparativa.
5. **¿Qué pasa con los datos personales?** — Todo se guarda en el dispositivo;
   solo se sincroniza lo necesario y con consentimiento.
