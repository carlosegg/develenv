TAREAS DE LA FASE DE BUILD
==========================

La ejecución de la fase de build comprende una serie de tareas: **compilación** 
en el caso que sea necesario, **ejecución de test unitarios**, 
**extracción de métricas de calidad del código** y **generación de documentación**.

Compilación
-----------
Esta tarea se realizará en el caso de que sea necesario caso java, c++, ...

Ejecución de test unitarios
---------------------------
Ejecutará los tests unitarios definidos en el módulo/aplicación. Para poder publicar
tanto el resultado de los tests unitarios como la cobertura de los mismos tanto
en jenkins como en sonar es necesario que el resultado se deje en

```
   target/surefire-reports/*.xml     ---> Resultado de los tests 
                                          unitarios en formato xUnit
   target/site/cobertura/coverage.xml --> Informe de cobertura
```

Extracción de métricas de calidad del código
--------------------------------------------
Se hará tanto un análisis dinámico(cobertura de código), como un análisis 
estático (duplicados, y complejidad ciclomática). Por defecto el análisis estático 
se hará utilizando sonar, mientras que el dinámico se reutilizará el resultado de 
los tests y la cobertura para publicarse en sonar

Una vez extraídas las métricas de calidad del código se compararán con ejecuciónes
anteriores y si son peores (empeorán en un 1%) entonces el build fallará.

Generación de documentación
---------------------------
En esta fase de generará la documentación técnica asociada al proyecto. Por
ejemplo si se trata de un proyecto maven, y se ha definido un site y se ha definido
donde desplegarlo entonces se generará toda la documentación técnica del proyecto.

