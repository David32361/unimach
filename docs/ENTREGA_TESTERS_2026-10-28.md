# Correcciones de testers · 28 de octubre de 2026

Entrega solicitada antes del **28 de octubre de 2026, 22:00**, zona
`America/Mexico_City`. Versión preparada: **0.1.0-beta.3+6**.

| Hallazgo | Tratamiento | Evidencia |
| --- | --- | --- |
| Contraseñas débiles | Requisitos de 8–128 caracteres, mayúscula, minúscula, número y símbolo; política aplicada también en Firebase | PR #5; validadores y script de configuración |
| Correo inventado sin verificar | Cuenta sin acceso a perfiles/datos hasta confirmar enlace enviado por Firebase | PR #5; prueba de navegación y reglas |
| Corazón sin estado visible | Pestaña de intereses enviados; match solo recíproco y conversación atómica | PR #6; pruebas de interfaz y reglas |
| «anos» en perfil | «años» y revisión de acentos en pantallas | PR #7 |
| «Texnologica» | Normalización al mostrar/guardar y nombres oficiales del catálogo | PR #7; prueba del catálogo |
| No aparecen todos los usuarios | Excluido por indicación del responsable: comprobó que sí aparecen | Sin cambio en consulta, filtros o paginación de Descubrir |
| Editar perfil | Reportado como funcionamiento correcto; se conserva | Regresión de selección de universidad y campos |

## Comprobaciones realizadas

- App de usuario: **26 pruebas aprobadas** y análisis estático sin incidencias.
- Reglas: **3 pruebas aprobadas** en el emulador, incluyendo rechazo a cuentas
  sin verificar, rechazo a match unilateral y creación atómica con reciprocidad.
- Las contraseñas antiguas siguen admitiéndose al iniciar sesión; la política
  nueva se aplica al crear/cambiar contraseñas. Las cuentas antiguas con correo
  sin verificar también deben confirmarlo para acceder a los datos.

## Confirmación por correo

Se usa `sendEmailVerification` de Firebase en español. El correo abre el
controlador de Firebase, que verifica el enlace; al pulsar **Continuar**, el
Android App Link apunta a `/email-verified/`. Una página ofrece **Abrir UniMatch**
si el navegador no inicia la app. Al volver, se consulta `reload()` y se renueva
el ID token. El botón **Ya confirmé mi correo** permite comprobarlo manualmente.
Un enlace o una URL por sí solos nunca cambian `emailVerified` en el cliente.

No se usan códigos de cuatro dígitos ni un proveedor SMTP adicional. El remitente
y la entrega usan el servicio de Firebase, como la recuperación de contraseña.

## Orden de publicación y validación pendiente en teléfono

1. Subir las ramas, revisar las pruebas e integrar mediante PRs.
2. Publicar la página de continuación y la asociación Android en Hosting.
3. Compilar y distribuir el APK beta.3 con la misma firma de las betas anteriores.
4. Publicar las reglas que requieren el correo confirmado.
5. En un teléfono con beta.3, registrar una cuenta real, abrir el correo,
   confirmar, pulsar Continuar y comprobar acceso al perfil. Probar también
   el regreso manual, enlace vencido, cuenta sin verificar, recuperación y Google.

Las pruebas automatizadas no sustituyen ese recorrido real de buzón y Android.
La beta anterior no tiene la pantalla de verificación: se debe instalar beta.3
para continuar con una cuenta sin correo confirmado tras publicar las reglas.

Fuentes originales conservadas: [Juan Pablo](https://github.com/David32361/app_unimach/blob/main/juan-pbs/README.md),
[Gael](https://github.com/David32361/app_unimach/blob/main/GaelSilis/README.md),
[Jhoana](https://github.com/David32361/app_unimach/blob/main/Jhoa-ml/README.md).
