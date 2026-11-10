# Manual de usuario — SaberMóvil

SaberMóvil es una aplicación para aprender en el celular o la tableta, **sin
necesidad de internet**. Las lecciones, los videos y tu avance quedan guardados
en el dispositivo. Cuando haya conexión con el servidor de la escuela, podrás
enviar tu avance.

---

## 1. Antes de instalar

- Necesitas un teléfono o tableta con Android y espacio libre para la app.
- Consigue el archivo **`app-release.apk`** con tu docente o en el sitio de la
  escuela. No lo descargues de sitios desconocidos.
- La app no pide cuenta de correo ni contraseña.

## 2. Instalar la app (APK)

1. Copia el archivo `app-release.apk` al teléfono (por cable, tarjeta SD o
   Bluetooth), o ábrelo directamente si ya está descargado.
2. Toca el archivo para instalarlo.
3. Si Android muestra un aviso como *"Por seguridad, tu teléfono no puede
   instalar apps desconocidas"*, toca **Configuración** y permite la instalación
   para la app de archivos o el navegador que estés usando.
4. Toca **Instalar** y espera unos segundos.
5. Al terminar, toca **Abrir**. También puedes buscar **SaberMóvil** en el menú
   de aplicaciones.

> Si no aparece el archivo, revisa que esté en la carpeta **Descargas**.

## 3. Primer uso

1. Abre SaberMóvil y toca **Continuar**.
2. Escribe tu **nombre** y toca **Continuar**.
3. Elige tu **nivel** (Primaria, Secundaria o Bachillerato), tu **grado** y tu
   **idioma**.
4. Toca **Guardar**. Verás la pantalla **Mi ruta de aprendizaje**.

Todo esto funciona sin internet. Si en ese momento no hay red, no pasa nada:
la app guarda tus datos en el dispositivo.

## 4. Usar la app sin internet

- Puedes activar el **modo avión** y la app seguirá funcionando.
- Arriba verás el mensaje: *"Sin conexión. Tu avance se guarda en este
  dispositivo."*
- Los videos y ejercicios ya están descargados en la app; no se gastan datos.
- Puedes cerrar la app y volver después: tu avance queda guardado.

## 5. Completar una lección

1. En **Aprender**, elige una unidad, por ejemplo **Fracciones**.
2. Toca una lección disponible. Las lecciones bloqueadas se abren cuando
   terminas la anterior.
3. Lee el texto y mira el video.
4. Responde la pregunta tocando una opción. Verás de inmediato si acertaste y
   una breve explicación.
5. Toca **Continuar** para pasar a la siguiente pregunta.
6. Al final, toca **Ver resultado**. Verás tus aciertos y tu porcentaje.
7. Toca **Volver a mi ruta** para seguir aprendiendo.

> La lección queda completada al responder todas las preguntas. Si aciertas
> menos del **60 %**, la app te invita a seguir practicando y puedes repetirla
> las veces que quieras.

## 6. Ver tu progreso

Toca **Progreso** en la barra inferior. Ahí verás:

- cuántas **lecciones** completaste;
- tus **aciertos** sobre el total de preguntas;
- tu **promedio** y tu racha de días;
- las **insignias** que ganaste;
- la lista de lecciones completadas con su calificación.

## 7. Sincronizar tu avance

Sincronizar significa enviar tu avance al servidor de la escuela. **No es
obligatorio para aprender**; la app funciona igual sin hacerlo.

1. Conéctate a la red o al Wi-Fi de la escuela.
2. Entra a **Perfil** (barra inferior).
3. Toca **Sincronizar avance**.
4. Si todo sale bien, verás un mensaje como *"Se enviaron 3 lecciones."*
5. Si no hay conexión con el servidor, aparecerá *"Sin conexión con el
   servidor. Tu avance sigue guardado."* No se pierde nada: inténtalo después.

## 8. ¿Qué hace el docente?

El docente entra al **panel docente** desde la computadora de la escuela:

```text
http://localhost:8000/panel
```

Desde otro equipo de la misma red, usando la dirección IP del servidor:

```text
http://192.168.1.20:8000/panel
```

En el panel puede ver:

- cuántos estudiantes hay registrados;
- cuántas lecciones se completaron en total;
- una tabla con nombre, grado, nivel, lecciones, aciertos y porcentaje de cada
  estudiante;
- el estado **"sin datos"** cuando todavía nadie ha sincronizado.

El panel se actualiza solo cada 10 segundos. También tiene un botón
**Actualizar**.

## 9. Si algo no funciona

| Problema | Qué hacer |
|---|---|
| No se instala el APK | Permite "instalar apps desconocidas" y vuelve a intentar. |
| No se ven los videos | Cierra y abre la app; el contenido ya está descargado, no necesitas internet. |
| No sincroniza | Revisa estar en la red de la escuela y que el servidor esté encendido. Tu avance no se pierde. |
| Quiero borrar mi avance | **Perfil → Borrar mi progreso**. Esta acción no se puede deshacer. |
| La app se cierra | Actualiza Android o prueba en otro dispositivo; avisa a tu docente. |

## 10. Privacidad

Tu nombre y tu avance se guardan **solo en tu dispositivo**. El servidor de la
escuela recibe únicamente un identificador, el nombre, el grado, el nivel y los
resultados de las lecciones. No se envían fotografías, ubicación ni datos de
contacto. Puedes pedir a tu docente que borre tu información.
