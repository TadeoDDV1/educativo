# Licencias y créditos — SaberMóvil

Este documento resume la licencia del proyecto, las licencias del contenido
educativo y los créditos de las herramientas usadas. Aplica al código de la
aplicación Flutter, a la API del servidor y a los materiales de la carpeta
`app/assets/content`.

## 1. Licencia del código: MIT

El código fuente de SaberMóvil (aplicación Flutter, API FastAPI y panel docente)
se distribuye bajo la **Licencia MIT**.

```text
MIT License

Copyright (c) 2026 Equipo SaberMóvil

Por la presente se concede permiso, de forma gratuita, a cualquier persona que
obtenga una copia de este software y de los archivos de documentación asociados
(el "Software"), para utilizar el Software sin restricción, incluidos, entre
otros, los derechos de usar, copiar, modificar, fusionar, publicar, distribuir,
sublicenciar y/o vender copias del Software, y para permitir a las personas a
quienes se les proporcione el Software que lo hagan, con sujeción a las
siguientes condiciones:

El aviso de copyright anterior y este aviso de permiso se incluirán en todas
las copias o partes sustanciales del Software.

EL SOFTWARE SE PROPORCIONA "TAL CUAL", SIN GARANTÍA DE NINGÚN TIPO, EXPRESA O
IMPLÍCITA, INCLUIDAS, ENTRE OTRAS, LAS GARANTÍAS DE COMERCIABILIDAD, IDONEIDAD
PARA UN PROPÓSITO PARTICULAR Y NO INFRACCIÓN. EN NINGÚN CASO LOS AUTORES O
TITULARES DEL COPYRIGHT SERÁN RESPONSABLES DE NINGUNA RECLAMACIÓN, DAÑOS U
OTRA RESPONSABILIDAD, YA SEA EN UNA ACCIÓN CONTRACTUAL, EXTRACONTRACTUAL O DE
OTRO TIPO, DERIVADA DEL SOFTWARE O DE SU USO U OTRAS OPERACIONES CON EL
SOFTWARE.
```

Se eligió MIT porque permite que escuelas, organizaciones sociales y empresas
reutilicen y adapten el proyecto con muy pocas obligaciones: conservar el aviso
de copyright y la licencia.

## 2. Licencia del contenido educativo: CC BY-SA 4.0

Los materiales educativos originales de SaberMóvil —textos de lecciones,
ejercicios, guiones de video, audios en lengua indígena, ilustraciones y el
glosario— se distribuyen bajo **Creative Commons Atribución-CompartirIgual 4.0
Internacional (CC BY-SA 4.0)**.

Esto significa que cualquiera puede:

- **Compartir**: copiar y redistribuir el material en cualquier medio o formato.
- **Adaptar**: remezclar, transformar y construir a partir del material para
  cualquier propósito, incluso comercial.

Con estas condiciones:

- **Atribución**: dar crédito a SaberMóvil, indicar si se hicieron cambios y
  enlazar la licencia.
- **CompartirIgual**: si se adapta el material, la nueva obra debe distribuirse
  bajo la misma licencia CC BY-SA 4.0.
- **Sin restricciones adicionales**: no se pueden aplicar términos legales o
  medidas tecnológicas que limiten lo que la licencia permite.

Texto completo: <https://creativecommons.org/licenses/by-sa/4.0/legalcode.es>

Ejemplo de atribución:

> "Fracciones", SaberMóvil, adaptado por [nombre], licencia CC BY-SA 4.0.
> Cambios: se simplificó el lenguaje y se agregaron ejemplos locales.

Los videos protagonizados por docentes deben contar con una cesión de derechos
de imagen y voz firmada por cada persona que aparece. Si un video o audio usa
material de terceros, debe tener su propia licencia compatible y estar
acreditado en la ficha de la lección.

### Referentes curriculares

La organización del contenido (fases, Campos formativos, contenidos, PDA y ejes
articuladores) sigue el Plan de Estudio 2022 y los Programas Sintéticos de las
Fases 3 y 4 de la Secretaría de Educación Pública (2024), cuya reproducción se
autoriza para fines no comerciales reconociendo su autoría. Los PDA citados en
cada unidad son extractos o paráfrasis de esos programas. Las lecciones de
ortografía son textos originales de SaberMóvil: solo toman como referencia la
secuencia de temas de una guía comercial de ortografía, sin reproducir su texto
ni sus ejercicios.

## 3. Créditos de herramientas y dependencias

| Herramienta | Uso en SaberMóvil | Licencia |
|---|---|---|
| [Flutter](https://flutter.dev/) | Framework de la aplicación móvil | BSD 3-Clause |
| [Dart](https://dart.dev/) | Lenguaje de la app | BSD 3-Clause |
| [FastAPI](https://fastapi.tiangolo.com/) | API del servidor | MIT |
| [Uvicorn](https://www.uvicorn.org/) | Servidor ASGI | BSD 3-Clause |
| [SQLite](https://sqlite.org/) | Base de datos local (app y servidor) | Dominio público |
| [sqflite](https://pub.dev/packages/sqflite) | Acceso a SQLite desde Flutter | MIT |
| [Pydantic](https://docs.pydantic.dev/) | Validación de datos de la API | MIT |

Flutter y Dart son marcas de Google LLC. FastAPI es un proyecto de Sebastián
Ramírez. Los nombres de productos y empresas se usan solo para identificar las
herramientas y no implican patrocinio.

La lista completa de paquetes de Dart y sus licencias se puede consultar en
`app/pubspec.lock` y en la pantalla **Licencias** que Flutter genera
automáticamente (`showLicensePage`). Para Python, revisar
`server/requirements.txt`.

## 4. Consentimiento y datos de menores

SaberMóvil está pensada para estudiantes, incluidos menores de edad. Por eso:

- **Los datos viven en el dispositivo.** El progreso se guarda en una base
  SQLite local. La app no requiere cuenta de correo, teléfono ni contraseña.
- **El servidor recibe lo mínimo.** Al sincronizar se envía un identificador
  local, el **nombre**, el grado, el nivel y los resultados de las lecciones
  (aciertos y total de preguntas). No se envían fotografías, ubicación,
  contactos, fechas de nacimiento ni datos de salud.
- **Consentimiento informado.** Antes de usar la app en una escuela se debe
  pedir autorización a la madre, el padre o el tutor, y explicar qué se guarda,
  para qué y quién puede verlo. El docente responsable conserva ese
  consentimiento.
- **Acceso limitado.** El panel docente es de solo lectura y debe estar en la
  red local de la escuela. No debe publicarse en internet sin autenticación.
- **Derecho de borrado.** El estudiante o su tutor puede pedir que se borre su
  información. En la app: **Perfil → Borrar mi progreso**. En el servidor, el
  docente o administrador debe eliminar el registro correspondiente.
- **Retención.** Se recomienda conservar los datos solo durante el ciclo
  escolar y eliminarlos o anonimizarlos al terminar, salvo obligación legal.

En producción se recomienda añadir autenticación de docentes, conexión HTTPS,
respaldos cifrados y una política de privacidad revisada por la escuela.
