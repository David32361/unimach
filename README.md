# UniMatch

Version actual de desarrollo: `0.1.0-dev.2+2` en ambas aplicaciones. Aun no
existe una beta publicada para testers. Consulta [CHANGELOG.md](CHANGELOG.md)
y [docs/VERSIONADO.md](docs/VERSIONADO.md) para continuar el versionado.
Repositorio de codigo: <https://github.com/David32361/unimach>.
La fecha prevista para recibir comentarios de los testers esta en
[docs/PRUEBAS_BETA.md](docs/PRUEBAS_BETA.md).

UniMatch tiene solamente dos aplicaciones conectadas al proyecto Firebase
`unimatch-daniel-2026`:

- `unimatch_user`: aplicacion Flutter Android para usuarios.
- `unimatch_admin`: panel administrativo independiente en Flutter Web.

No incluye Smart TV, smartwatch, chatbot ni un backend independiente. Las
imagenes de perfil son avatares incluidos en las aplicaciones; no se permiten
subidas de fotografias.

## Funcionalidades

### Aplicacion de usuario

- Registro e inicio de sesion con correo y Google.
- Redireccion automatica al modulo administrativo cuando el token contiene el
  custom claim `admin: true`.
- Recuperacion de contrasena y cierre de sesion.
- Perfil con nombre, edad, genero, universidad, carrera y descripcion.
- Busqueda de instituciones de Hidalgo y carreras por nombre o siglas. El
  catalogo inicial y sus fuentes estan en [docs/CATALOGOS.md](docs/CATALOGOS.md).
- Seleccion y edicion de al menos tres gustos diferentes. Anime permite elegir
  generos y requiere al menos tres cuando se selecciona.
- Doce avatares uniformes de gatos y perros.
- Descubrir perfiles, indicar interes o descartarlos.
- Creacion automatica de Match cuando el interes es mutuo.
- Lista de Matches y conversaciones en tiempo real.
- Mensajes leidos y contador de pendientes.
- Bloqueo y reporte de usuarios.
- Registro de actividad y duracion aproximada de sesiones.
- Pantalla de cuenta suspendida, baneada o eliminada.
- Registro del token FCM del telefono para notificaciones.

### Panel administrativo

- Acceso exclusivo con Firebase Custom Claim `admin: true`.
- Disponible dentro de la aplicacion Android y tambien como panel web
  independiente.
- Dashboard con usuarios, actividad, matches, conversaciones y reportes.
- Grafica sencilla de distribucion de estados.
- Busqueda por nombre o correo.
- Filtros por genero, edad, universidad, carrera, estado, registro y actividad.
- Orden por fecha o actividad.
- Suspension, baneo, reactivacion y eliminacion logica con motivo.
- Moderacion de reportes: revisar, resolver o rechazar.
- Suspension o baneo desde un reporte.
- Consulta de mensajes unicamente de los ultimos tres dias.
- Historial inmutable de acciones administrativas.

Panel publicado: <https://unimatch-daniel-2026.web.app>

## Estructura

```text
UniMatch/
|-- unimatch_user/
|-- unimatch_admin/
|-- firebase/
|   |-- firestore.rules
|   |-- firestore.indexes.json
|   |-- storage.rules
|   |-- scripts/
|   `-- functions/
|-- firebase.json
`-- README.md
```

## Requisitos

- Flutter 3.44.1 o compatible.
- Dart 3.12.1 o compatible.
- Android SDK.
- Java 17 o posterior.
- Node.js 22 para Cloud Functions.
- Firebase CLI autenticado con `firebase login`.
- Un telefono Android con depuracion USB para la app de usuario.

## Configuracion Firebase

Firebase Authentication debe tener habilitados:

1. Correo y contrasena.
2. Google.

La aplicacion Android usa:

```text
unimatch_user/android/app/google-services.json
unimatch_user/lib/firebase_options.dart
```

La aplicacion web usa:

```text
unimatch_admin/lib/firebase_options.dart
```

Google Sign-In necesita que los SHA-1 y SHA-256 de la firma Android esten
registrados en Firebase. Despues de cambiar certificados se debe descargar de
nuevo `google-services.json`.

## Primer administrador

Primero crea la cuenta mediante Authentication o la aplicacion de usuario.
Luego, desde la raiz del proyecto, ejecuta:

```powershell
powershell -ExecutionPolicy Bypass -File firebase/scripts/set_admin_claim.ps1 -Email administrador@correo.com
```

Para revocar el permiso:

```powershell
powershell -ExecutionPolicy Bypass -File firebase/scripts/set_admin_claim.ps1 -Email administrador@correo.com -Remove
```

La cuenta debe cerrar sesion y volver a entrar para recibir un token nuevo. Las
reglas de Firestore validan el claim; ocultar botones no concede permisos.

## Ejecutar las aplicaciones

Usuario Android:

```powershell
cd unimatch_user
flutter pub get
flutter run -d android
```

Administrador Web:

```powershell
cd unimatch_admin
flutter pub get
flutter run -d chrome
```

Compilar y publicar el panel:

```powershell
flutter build web --release
cd ..
firebase deploy --only hosting
```

## Firestore y seguridad

Los documentos principales son:

```text
users/{uid}
users/{uid}/passes/{targetUid}
users/{uid}/devices/{deviceId}
users/{uid}/sessions/{sessionId}
publicProfiles/{uid}
likes/{senderId_receiverId}
matches/{matchId}
conversations/{matchId}/messages/{messageId}
blocks/{blockerId_blockedId}
reports/{reportId}
adminActions/{actionId}
```

Un usuario normal no puede listar documentos privados, consultar reportes,
leer conversaciones ajenas, cambiar estados de cuenta ni escribir acciones
administrativas. Los usuarios suspendidos, baneados o eliminados quedan
bloqueados por reglas aunque todavia conserven una sesion local.

Los administradores pueden consultar mensajes recientes, pero la regla exige
que `timestamp` sea de los ultimos tres dias. El panel aplica el mismo filtro.
Los mensajes antiguos continuan disponibles para sus participantes y no quedan
expuestos al administrador.

Desplegar reglas:

```powershell
firebase deploy --only "firestore:rules,firestore:indexes"
```

Firebase Storage permanece completamente cerrado en `firebase/storage.rules`
porque UniMatch utiliza avatares locales y no sube archivos.

## Notificaciones y plan Firebase

FCM es gratuito, pero el envio automatico desde eventos de Firestore utiliza
Cloud Functions. Firebase exige vincular facturacion y usar el plan Blaze para
desplegar estas funciones. El codigo ya incluye:

- Notificacion de nuevo Match.
- Notificacion de nuevo mensaje.
- Notificacion de cambio administrativo importante.
- Deshabilitar o reactivar Firebase Authentication segun `accountStatus`.

Tras habilitar Blaze:

```powershell
firebase deploy --only functions
```

Mientras el proyecto permanezca en Spark, registro, perfiles, descubrir,
matches, chat, bloqueos, reportes, reglas y panel web funcionan dentro de las
cuotas gratuitas. No funcionaran el envio automatico de notificaciones ni la
deshabilitacion de Auth del lado servidor; aun asi, Firestore y la app bloquean
las funciones principales de cuentas no activas.

## Pruebas

Ejecutar analisis y pruebas:

```powershell
cd unimatch_user
dart analyze lib test
flutter test

cd ../unimatch_admin
dart analyze lib test
flutter test
```

Pruebas manuales recomendadas:

1. Registrar dos cuentas y completar perfil e intereses.
2. Comprobar login por correo, Google y recuperacion de contrasena.
3. Dar interes mutuo y verificar el Match.
4. Enviar mensajes en ambas direcciones y revisar estados de lectura.
5. Bloquear un usuario y confirmar que ya no puede enviar mensajes ni likes.
6. Crear un reporte y revisarlo desde Admin.
7. Suspender, banear, reactivar y eliminar logicamente una cuenta.
8. Confirmar que una cuenta normal no puede iniciar en Admin.
9. Revisar filtros, estadisticas y tiempo de uso.
10. Confirmar que Admin no puede leer mensajes con mas de tres dias.
11. Con Blaze activo, probar notificaciones con la app en segundo plano y cerrada.
