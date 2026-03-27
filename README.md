# Daily News App

Aplicacion de noticias construida con Flutter y Firebase.

El proyecto combina dos tipos de contenido en una misma experiencia:

- articulos propios publicados desde la app y guardados en Firebase
- titulares externos obtenidos desde `NewsAPI`

El resultado actual es un MVP funcional orientado a Android con flujo completo de lectura, detalle, guardado local, creacion, edicion y archivado de articulos.

## Que hace la aplicacion

Las funcionalidades activas a dia de hoy son:

- feed principal con articulos publicados en Firestore
- integracion de titulares externos desde `NewsAPI`
- detalle de articulo para contenido propio y externo
- guardado local de articulos en `Saved Articles`
- creacion de articulos con miniatura
- subida de miniaturas a Firebase Storage
- edicion de articulos propios ya publicados
- archivado de articulos propios
- borradores persistidos localmente mientras se edita

## Estado actual del proyecto

Este repositorio ya no es solo una plantilla o una consigna de prueba. La aplicacion esta aterrizada sobre una arquitectura real con:

- frontend Flutter en `frontend/`
- backend Firebase en `backend/`
- documentacion y reporte en `docs/`

Soporte actual:

- plataforma objetivo: Android
- backend real: Firebase Auth, Firestore y Storage
- persistencia local: Floor/SQLite
- gestion de estado: `flutter_bloc`

Limitaciones actuales importantes:

- no hay una UI de login dedicada; el flujo actual depende de Firebase Auth y del acceso anonimo cuando esta habilitado
- el frontend no esta cableado todavia para usar `Firebase Emulator Suite` con `useEmulator(...)`
- el soporte Firebase real esta preparado para Android, no para web/iOS/desktop
- si no se proporciona `NEWS_API_KEY`, la app sigue funcionando pero sin titulares externos de `NewsAPI`
- la build publica no activa autenticacion anonima por defecto

## Tecnologias principales

- Flutter
- Dart
- `flutter_bloc`
- `get_it`
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Floor / SQLite
- `image_picker`
- `dio` + `retrofit`

## Estructura del repositorio

```text
starter-project/
|- frontend/   -> app Flutter Android
|- backend/    -> reglas, indices y esquema Firebase
|- docs/       -> reporte y documentacion adicional
`- README.md   -> guia general del proyecto
```

## Requisitos

Para ejecutar y probar la app con normalidad necesitas:

- Flutter `>=3.38.0`
- Dart `>=3.10.0`
- JDK 17
- Android SDK
- Android NDK `27.0.12077973`

Si la NDK no esta instalada:

```powershell
sdkmanager "ndk;27.0.12077973"
```

## Instalacion rapida

### 1. Clonar el repositorio

```powershell
git clone <repo-url>
cd starter-project
```

### 2. Preparar el frontend

```powershell
cd frontend
flutter pub get
flutter doctor -v
```

### 3. Revisar Firebase

El repositorio ya incluye configuracion Android de Firebase para el proyecto actual.

Si quieres usar tu propio proyecto Firebase:

1. crea o selecciona un proyecto en Firebase
2. anade una app Android con package `com.example.news_app_clean_architecture`
3. reemplaza `frontend/android/app/google-services.json`
4. regenera `frontend/lib/firebase_options.dart`
5. despliega las reglas e indices desde `backend/`

Ejemplo con FlutterFire CLI:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Firebase esperado por la app:

- Authentication
- Cloud Firestore
- Cloud Storage

Para que publicar articulos funcione sin implementar una pantalla de login, activa `Anonymous` en Firebase Authentication.

Si ademas quieres que esta app intente abrir sesion anonima automaticamente, ejecutala con:

```powershell
flutter run --dart-define=ENABLE_ANONYMOUS_AUTH=true
```

Para probar a la vez `NewsAPI` y el flujo anonimo:

```powershell
flutter run --dart-define=NEWS_API_KEY=<tu-clave> --dart-define=ENABLE_ANONYMOUS_AUTH=true
```

### 3.1 Configurar NewsAPI

La clave de `NewsAPI` ya no se guarda en el repositorio.

Para ejecutar la app con titulares externos, pasa la clave por `dart-define`:

```powershell
flutter run --dart-define=NEWS_API_KEY=<tu-clave>
```

Si no defines `NEWS_API_KEY`, la app seguira arrancando, pero el feed solo mostrara articulos de Firestore.

### 4. Ejecutar la app

Desde `frontend/`:

```powershell
flutter run
```

Con `NewsAPI` habilitado:

```powershell
flutter run --dart-define=NEWS_API_KEY=<tu-clave>
```

Si quieres elegir un dispositivo o emulador:

```powershell
flutter devices
flutter run -d <device-id>
```

Si necesitas arrancar primero un emulador:

```powershell
flutter emulators
flutter emulators --launch <emulator-id>
flutter run -d <device-id>
```

## Como funciona el backend

La carpeta `backend/` contiene el contrato remoto de la app:

- esquema de articulos en Firestore
- reglas de Firestore
- reglas de Storage
- indices compuestos
- configuracion de emuladores

Si vas a usar un proyecto Firebase propio, desde `backend/` puedes desplegar lo necesario con:

```powershell
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Para levantar la suite de emuladores:

```powershell
firebase emulators:start
```

Importante: el frontend todavia no apunta automaticamente a esos emuladores, asi que esto sirve para validacion backend y futuras mejoras, pero no como flujo end-to-end cerrado desde la app.

## Recomendacion si el repo es publico

Para dejar este repo en publico sin exponer un backend escribible por cualquiera, la estrategia recomendada es:

1. no guardar claves reales de `NewsAPI` en el codigo
2. no depender de `Anonymous Auth` en tu proyecto Firebase compartido/publico
3. dejar el proyecto Firebase publico solo para lectura del feed actual, o pedir a cada revisor que configure su propio Firebase si quiere probar el flujo completo de publicacion

Punto importante:

- `google-services.json` y `firebase_options.dart` no son equivalentes a una clave secreta de servidor
- el riesgo real en este proyecto viene de permitir escrituras con autenticacion anonima sobre un Firebase compartido

En otras palabras:

- repo publico + Firebase compartido + `Anonymous Auth` activado = mala idea
- repo publico + app compilada sin `ENABLE_ANONYMOUS_AUTH` + Firebase compartido = mucho mas razonable para demo de lectura
- repo publico + Firebase propio por revisor = opcion mas segura para probar publicacion

## Como probar la aplicacion

### Verificacion automatica

Desde `frontend/`:

```powershell
flutter analyze
flutter test test/features/daily_news
flutter test
```

### Smoke test manual recomendado

1. Abre la app en Android.
2. Comprueba que el feed carga articulos publicados y anade noticias de `NewsAPI`.
3. Abre un articulo propio y verifica el detalle.
4. Abre una noticia externa y verifica el detalle.
5. Guarda un articulo y confirma que aparece en `Saved Articles`.
6. Crea un articulo nuevo con miniatura.
7. Comprueba que aparece en el feed y en `My Articles`.
8. Edita ese articulo y revisa que los cambios se reflejan.
9. Archivarlo y confirmar que desaparece del feed publico pero sigue visible en el area del autor.
10. Si `Anonymous Auth` no esta habilitado, confirmar que publicar falla con un mensaje claro y no con un crash.

## Documentacion util

- [Frontend README](./frontend/README.md)
- [Backend README](./backend/README.md)
- [Reporte de desarrollo](./docs/REPORT.md)
- [Arquitectura de la app](./docs/APP_ARCHITECTURE.md)
- [Esquema de Firestore](./backend/docs/DB_SCHEMA.md)
- [Futuras mejoras](./docs/FUTURE.md)

## Resumen rapido para alguien nuevo

Si solo quieres entender el repo y probarlo:

1. lee este `README.md`
2. entra en `frontend/`
3. ejecuta `flutter pub get`
4. revisa que tienes Android y JDK 17 correctos
5. ejecuta `flutter run`
6. si usas tu propio Firebase, sigue despues `frontend/README.md` y `backend/README.md`

Con eso deberias tener contexto suficiente para entender la aplicacion y empezar a probar el flujo principal.
