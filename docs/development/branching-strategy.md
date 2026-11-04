# Estrategia de ramas

`main` contiene releases aprobadas; `develop` integra el trabajo del equipo. Crea ramas desde `develop` con `<tipo>/<modulo>-<descripcion>`, sin nombres de personas: `feature/supervisor-authentication`, `fix/session-expiration`, `test/authentication-flow`, `docs/release-process` o `chore/flutter-ci`. Los PR normales apuntan a `develop`.

Prepara `release/X.Y.Z` desde `develop`, abre un PR a `main` e incorpora a `develop` los ajustes de la release. Para una corrección crítica usa `hotfix/<modulo>-<descripcion>` desde `main`, integra mediante PR a `main` y después a `develop`. Véase [proceso de release](../releases/release-process.md).

Tras confirmar la integración, elimina únicamente la rama temporal correspondiente. Conserva `main`, `develop` y los tags. No reescribas historia compartida ni fuerces pushes. No cambies ramas existentes para adaptarlas retroactivamente a esta convención.

Los PR a `main` y `develop` requieren el check `validate` aprobado, pero no requieren aprobaciones humanas. El autor con permisos suficientes puede integrar su propio PR; en `main` también deben resolverse las conversaciones de revisión. Se recomienda pedir revisión a otra persona cuando esté disponible, especialmente en cambios de riesgo.
