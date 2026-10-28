# Flujo individual en GitHub

Cada cambio sigue: actualizar `main` → crear rama → desarrollar y probar →
subir rama → abrir y revisar PR → integrar → publicar versión cuando corresponda.
No se alteran fechas de commits ni se atribuyen revisiones a otras personas.

## Ramas por responsabilidad

| Rama | Responsabilidad | Evidencia |
| --- | --- | --- |
| `main` | Cambios integrados y comprobados | Historial de merges y CI |
| `feature/seguridad-correo` | Contraseñas fuertes, verificación y reglas de acceso | [PR #5](https://github.com/David32361/unimach/pull/5) |
| `fix/interacciones-match` | Likes, estado visible y creación atómica de match/conversación | [PR #6](https://github.com/David32361/unimach/pull/6) |
| `fix/diseno-ortografia` | Textos, tildes y nombres de universidades | [PR #7](https://github.com/David32361/unimach/pull/7) |
| `fix/lectura-conversacion` | Lectura inicial de conversación propia en la transacción | [PR #9](https://github.com/David32361/unimach/pull/9) |
| `chore/flujo-trabajo` | CI, trazabilidad, plantillas y preparación de versiones | [PR #8](https://github.com/David32361/unimach/pull/8) |

Las ramas se conservan en GitHub como evidencia de esta entrega. Las tareas
nuevas deben partir de `main` actualizado; no reutilizar una rama ya integrada
sin actualizarla primero. Se prefieren ramas cortas y PRs con un propósito.

## Pasos reproducibles

```powershell
git switch main
git pull --ff-only origin main
git switch -c feature/nombre-del-cambio
# Desarrollar; revisar git diff y crear commits pequeños.
git add ruta/de/los/archivos
git commit -m "feat(area): describir comportamiento"
git push -u origin feature/nombre-del-cambio
# Abrir PR contra main, revisar diff y comprobar CI.
```

Después de validar el PR, integrar en GitHub o localmente. En esta entrega
se conserva un merge explícito:

```powershell
git switch main
git pull --ff-only origin main
git merge --no-ff feature/nombre-del-cambio
git push origin main
```

## Comprobaciones

- Usuario: `flutter analyze` y `flutter test` desde `unimatch_user`.
- Panel: `flutter analyze` y `flutter test` desde `unimatch_admin`.
- Funciones: `npm ci` y `npm run build` desde `firebase/functions`.
- Reglas, desde la raíz: `firebase emulators:exec --only firestore --project demo-unimatch "npm --prefix firebase/functions run test:rules"`.
- APK: `flutter build apk --release` desde `unimatch_user`, con la firma local
  persistente; nunca subir el keystore ni sus contraseñas.

GitHub Actions ejecuta las comprobaciones en cada PR y en las ramas de trabajo.
La configuración Firebase de CI es ficticia y solo sirve para compilar y
ejecutar pruebas con dobles y emuladores. CI no despliega producción.

## Versión y entrega

Incrementar ambos `pubspec.yaml`, actualizar `CHANGELOG.md`, compilar y verificar
la firma/hash del APK. Crear un tag anotado y una Release preliminar para una
beta; reservar las Releases estables para una versión aprobada. El repositorio
`app_unimach` distribuye el APK y los reportes, mientras `unimach` mantiene el código.
