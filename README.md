# Opervia Service Compliance

Aplicación Flutter para supervisión de obligaciones operativas. Los supervisores pueden iniciar sesión, consultar el estado operativo y revisar ejecuciones enviadas. La demo de incidencias está disponible desde la pantalla de acceso con datos de muestra.

Versión inicial: `0.0.1` (build `1`).

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

Cada equipo puede añadir `data` y lógica propia dentro de su funcionalidad cuando la necesite. Mantener contratos entre módulos pequeños y evitar dependencias cruzadas innecesarias. `ApiClient` admite GET y POST, JSON, descarga de imágenes autenticadas, tiempo de espera y errores básicos. Su propietario debe llamar a `close()`.

## Contratos identificados en el backend

Usa un backend compatible con [serviceComplianceAPI en ddca9f4](https://github.com/OperviaStartup/serviceComplianceAPI/tree/ddca9f4). Para entrar al área de supervisión necesitas una cuenta activa con rol `SUPERVISOR` en ese entorno.

| Método y ruta | Contrato observado |
| --- | --- |
| `POST /api/v1/auth/login` | Correo o documento en `identifier` y `password`. Devuelve los tokens y el rol. |
| `POST /api/v1/auth/logout` | Revoca el token de renovación. La sesión de Flutter vive en memoria. |
| `GET /api/v1/operational-obligations` | Obligaciones y conteos del alcance del supervisor, con filtros y paginación. |
| `GET /api/v1/obligations/{id}/execution` | Obtiene la ejecución vinculada a una obligación. |
| `GET /api/v1/compliance-reviews/executions/{id}` | Consulta una ejecución enviada, su evidencia, excepciones e información faltante. |
| `GET /api/v1/evidence/{id}/content` | Descarga la foto privada con autorización. |

## Trabajo en equipo y pendientes

Consulta la [estrategia de ramas](docs/development/branching-strategy.md), la [guía de contribución](CONTRIBUTING.md) y el [proceso de releases](docs/releases/release-process.md). El proyecto está en desarrollo inicial `0.x.y`; una versión `1.0.0` se reservará para una API pública estable.

GitHub Actions verifica el formato de `lib` y `test`, ejecuta `flutter analyze` y `flutter test` en pushes y PR usando Flutter 3.47.9. La integración con la API y las compilaciones móviles no forman parte de ese flujo todavía.

Quedan pendientes el registro de evaluaciones, las correctivas, el reporte de cumplimiento completo y la gestión administrativa. La pestaña Reportes muestra los conteos operativos de la consulta autorizada. No subir archivos `.env`, credenciales, certificados de firma ni secretos. El `.gitignore` reduce el riesgo, pero revisa cada cambio antes de confirmarlo.

La firma Android de producción aún no está configurada; antes de distribuir una versión release, el equipo debe configurar su propia clave fuera del repositorio.

## Verificación inicial

En la preparación inicial de Windows se ejecutaron `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build web` y `flutter build apk --debug`: todos finalizaron correctamente. El APK se generó en `build/app/outputs/flutter-apk/app-debug.apk`. Las pruebas cubren navegación y el cliente HTTP con mocks, no integración con la API; el APK aún no se ha probado en un dispositivo. `flutter doctor -v` detectó que faltan las Android SDK Command-line Tools y no pudo determinar el estado de las licencias; instálalas desde el SDK Manager de Android Studio y ejecuta `flutter doctor --android-licenses` para revisar y aceptar las que correspondan. Durante la compilación, Gradle utilizó licencias ya aceptadas para instalar los componentes Android necesarios. Chrome no se detectó, pero Edge sí está disponible. Para iOS es necesario verificar la compilación en macOS con Xcode.
