# Opervia Service Compliance

Base de una aplicación Flutter para supervisión de obligaciones operativas. Las secciones de autenticación, obligaciones, cumplimiento e incidencias son espacios iniciales: todavía no autentican ni consultan datos reales.

## Requisitos y ejecución

- Flutter estable 3.47.9 y Dart 3.13.7 (versiones usadas en esta preparación). Consultar la [instalación oficial](https://docs.flutter.dev/install/manual).
- Para Android: Android SDK, herramientas de línea de comandos, licencias aceptadas y un emulador o dispositivo. Para iOS se requiere macOS con Xcode. Para Windows, Visual Studio con herramientas de desarrollo de escritorio C++.

```sh
flutter doctor -v
flutter pub get
flutter devices
flutter run -d edge
flutter analyze
flutter test
```

El SDK se instaló en `C:\src\flutter`; abre una terminal nueva para usar el PATH actualizado. Cambia `edge` por el dispositivo elegido. Para configurar el cliente HTTP, pasa la URL de la API en compilación:

```sh
flutter run -d edge --dart-define=API_BASE_URL=http://localhost:8080
```

En el emulador Android estándar, usa `http://10.0.2.2:8080` para acceder al servidor del equipo anfitrión. Los dispositivos físicos necesitan una dirección accesible en la red. El tráfico HTTP sin cifrar puede requerir configuración específica de desarrollo en Android/iOS; usa HTTPS para entornos reales. En web, la API debe permitir el origen de la aplicación mediante CORS. La URL no es un secreto y `--dart-define` queda incorporado al binario: no lo uses para claves o contraseñas. No hay URL predeterminada; el cliente devuelve un error si falta o es inválida.

## Organización

```text
lib/
  app/                  aplicación, tema y navegación
  core/network/         cliente HTTP compartido
  core/widgets/         estados y componentes comunes
  features/
    authentication/presentation/
    obligations/presentation/
    compliance/presentation/
    incidents/presentation/
```

Cada equipo puede añadir `data` y lógica propia dentro de su funcionalidad cuando la necesite. Mantener contratos entre módulos pequeños y evitar dependencias cruzadas innecesarias. `ApiClient` admite GET y POST, JSON, token Bearer opcional por petición, tiempo de espera y errores básicos; su propietario debe llamar a `close()`. Los widgets de carga y error están disponibles para las pantallas que integren datos; aún no hay consultas activas.

## Contratos identificados en el backend

Fuente: [serviceComplianceAPI, revisión a70a67b2](https://github.com/OperviaStartup/serviceComplianceAPI/tree/a70a67b2feb955bc586632be0d1d3966e36891cf). Verificar Swagger (`/swagger-ui.html`) y el código actualizado antes de implementar.

| Método y ruta | Contrato observado |
| --- | --- |
| `POST /api/v1/auth/register` | `fullName`, `email`, `password`; devuelve `token`, `userId`, `fullName`, `email`, `role`. Registra `OPERATOR`. |
| `POST /api/v1/auth/login` | `email`, `password`; devuelve la misma respuesta de autenticación. |
| `GET /api/v1/auth/me` | Requiere Bearer; devuelve `id`, `fullName`, `email`, `role`. |
| `GET /api/v1/obligations` | Requiere autenticación; devuelve obligaciones asignadas al usuario actual. |
| `POST /api/v1/obligations` | Requiere `SUPERVISOR`; recibe `title`, `description`, `siteName`, `assignedOperatorId`, `dueAt` (instante). |

Una obligación expone `id`, `title`, `description`, `siteName`, `assignedOperatorId`, `status` y `dueAt`. También hay rutas de ejecuciones y evidencias en el backend. En la revisión consultada no existe un controlador de incidencias; acordar ese contrato antes de implementarlo. La consulta actual de obligaciones no es un listado global de supervisor: confirmar con el equipo del backend si AV2 necesita uno. No se han implementado estos flujos ni persistencia de tokens.

## Trabajo en equipo y pendientes

Usar ramas `feature/...` desde la rama de integración que acuerde el equipo, con revisiones y merges según Git Flow. El equipo debe acordar la creación y el uso de `develop` como rama de integración.

Para AV2: acordar alcance y contratos de supervisión e incidencias; implementar autenticación y almacenamiento seguro de sesión, autorización, módulos y manejo de errores reales; validar conectividad y CORS, pruebas de integración y UX en dispositivos. No subir archivos `.env`, credenciales, certificados de firma ni secretos. El `.gitignore` reduce el riesgo, pero revisa cada cambio antes de confirmarlo.

La firma Android de producción aún no está configurada; antes de distribuir una versión release, el equipo debe configurar su propia clave fuera del repositorio.

## Verificación inicial

En Windows se ejecutaron `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build web` y `flutter build apk --debug`: todos finalizaron correctamente. El APK está en `build/app/outputs/flutter-apk/app-debug.apk`. La prueba comprueba navegación entre secciones, no integración con la API; el APK aún no se ha probado en un dispositivo. `flutter doctor -v` detectó que faltan las Android SDK Command-line Tools y no pudo determinar el estado de las licencias; instálalas desde el SDK Manager de Android Studio y ejecuta `flutter doctor --android-licenses` para revisar y aceptar las que correspondan. Durante la compilación, Gradle utilizó licencias ya aceptadas para instalar los componentes Android necesarios. Chrome no se detectó, pero Edge sí está disponible. Para iOS es necesario verificar la compilación en macOS con Xcode.
