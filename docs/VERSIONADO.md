# Versionado de UniMatch

El repositorio Git de la aplicacion abarca `unimatch_user`, `unimatch_admin` y
`firebase`. La documentacion academica de `../documentacion` queda fuera de
este repositorio.

## Estado actual

- Version de desarrollo: `0.1.0-dev.1+1` en ambos `pubspec.yaml`.
- Sin tag ni GitHub Release. El sufijo `dev.1` indica que no es una version
  estable ni una beta entregada a testers.
- Los dos proyectos comparten numero de version mientras se desarrollan como
  una sola linea de producto. El numero despues de `+` es el build number y
  debe aumentar cuando se genere una nueva compilacion Android distribuible.

## Flujo de trabajo individual

`main` contiene los cambios integrados que pasaron las comprobaciones locales.
Para cada tarea, crea una rama corta desde `main`:

```powershell
git switch main
git switch -c feat/nombre-corto
```

Prefijos recomendados: `feat/`, `fix/`, `docs/`, `test/` y `chore/`.
Antes de integrar, ejecuta las comprobaciones correspondientes y actualiza
`CHANGELOG.md` si cambia el comportamiento. Usa Conventional Commits:

```text
feat(user): agregar filtro de universidad
fix(admin): corregir estado de reportes
docs: actualizar instrucciones de Firebase
test(user): cubrir validacion de perfil
chore: preparar version de desarrollo
```

Integra la rama despues de revisar el diff y las pruebas:

```powershell
git switch main
git merge --no-ff feat/nombre-corto
```

El remoto `origin` es `https://github.com/David32361/unimach.git`. Usa
`git push -u origin main` para publicar el historial y
`git push -u origin feat/nombre-corto` para subir una rama nueva. Revisa el
estado con `git status` y `git fetch origin` antes de cada integracion.

## Versiones futuras

- Cambios de desarrollo: aumenta `dev.N` y registra el cambio en el changelog.
- Primera ronda beta, cuando se autorice: `0.1.0-beta.1+N` y tag preliminar
  `v0.1.0-beta.1`, solo sobre un commit verificado.
- Una correccion posterior a una beta distribuida usa un nuevo tag y artefacto;
  nunca reemplaza el anterior.
- Reserva `1.0.0` para una version estable aprobada.

## Archivos locales excluidos

`.firebaserc`, `firebase_options.dart`, `google-services.json`, claves de
firma, archivos `.env`, caches y salidas de compilacion no se incluyen en Git.
En un equipo nuevo se deben configurar las dos apps con FlutterFire en el
mismo proyecto Firebase y obtener la configuracion Android correspondiente.
Consulta el README principal para los comandos de ejecucion.
