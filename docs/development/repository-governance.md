# Gobernanza de GitHub: diagnóstico y propuesta

Auditoría del 4 de noviembre de 2026: `main` y `develop` apuntaban a `745c97d`; el tag anotado `v0.0.1` apuntaba a ese commit. GitHub mostraba ambas ramas sin protección y ningún ruleset a nivel del repositorio. La consulta a la API con `includes_parents=true` no devolvió rulesets; la visibilidad de reglas de organización depende de los permisos de la conexión y no se considera una auditoría completa de la organización. La pantalla de acceso muestra un rol base `Write` para seis miembros; el listado de la organización incluye dos propietarios, `@ZaydAyasta` y `@Jean-AT`. Esto identifica una posible persona revisora distinta del autor, pero no confirma su disponibilidad ni su aprobación para asumir responsabilidades. No se registraron asignaciones por módulo. Revalidar todo antes de configurar reglas.

El job exitoso de GitHub Actions observado es `validate`, del workflow `Flutter CI`: [ejecución verificada](https://github.com/OperviaStartup/service-compliance-flutter/actions/runs/41775141401). El formulario de rulesets ofrece el check `validate` con origen GitHub Actions. La CI del [PR #3](https://github.com/OperviaStartup/service-compliance-flutter/pull/3) pasó para el commit `87d38dd`; verificar los resultados del commit más reciente del PR antes de fusionarlo.

## Protección actual

Las reglas [protect-main](https://github.com/OperviaStartup/service-compliance-flutter/settings/rules/26550801) y [protect-develop](https://github.com/OperviaStartup/service-compliance-flutter/settings/rules/26551707) están activas desde el 4 de noviembre de 2026. Ambas exigen PR, una aprobación de alguien distinto del autor y el check `validate` de GitHub Actions; también bloquean force push y eliminación. `main` exige resolver las conversaciones de revisión. No se configuraron excepciones. La aprobación puede proceder de cualquier integrante habilitado; no se requieren dos aprobadores concretos. GitHub no permite al autor aprobar su propio PR.

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
