# Contribuir a Opervia Flutter

Trabajamos en ramas temporales desde `develop` y abrimos PR hacia `develop`. Consulta [ramas y revisión](docs/development/branching-strategy.md) y la [Definition of Done](docs/development/definition-of-done.md). Enlaza una historia o incidencia cuando exista; si no existe, explica el contexto en el PR. No incluyas contraseñas, tokens, claves de firma ni datos privados en código, registros, capturas o commits.

## Commits

Usa Conventional Commits: `tipo(alcance): descripción` (el alcance es opcional). Tipos: `feat`, `fix`, `test`, `docs`, `refactor`, `perf`, `build`, `ci`, `chore` y `revert`. Ejemplos:

```text
feat(auth): implement supervisor login
fix(api): handle expired session
test(network): cover unauthorized responses
feat(api)!: change authentication response
```

Describe cambios incompatibles con `!` o con un pie `BREAKING CHANGE: explicación` y coordínalos con los consumidores. El equipo revisa la convención en el PR; no hay un filtro automático de commits.

## Antes de abrir el PR

```sh
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Describe qué validaste y qué no. Nunca marques como integración real o prueba en dispositivo un resultado obtenido con mocks o compilación solamente.
