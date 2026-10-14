# UniMatch User

Aplicacion Flutter Android de UniMatch. Los usuarios normales acceden a los
flujos de perfil, intereses, descubrimiento, matches y mensajes.

## Acceso administrativo

El mismo formulario de inicio de sesion detecta el custom claim de Firebase
Authentication. Si el token contiene `admin: true`, GoRouter dirige la sesion
a `/admin` antes de evaluar el perfil de usuario.

La autorizacion real se mantiene en las reglas de Firestore; no se decide por
un correo codificado en la aplicacion. El modulo visual se comparte mediante
la dependencia local `../unimatch_admin`, por lo que ambos proyectos deben
conservarse dentro de la misma carpeta raiz.

Despues de asignar o retirar el claim, la cuenta debe cerrar sesion y volver a
entrar para renovar el token.
