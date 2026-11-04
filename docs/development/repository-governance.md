# Gobernanza de GitHub: diagnóstico y propuesta

Auditoría del 4 de noviembre de 2026: `main` y `develop` apuntaban a `745c97d`; el tag anotado `v0.0.1` apuntaba a ese commit. GitHub mostraba ambas ramas sin protección y ningún ruleset a nivel del repositorio. La consulta a la API con `includes_parents=true` no devolvió rulesets; la visibilidad de reglas de organización depende de los permisos de la conexión y no se considera una auditoría completa de la organización. La consulta de colaboradores y permisos de revisión solicitó una verificación adicional de GitHub, por lo que no se confirmó un segundo revisor ni la pertenencia a equipos. Revalidar todo antes de configurar reglas.

El job exitoso de GitHub Actions observado es `validate`, del workflow `Flutter CI`: [ejecución verificada](https://github.com/OperviaStartup/service-compliance-flutter/actions/runs/41775141401). Antes de requerirlo, confirma en GitHub el nombre exacto ofrecido por la interfaz y que se ejecuta en ambas ramas y en PR. Un nombre de paso no equivale necesariamente al nombre del check.

## Propuesta pendiente de aprobación

Para `main`: PR obligatorio, al menos una aprobación de otra persona, check `validate` exitoso, conversaciones resueltas, impedir force push y eliminación. Para `develop`: PR y `validate` obligatorios, una revisión si existe otro revisor disponible, impedir force push y eliminación. No se han activado estas reglas como parte de esta propuesta.

Antes de aplicarlas, comprobar plan, reglas heredadas, permisos administrativos y al menos una persona distinta del autor con acceso suficiente para revisar e integrar. Confirmar la disponibilidad del equipo para no bloquear AV2. Comunicar el impacto y obtener autorización explícita. Si alguna opción no está disponible, documentar el motivo exacto y usar revisión y CI manuales mientras tanto; no cambiar permisos ni visibilidad como solución automática.

## CODEOWNERS propuesto, sin activar

| Área | Rutas orientativas | Responsable |
| --- | --- | --- |
| Infraestructura | `lib/core/`, `lib/app/` | Pendiente de verificar. |
| Autenticación | `lib/features/authentication/` | Pendiente de verificar. |
| Obligaciones | `lib/features/obligations/` | Pendiente de verificar. |
| Incidencias | `lib/features/incidents/` | Pendiente de verificar. |
| CI y configuración | `.github/`, `pubspec.yaml` | Pendiente de verificar. |
| Documentación | `docs/`, `README.md` | Pendiente de verificar. |

No se publica CODEOWNERS hasta verificar cuentas o equipos, acceso de escritura y disponibilidad. Asignar varios responsables cuando sea posible y acordar si exigir su aprobación: un propietario único puede bloquear al equipo. Esta tabla no asigna permisos ni revisores.
