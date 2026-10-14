# UniMatch Admin

Aplicacion Flutter Web independiente para administrar UniMatch. Tiene su propio
`pubspec.yaml`, punto de entrada en `lib/main.dart` y compilacion web. La app
Android de estudiantes esta en el proyecto hermano `unimatch_user`.

## Ejecutar

Desde esta carpeta:

```powershell
flutter pub get
flutter run -d chrome
```

Para comprobar o generar la version web:

```powershell
flutter analyze
flutter test
flutter build web
```

## Firebase

Las dos aplicaciones usaran el mismo proyecto Firebase, con registros de app
distintos. Para conectar este panel, ejecuta FlutterFire desde esta carpeta:

```powershell
flutterfire configure --project=your-firebase-project-id --platforms=web
```

Despues, configura `lib/services/firebase_bootstrap.dart` para inicializar
Firebase con `DefaultFirebaseOptions.currentPlatform`. Actualmente la pantalla
de inicio indica si Firebase sigue pendiente de configurar.

El acceso administrativo se protegera con Firebase Authentication y el Custom
Claim `admin: true`. Las reglas compartidas estan en `../firebase/`.
