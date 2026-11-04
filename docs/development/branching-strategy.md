# Estrategia de ramas

`main` contiene releases aprobadas; `develop` integra el trabajo del equipo. Crea ramas desde `develop` con `<tipo>/<modulo>-<descripcion>`, sin nombres de personas: `feature/supervisor-authentication`, `fix/session-expiration`, `test/authentication-flow`, `docs/release-process` o `chore/flutter-ci`. Los PR normales apuntan a `develop`.

Prepara `release/X.Y.Z` desde `develop`, abre un PR revisado a `main` e incorpora a `develop` los ajustes de la release. Para una corrección crítica usa `hotfix/<modulo>-<descripcion>` desde `main`, integra mediante PR a `main` y después a `develop`. Véase [proceso de release](../releases/release-process.md).

Tras confirmar la integración, elimina únicamente la rama temporal correspondiente. Conserva `main`, `develop` y los tags. No reescribas historia compartida ni fuerces pushes. No cambies ramas existentes para adaptarlas retroactivamente a esta convención.

La revisión deseada incluye CI verde y al menos una aprobación de otra persona; hasta que se acuerden y activen protecciones, es una práctica del equipo, no una garantía automática. No fusiones tu propio PR sin seguir la política y aprobaciones acordadas.
