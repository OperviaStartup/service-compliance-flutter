# Definition of Done

Una tarea se considera terminada para el alcance acordado cuando:

- Cumple criterios de aceptación y respeta la arquitectura del módulo.
- Incluye pruebas adecuadas, análisis estático y CI aprobados.
- No introduce secretos y actualiza documentación cuando corresponde.
- Tiene evidencia verificable y revisión según las reglas vigentes.
- Documenta riesgos, limitaciones y dependencias de backend.

## Estados de evidencia

Estos estados son distintos y no se implican entre sí:

| Estado | Evidencia mínima |
| --- | --- |
| Implementado localmente | Cambios y verificaciones en el equipo de desarrollo. |
| Publicado en rama | Commit disponible en una rama remota. |
| Integrado en develop | PR fusionado en `develop`. |
| Publicado en main | Commit de release integrado en `main`. |
| Desplegado | Versión instalada en un entorno identificado. |
| Probado en dispositivo | Resultado registrado en dispositivo o emulador identificado. |
| Validado con backend real | Flujo probado contra una revisión y entorno de API identificados. |

Un APK compilado no demuestra que se haya ejecutado; una prueba con mocks no demuestra compatibilidad real con la API.
