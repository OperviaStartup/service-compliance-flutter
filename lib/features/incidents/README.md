# Incidencias (US07: Reportar Impedimento)

Estado: **UI con datos de muestra. Sin integración con el backend.**

## Qué hay

- `presentation/incidents_page.dart`: punto de entrada en la pestaña Incidencias. Muestra la actividad en curso y el botón "Reportar impedimento o incidencia". Estados de carga, vacío y error (con reintento). Usa `StatefulWidget` + `setState`.
- `presentation/report_impediment_page.dart`: US07 - Reportar Impedimento (motivo, detalle opcional, envío para revisión).
- `presentation/impediment_registered_page.dart`: US07 - Registro Impedimento (confirmación).
- `data/impediment.dart`: modelos de interfaz tomados del diseño. **No son un contrato del backend.**
- `data/incidents_repository.dart`: interfaz `IncidentsRepository` y `SampleIncidentsRepository` (DATOS DE MUESTRA, sin red).
- `presentation/incidents_design.dart`: estilo del Figma (colores aproximados, tarjetas, encabezado, botón y rótulo de datos de muestra). No modifica el tema de la app.
## Por qué no hay integración

El backend (serviceComplianceAPI, revisión a70a67b2) no tiene un controlador de incidencias. No se inventaron rutas ni se simuló una integración real. Mientras se use el repositorio de muestra, las pantallas muestran el rótulo "DATOS DE MUESTRA".

## Pendiente

- La actividad en curso (US05) todavía no existe en la app; por ahora la pestaña Incidencias hace de punto de entrada con una actividad de muestra.
- La bandeja de supervisión que menciona US07 no está implementada ni aparece en el Figma recibido.

## Para conectar el backend

1. Backend define el contrato (ruta, campos, roles) y se confirma con Jean.
2. Se crea una implementación de `IncidentsRepository` que reciba `ApiClient` (`core/network`) y el token por petición.
3. Se pasa a `IncidentsPage(repository: ...)`. Con eso desaparecen el rótulo y el selector de estados demo.
4. Se ajustan los modelos de `data/impediment.dart` a los campos reales.