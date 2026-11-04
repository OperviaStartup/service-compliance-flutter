# Compatibilidad de API

Este inventario se basa en el [backend, commit a70a67b](https://github.com/OperviaStartup/serviceComplianceAPI/tree/a70a67b2feb955bc586632be0d1d3966e36891cf), y debe actualizarse al cambiarlo. La configuración publica OpenAPI en `/api-docs` y Swagger en `/swagger-ui.html` cuando el backend está ejecutándose; no se ha verificado una instancia activa en esta auditoría. El prefijo `/api/v1` no identifica por sí solo la versión de release ni garantiza compatibilidad SemVer.

## Contratos observados

- `POST /api/v1/auth/register`: `fullName`, `email`, `password`; crea `OPERATOR`. `POST /api/v1/auth/login`: `email`, `password`. Ambas respuestas incluyen `token`, `userId`, `fullName`, `email` y `role`. `GET /api/v1/auth/me` devuelve el perfil autenticado.
- `GET /api/v1/obligations` consulta obligaciones asignadas al usuario autenticado; no es una consulta global de supervisión. `POST /api/v1/obligations` requiere `SUPERVISOR` y recibe `title`, `description`, `siteName`, `assignedOperatorId`, `dueAt`.
- Hay rutas de ejecuciones y evidencias bajo `/api/v1/executions`. No se identificó un controlador de incidencias en esta revisión.
- Los errores manejados pueden usar `code`, `message` y `timestamp`; confirmar la respuesta de cada ruta, incluidos errores de seguridad, antes de depender de una forma única.

Flutter dispone de transporte HTTP configurable, pero sus pantallas aún no implementan autenticación ni consumen estas rutas. El cliente acepta tokens Bearer por petición; no persiste sesiones. No documentar integración real hasta probar un flujo completo contra un entorno identificado.

## Coordinación de cambios

Antes de cambiar rutas, obligatoriedad o tipos de campos, valores de enumeración, roles, errores o semántica, abre una historia vinculada y revisa consumidores Flutter y Kotlin. Una adición opcional puede ser compatible si ambos clientes la toleran; no se debe asumir compatibilidad sin verificar serialización y comportamiento reales. Para cada cambio, compara OpenAPI y DTO en el SHA anterior y nuevo, ejecuta pruebas de contrato y registra entorno, revisiones, resultados, responsables y limitaciones en la línea base de integración.

Comprueba en Kotlin sus clientes y modelos reales y prueba los flujos afectados contra la misma revisión de backend; este documento no afirma que esa integración haya sido validada. Registra incompatibilidades en una incidencia con ruta, versiones/SHA, ejemplo sin datos sensibles, comportamiento esperado y observado, impacto y plan de migración.

Historias técnicas propuestas: acordar consulta de supervisión global y sus permisos si AV2 la necesita; acordar el contrato de incidencias si entra en alcance; automatizar en el futuro comparación de OpenAPI y pruebas de contrato para ambos clientes. Son propuestas, no endpoints existentes.
