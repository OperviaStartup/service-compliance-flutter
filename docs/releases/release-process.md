# Proceso de releases

Cada componente (Flutter, API, Kotlin y landing) mantiene su propia versión y su propio repositorio. El estado actual de Flutter es `0.0.1+1`: `0.0.1` es la versión del producto, `1` el número de compilación de Flutter y `v0.0.1` un tag Git. Un tag no es por sí solo una GitHub Release ni un despliegue. `/api/v1` es un prefijo de contrato HTTP, no una versión SemVer del backend. Una línea base de integración identifica versiones y revisiones compatibles de varios componentes; véase el [ejemplo](integration-baseline.example.yaml).

## Elegir versión

SemVer usa `MAJOR.MINOR.PATCH`. En `0.y.z` el producto está en desarrollo inicial y su API pública puede cambiar: el equipo acuerda y anuncia de antemano cambios incompatibles, normalmente incrementando `MINOR`; una corrección compatible incrementa `PATCH`. Para nuevas funcionalidades compatibles en esta etapa se puede incrementar `MINOR` según el alcance acordado. Una vez establecida una API pública estable en `1.0.0`, incrementa `MAJOR` para cambios incompatibles, `MINOR` para funcionalidades compatibles y `PATCH` para correcciones compatibles. No declares estabilidad solo por generar un tag.

El número `+build` identifica compilaciones y no forma parte de la precedencia SemVer. Para cada binario distribuido, incrementa el build number respecto del último publicado en la plataforma correspondiente; verifica las reglas de distribución de Android e iOS antes de publicar. Nunca reutilices una versión o tag publicado para contenido diferente.

## Preparar una release

1. Acuerda alcance, compatibilidad y versión a partir del estado integrado en `develop`; registra historias y dependencias.
2. Crea `release/X.Y.Z` desde `develop`; actualiza `pubspec.yaml`, build number cuando corresponda, documentación y notas. No se realiza este cambio solo para ensayar el proceso.
3. Ejecuta formato, análisis, pruebas y CI; compila y prueba en los dispositivos y entornos que exija la entrega. Registra qué backend y revisión usaste, o indica que no hubo integración real.
4. Abre un PR a `main`; espera CI verde y resuelve las conversaciones de revisión. Una aprobación humana no es obligatoria, aunque se recomienda una revisión independiente cuando sea posible. Fusiona solo con autorización y conforme a las reglas vigentes.
5. Confirma el SHA final en `main`; crea el tag anotado `vX.Y.Z` apuntando a ese commit. Crea una GitHub Release con ese tag solo cuando esté autorizada. Describe cambios, pruebas, compatibilidad y limitaciones; enlaza PR y tareas. Publicar una release no equivale a desplegar.
6. Integra los ajustes de la release en `develop` mediante PR o avance rápido cuando la política vigente lo permita. Comprueba ambas ramas y el tag; elimina la rama temporal solo después de la integración y con la autorización correspondiente.

## Hotfix

Crea `hotfix/<modulo>-<descripcion>` desde `main`. Prepara el ajuste y la versión apropiada, valida y abre PR a `main`. Tras cumplir las reglas e integrarlo, etiqueta el commit correcto y lleva la corrección a `develop`; elimina la rama solo después de completar ambas integraciones y contar con autorización. No muevas ni borres tags existentes.

## Plantilla de notas

```text
Versión y tag:
Historias y PR:
Cambios y correcciones:
Cambios incompatibles y migración:
Versiones compatibles / línea base:
Pruebas, dispositivo y backend:
Limitaciones y riesgos conocidos:
```
