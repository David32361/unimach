# Changelog

Los cambios relevantes de UniMatch se registran aqui. El formato sigue
Keep a Changelog y las versiones siguen SemVer.

## [Unreleased]

### Pendiente

- Documentar los cambios antes de cada nueva version beta.

## [0.1.0-beta.1] - 2026-10-19

### Agregado

- Descubrimiento en un feed vertical de perfiles con paginacion automatica
  hasta agotar los resultados y opcion de actualizar.
- Primer APK beta Android para tres testers, firmado con una clave de
  distribucion persistente y publicado en GitHub Releases.

### Corregido

- La compilacion de lanzamiento solicita permiso de Internet para usar Firebase.

### Pruebas beta

- Comentarios hasta el 25 de octubre de 2026 a las 23:59, zona
  `America/Mexico_City`.

## [0.1.0-dev.3] - 2026-10-19

### Cambiado

- Recuperacion de contrasena por correo con confirmacion que no revela si una
  cuenta existe y mensajes enviados en espanol.
- Acceso con Google y enlace a la recuperacion oficial de Google disponibles
  desde la pantalla de recuperacion.
- Entrega de desarrollo registrada con vencimiento el 20 de octubre de 2026;
  el codigo se publico el 19 de octubre, sin distribuirlo a testers.

## [0.1.0-dev.2] - 2026-10-19

### Agregado

- Catalogo inicial de instituciones de educacion superior de Hidalgo y carreras
  generales, con busqueda por nombre o siglas en alta y edicion de perfil.
- Anime como gusto y seleccion independiente de sus generos.

### Cambiado

- Se requieren tres gustos diferentes y, al elegir Anime, tres generos distintos.
- El perfil publico muestra los generos de anime seleccionados.
- Fecha limite prevista para comentarios de la ronda beta: 25 de octubre de
  2026 a las 23:59, hora de `America/Mexico_City`.

## [0.1.0-dev.1] - 2026-10-14

### Incluido

- Linea base local del codigo existente: app Flutter Android, panel Flutter Web
  independiente y backend Firebase.
- Version preliminar de desarrollo para ambas apps. No se ha creado una Release
  ni se ha distribuido un instalador a testers.

### Limitaciones

- La configuracion local de Firebase no se guarda en Git y debe generarse en
  cada entorno antes de compilar o ejecutar las aplicaciones.
