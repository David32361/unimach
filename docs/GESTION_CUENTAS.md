# Gestión de cuentas y soporte — beta.5

Contacto mostrado como texto: **unimatch7@gmail.com**. Sirve para quejas,
sugerencias, solicitudes de eliminación y apelaciones. No es el remitente de
Firebase y no se añadieron credenciales de correo.

## Disponible con el proyecto actual

- Perfil → Eliminar mi cuenta muestra el procedimiento de solicitud manual.
  También se puede entrar desde verificación de correo y cuenta sancionada.
- Fuera de la app: https://unimatch-daniel-2026.web.app/account-deletion/.
- La moderación guarda el motivo y un aviso privado junto con el cambio de estado
  en una operación atómica. El usuario conectado puede consultar ese motivo.
  Si Firebase ya cerró su acceso, la pantalla de acceso muestra el contacto para
  apelar; no expone públicamente el motivo ni datos de su cuenta.
- La eliminación administrativa permanente permanece deshabilitada. Marcar una
  cuenta como eliminada lógicamente no sustituye borrar Authentication y datos.

## Preparado y probado, pendiente de activar

`ACCOUNT_MANAGEMENT_ENABLED` es `false` por defecto en ambas aplicaciones.
No compilar con `true` hasta desplegar y validar las funciones siguientes:

- `deleteOwnAccount`: obtiene el UID de la sesión y exige autenticación reciente
  (cinco minutos) y confirmación `ELIMINAR`.
- `manageAccount`: valida el permiso administrativo tanto en el token como en
  Authentication. Protege las cuentas administrativas y exige autenticación
  reciente para el borrado.
- `purgeDeletedAccount`: desactiva el acceso y elimina perfiles, subcolecciones,
  intereses, bloqueos, matches, reportes y conversaciones relacionadas, incluidos
  los mensajes compartidos. El resto de cuentas y conversaciones se conserva.
  Es idempotente y reintenta errores sin declarar completado un borrado fallido.

La UI exige contraseña o reautenticación con Google para el titular; el panel pide
confirmación escrita y la contraseña administrativa cuando corresponde. Una
respuesta aceptada significa solicitud en proceso, no borrado ya terminado.

Los registros nuevos de administración vencen a los 30 días. El trabajo de borrado
vence 30 días después de completarse; nunca se programa su vencimiento antes.
Los avisos de sanción vigente no tienen TTL. Los históricos anteriores requieren
una política y limpieza aparte. El TTL de Firestore no borra instantáneamente.

## Requisito de infraestructura

Comprobado el 29 de octubre: `billingEnabled=false`; Cloud Functions no está
habilitado. El despliegue requiere Blaze. No se activó facturación ni se modificó
el plan como parte de esta entrega. Documentación oficial:
https://firebase.google.com/docs/functions/get-started

Después de que el responsable active y configure el servicio:

1. Ejecutar `npm --prefix firebase/functions ci` y `npm --prefix firebase/functions run build`.
2. Ejecutar las pruebas locales de emulador descritas abajo.
3. Desplegar `firebase deploy --only functions,firestore --project unimatch-daniel-2026`.
   Esto incluye los índices y TTL; revisar su disponibilidad y costes previamente.
4. Probar eliminación propia y administrativa con cuentas de prueba dedicadas,
   reautenticación, fallo/reintento y conservación de una cuenta ajena.
5. Compilar ambas apps con `--dart-define=ACCOUNT_MANAGEMENT_ENABLED=true` y
   distribuir una nueva versión solo después de validar el backend real.

## Correo solicitado

El remitente nativo de Firebase Authentication envía verificación, recuperación y
acciones de acceso; no ofrece una API de correo arbitrario para baneo o eliminación.
No se simula ese aviso con un correo de verificación ni se afirma «correo enviado».
Se necesita un servicio de envío adicional para cumplir esa parte de la solicitud:
https://firebase.google.com/docs/auth/admin/email-action-links

## Comprobaciones

```powershell
npm --prefix firebase/functions run build
firebase emulators:exec --only firestore --project demo-unimatch "npm --prefix firebase/functions run test:emulator"
cd unimatch_user
flutter analyze --no-pub
flutter test --no-pub
flutter test test/account_deletion_ui_test.dart --no-pub --dart-define=ACCOUNT_MANAGEMENT_ENABLED=true
```

Se usan un proyecto `demo-` y un Authentication falso; no se borran cuentas reales.
