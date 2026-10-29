# Changelog

Los cambios relevantes de UniMatch se registran aqui. El formato sigue
Keep a Changelog y las versiones siguen SemVer.

## [Unreleased]

Sin cambios pendientes de registrar.

## [1.0.0] - 2026-10-29

### Entrega final

- Cierre solicitado del proyecto mediante tag anotado y Release estable `v1.0.0`.
- Versión `1.0.0+9` en usuario y panel; APK firmado con la clave persistente.
- Consolida las mejoras de seguridad, verificación por correo, interacciones,
  ortografía, logo, soporte y apelaciones de las betas anteriores.
- Incluye la corrección de servidor para motivos breves de moderación como «Spam».
- Se conserva desactivado el borrado automático hasta habilitar y validar el
  backend en Blaze. La solicitud manual y el contacto sí están disponibles.
- No se habilitaron correos personalizados de sanción, facturación ni publicación
  en Amazon Appstore. Una Release estable de GitHub no activa esos servicios.

## [0.1.0-beta.5] - 2026-10-29

### Agregado

- Contacto de soporte y apelaciones: unimatch7@gmail.com, como texto seleccionable.
- Pantalla para solicitar eliminación desde perfil, verificación y cuenta sancionada;
  página pública con instrucciones para personas sin acceso a la app.
- Motivo privado de la suspensión o baneo e instrucciones para apelar.
- Backend de eliminación propia y administrativa con confirmación de identidad,
  borrado de datos relacionados, reintentos y pruebas con cuentas ficticias.

### Disponibilidad

- El borrado automático está desactivado: el proyecto actual usa Spark sin
  facturación y no permite desplegar Cloud Functions. Esta beta ofrece la vía
  de solicitud manual, sin afirmar que el borrado ya se haya ejecutado.
- Los avisos de moderación se muestran dentro de la app. Firebase Authentication
  no ofrece correos personalizados de sanción mediante su remitente nativo.
- Versión 0.1.0-beta.5+8. No se borraron cuentas reales durante las pruebas.

## [0.1.0-beta.4] - 2026-10-29

### Agregado

- Logo propio de UniMatch en las pantallas de acceso, registro, recuperación
  y confirmación de correo; también en el panel administrativo y la página
  de regreso desde el correo.
- Icono Android en cinco densidades, icono adaptativo y monocromático temático.
- Favicons e iconos de instalación web con la misma identidad.
- Original PNG transparente y script para exportar tamaños de forma reproducible.

### Cambiado

- Versión `0.1.0-beta.4+7`, con la misma firma Android de las betas anteriores.

## [0.1.0-beta.3] - 2026-10-28

### Seguridad

- Contraseñas de 8–128 caracteres con mayúscula, minúscula, número y símbolo,
  también exigidas en Firebase; las contraseñas antiguas siguen admitiéndose al entrar.
- Confirmación del correo mediante enlace Firebase antes de completar el perfil
  o acceder a datos; reenvío con espera, comprobación al volver y Android App Links.
- Reglas Firestore que exigen correo verificado.

### Corregido

- «años» en Perfil, acentos y textos de acceso, recuperación, gustos y mensajes.
- Normalización de «Texnologica» y nombres de instituciones al mostrar y guardar.
- Creación atómica de like recíproco, match y conversación, sin sobrescribir chats.

### Agregado

- Pestaña de intereses enviados y explicación de la reciprocidad necesaria para match.
- Ramas por responsabilidad, PRs, merges explícitos, plantilla y CI con pruebas
  de ambas apps, compilación de funciones y reglas en emulador.
- Evidencia de atención a los testers y versión `0.1.0-beta.3+6`.

El reporte de perfiles faltantes se excluyó por indicación del responsable;
se conserva la consulta y paginación de Descubrir.

## [0.1.0-beta.2] - 2026-10-20

### Agregado

- Enlace a la politica de privacidad en acceso, registro y perfil.
- Borrador de privacidad y revision de requisitos de Amazon Appstore,
  incluidos los bloqueos de eliminacion de cuenta y compatibilidad Fire OS.
- Canal de comentarios en el repositorio `app_unimach` para testers.

### Cambiado

- Version Android `0.1.0-beta.2+5`; se mantiene la fecha limite de
  comentarios del 25 de octubre de 2026.

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
