# Revision para Amazon Appstore

Revision del 20 de octubre de 2026. Estado: **no listo para enviar**. Esta
auditoria es para la app Android de usuarios; el panel Admin Flutter Web no
es un APK para Amazon Appstore.

## Comprobado en el proyecto

- Existe una app Android con paquete `com.unimatch.unimatch_user`, permiso de
  Internet y version nueva `0.1.0-beta.2+5` (`versionCode` 5).
- El APK de lanzamiento se compilo y se verifico con `apksigner`, paquete
  `com.unimatch.unimatch_user`, `versionCode` 5, `minSdk` 24 y `targetSdk` 36.
  Su SHA-256 es
  `2a85a878103fb2ab3a6e743ac1ce817856a7091e049ff698eee9050c47bb40ff`.
  La clave de firma persistente es local y no se sube a Git.
- El acceso a la politica de privacidad aparece en inicio de sesion, registro
  y perfil. La URL apunta a `PRIVACIDAD.md` de `app_unimach`.
- La app no vende bienes digitales ni usa compras integradas.
- El registro de perfil exige una edad declarada de 18 a 99 anos.

## Bloqueos antes de solicitar aprobacion

1. Revisar legalmente el aviso integral y validar que el domicilio declarado
   por el responsable (Barrio Moxthe, La Vega, Cardonal, Hidalgo, C.P. 42376,
   calle sin nombre y s/n) permita recibir comunicaciones. La politica ya
   esta publicada en una URL accesible sin iniciar sesion.
2. Activar y validar la **eliminación definitiva**. La beta.5 ofrece instrucciones
   de solicitud en la app y en `/account-deletion/`; el backend está preparado y
   probado en emulador, pero no desplegado porque el proyecto sigue en Spark.
   Ver [GESTION_CUENTAS.md](GESTION_CUENTAS.md). Validar la atención manual,
   los plazos de conservación y respuesta antes de declarar esta función operativa
   en Developer Console.
3. Completar el cuestionario de privacidad de Amazon con los datos reales de
   Firebase, Google Sign-In, perfiles, chat, reportes y analitica. Marcar que
   se recogen datos del usuario; no seleccionar "No".
4. Probar el APK en una tablet Fire real. Fire OS no incluye los servicios de
   Google habituales; verificar arranque, autenticacion con correo y Google,
   Firestore, chat y notificaciones. Adaptar o desactivar con claridad las
   funciones dependientes de Google que fallen. Una compilacion Android
   correcta por si sola no demuestra compatibilidad Fire.
5. Preparar la ficha: dos iconos PNG transparentes de 114x114 y 512x512,
   entre 3 y 10 capturas reales de la app con datos ficticios, descripciones,
   categoria, paises, audiencia y clasificacion de contenido. Los iconos
   Android del manifiesto no sustituyen los de la ficha.
6. Confirmar acceso a una cuenta Amazon Developer y crear la ficha; disponer
   de credenciales de prueba para revision sin exponerlas en Git.

## Fuentes oficiales

- https://developer.amazon.com/docs/app-submission/submitting-apps-to-amazon-appstore.html
- https://developer.amazon.com/docs/app-submission/target-app.html
- https://developer.amazon.com/docs/app-submission/appstore-details.html
- https://developer.amazon.com/docs/app-submission/appstore-privacy-labels.html
- https://developer.amazon.com/docs/app-submission/user-account-and-data-deletion.html
- https://developer.amazon.com/docs/fire-tablets/ft-faq.html
