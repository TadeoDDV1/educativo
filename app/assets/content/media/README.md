# Medios del contenido

Aquí van los videos y audios referenciados por los JSON de `assets/content/`.

- Formato: nombre `<unidadId>-<leccionId>.mp4` (ej. `prim-6-mate-u1-l1.mp4`).
- Video: H.264 + AAC, 480p, ≤ 8 MB/min. Audio: MP3 64 kbps mono.
- Los binarios de más de 5 MB **no** se suben a Git: se publican en el release
  o los sirve el backend (Sección D).
- Al agregar un archivo, actualiza el `manifest.json` correspondiente.

Comando de compresión sugerido:

```bash
ffmpeg -i original.mp4 -vf scale=-2:480 -c:v libx264 -crf 28 -preset slow \
  -c:a aac -b:a 64k prim-6-mate-u1-l1.mp4
```
