# UniMatch 1.0.0 — cierre de la entrega

Fecha: 29 de octubre de 2026. Versión de las aplicaciones: **1.0.0+9**.

El usuario solicita cerrar el proyecto con un tag y una Release estable. Esta
entrega consolida las funciones disponibles; no declara activados los servicios
que siguen pendientes. Los repositorios y las betas se conservan.

## Qué significa cada elemento

- **Tag `v1.0.0`**: referencia fija y anotada al commit de esta entrega. Permite
  encontrar y descargar exactamente ese código.
- **Release 1.0.0**: publicación de GitHub asociada al tag, con notas y archivos.
  Se publica sin la marca de versión preliminar y como la entrega más reciente.
- **APK 1.0.0, código 9**: instalador Android nuevo, con la misma firma de las
  betas anteriores para permitir la actualización.

## Alcance disponible

Registro e inicio de sesión, recuperación y confirmación de correo por Firebase,
contraseñas fuertes para registros nuevos, perfiles e intereses, descubrimiento,
matches y conversaciones, bloqueo y reportes, panel administrativo, logo propio,
avisos privados con motivo de sanción e instrucciones para apelar.

Contacto: **unimatch7@gmail.com**. Perfil → Eliminar mi cuenta ofrece el
procedimiento de solicitud manual. También está publicado en
https://unimatch-daniel-2026.web.app/account-deletion/.

## Pendientes que se conservan

- La eliminación automática de cuentas propias y desde administración está
  implementada y probada en emulador, pero permanece **desactivada**.
  `ACCOUNT_MANAGEMENT_ENABLED=false`: falta habilitar y validar Cloud Functions
  en un proyecto con Blaze. No se activó facturación.
- Los avisos personalizados de baneo o eliminación por correo no están activos.
  El remitente nativo de verificación de Firebase no ofrece correo arbitrario;
  se necesita otro servicio de envío para esa función.
- No se declara aprobación ni publicación en Amazon Appstore. La revisión legal,
  los requisitos de tienda y las pruebas en dispositivos Fire siguen separados.

Véanse [gestión de cuentas](GESTION_CUENTAS.md) y
[revisión de Amazon Appstore](AMAZON_APPSTORE.md).

## Dónde abrirlo en GitHub

- [Código y tag](https://github.com/David32361/unimach/tree/v1.0.0).
- [Release del código](https://github.com/David32361/unimach/releases/tag/v1.0.0).
- [Release e instalador](https://github.com/David32361/app_unimach/releases/tag/v1.0.0).

En cada repositorio abre **Releases → UniMatch 1.0.0**. Para el instalador, entra
al repositorio `app_unimach`, abre **Assets** y elige el APK para tu arquitectura: `UniMatch-1.0.0-arm64-v8a.apk`,
`UniMatch-1.0.0-armeabi-v7a.apk` o `UniMatch-1.0.0-x86_64.apk`.
Para el tag, abre el selector de ramas de la pestaña **Code**, cambia a **Tags**
y selecciona `v1.0.0`. El tag también se ve en el encabezado de la Release.

## Validación

La entrega parte del código integrado con análisis y pruebas de Flutter, pruebas
de reglas y backend en emulador y CI aprobados. El cierre se valida de nuevo en
el PR de versión. Antes de publicar el APK se comprueban versión, firma y SHA-256;
el hash final se registra en las notas del repositorio de distribución.

Los instaladores por arquitectura son más pequeños y evitan el corte de conexión
al subir el APK universal. Todos llevan versión 1.0.0, código 9 y la misma firma.
ARM64 corresponde a Android ARM de 64 bits; armeabi-v7a a ARM de 32 bits;
x86_64 a Android para esa arquitectura, como algunos emuladores.
