# Politica de privacidad de UniMatch (borrador para beta)

Actualizada el 29 de octubre de 2026. Esta politica describe la aplicacion
Android UniMatch y su panel administrativo. El responsable del tratamiento es
**David Martinez Polvadera**; contacto privado:
**unimatch7@gmail.com**. Domicilio indicado por el responsable:
**Barrio Moxthe, La Vega, Cardonal, Hidalgo, C.P. 42376, Mexico; calle sin
nombre y sin numero exterior (s/n)**. **Este documento aun requiere revision
legal y un procedimiento operativo de eliminacion definitiva de cuenta y
datos.**

## Datos que trata la aplicacion

- Para crear y usar una cuenta: correo electronico, identificador de Firebase
  Authentication y, si se usa Google, los datos basicos facilitados por ese
  proveedor. UniMatch no almacena la contrasena en Firestore.
- Para el perfil: nombre, edad, genero, universidad, carrera, descripcion,
  avatar elegido, gustos y generos de anime. El nombre y esos campos del
  perfil se muestran a otros usuarios registrados durante el descubrimiento;
  el correo no forma parte del perfil publico.
- Para conectar personas: perfiles que se descartan o a los que se da interes,
  matches, mensajes y estados de lectura. Los mensajes son visibles para las
  personas de la conversacion. Los administradores pueden consultar mensajes
  recientes para moderacion, con una ventana de tres dias.
- Para seguridad: bloqueos, reportes, motivo y descripcion del reporte,
  estado de la cuenta e historial de acciones administrativas.
- Para funcionamiento: fechas de registro y actividad, inicio y duracion
  aproximada de sesiones, identificador del dispositivo para notificaciones
  push y datos tecnicos tratados por los servicios Firebase integrados.

No se solicitan fotografias, ubicacion precisa ni datos de pago. La aplicacion
esta destinada a mayores de 18 anos y comprueba la edad declarada al crear el
perfil; no realiza verificacion documental de edad.

## Para que se usan

Los datos permiten autenticar cuentas, mostrar perfiles, buscar afinidades,
crear matches, ofrecer chat, enviar notificaciones cuando esten habilitadas,
prevenir abusos, resolver reportes y conocer el uso basico de la aplicacion.
Las notificaciones automaticas dependen de la activacion de Cloud Functions;
el registro de un token no significa que ya se esten enviando.

## Servicios y acceso

UniMatch usa Firebase Authentication, Cloud Firestore y Firebase Cloud
Messaging, y el proyecto incluye Firebase Analytics. Google Sign-In se usa
solo cuando el usuario elige ese metodo de acceso. Estos servicios de Google
procesan datos para prestar la funcionalidad correspondiente. Las reglas de
Firestore restringen el acceso a datos privados y a las herramientas de
moderacion segun la cuenta y sus permisos. No se venden datos personales.

## Conservacion y eliminacion

El perfil y el historial asociado permanecen mientras exista la cuenta o hasta
que se complete su eliminación. Puedes solicitarla desde **Perfil → Eliminar mi
cuenta**, desde la pantalla de verificación de correo o siguiendo las instrucciones
en https://unimatch-daniel-2026.web.app/account-deletion/. En esta beta el borrado
automático está pendiente de activar el servicio de servidor. Envía la solicitud
a **unimatch7@gmail.com** desde la dirección asociada a tu cuenta. Abrir la pantalla
o copiar el correo no envía una solicitud ni borra datos.

El procedimiento de servidor preparado elimina Firebase Authentication, perfiles,
dispositivos, sesiones, intereses, matches, bloqueos y reportes asociados. También
elimina las conversaciones compartidas y sus mensajes para ambos participantes.
No se garantiza recuperar datos ya borrados mediante una apelación.

Tras activar el procedimiento, los registros mínimos de la eliminación y las
nuevas acciones administrativas tendrán un vencimiento de 30 días; la limpieza TTL
es asíncrona. Los avisos de una sanción vigente se conservan hasta su resolución.
Los registros históricos de administración previos a esta versión no tienen aún
vencimiento automático. La gestión manual y los plazos de respuesta deben validarse
operativamente antes de la publicación en una tienda.

## Control, derechos y contacto

Desde la aplicacion se puede modificar universidad, carrera, descripcion,
avatar y gustos, y cerrar sesion. El permiso de notificaciones se gestiona en
Android. Para solicitar acceso, rectificacion, cancelacion u oposicion (ARCO),
revocar el consentimiento o limitar el uso de tus datos, escribe a
**unimatch7@gmail.com** desde el correo asociado a tu cuenta, indica
el derecho que deseas ejercer y describe los datos involucrados. El
responsable podra pedir informacion adicional para comprobar tu identidad
antes de responder. No compartas contrasenas. El borrado automático requiere activar el servicio de servidor; una solicitud
no confirma que el borrado haya concluido. **No incluyas datos personales
en los issues publicos de GitHub.**

Domicilio del responsable: Barrio Moxthe, La Vega, Cardonal, Hidalgo,
C.P. 42376, Mexico; calle sin nombre y sin numero exterior (s/n).

Los cambios de esta politica se comunicaran publicando una nueva version en
esta misma URL y actualizando la fecha de revision. Antes de tratar datos con
finalidades nuevas que requieran consentimiento, se solicitara la autorizacion
correspondiente.
