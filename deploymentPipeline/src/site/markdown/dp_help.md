Ayuda
=====

* [Gráfica] (#Grfica)
* [Deployment Table] (#Deployment_Table)
* [Pipeline Executions] (#Pipeline_Executions)
* [Pipeline Stats] (#Pipeline_Stats)
* [Pipeline Events] (#Pipeline_Events)

Gráfica
-------

![Gráfica]( ./img/pipelineReport/dp_desc_grafica.png "Gráfica")

Esta gráfica los diferentes estados por los que pasan los diferentes proyectos
controlados por la deployment pipeline. A partir de esta gráfica se pueden obtener 
datos como por ejemplo cuál es el proyecto que más actividad tiene, o cuál es el
proyecto con mayor número de fallos.


Cada estado está formado por:

| Campo           | Ejemplo                 | Descripción                                     |
|:----------------|:------------------------|:------------------------------------------------|
| pipelineId(host)|pipelineTraining(ironman)|Identificador de la pipeline                     |
| enviroment      |ci                       |Entorno en el que se está ejecutando la pipeline |
| fase            |install                  |Fase en la que está la pipeline                  |

El resultado de cada estado es:

| Resultado       | Color                   |Descripción                                    |
|:----------------|:------------------------|:----------------------------------------------|
| executing       |azul                     |Se está ejecutando dicho estado                |
| aborted         |naranja                  |Se ha abortado la ejecución de dicho estado    |
| ok              |verde                    |La ejecución ha acabado correctamente          |

Deployment Table
----------------
![Deployment Table]( ./img/pipelineReport/dp_desc_deploymentTable.png "Depoyment Table")

La tabla anterior muestra la configuración de cada uno de los entornos que forman 
una pipeline. Además da la posiblidad de hacer rollback de una instalación, es 
decir, volver a la instalación que se hizo anteriormente en un determinado 
entorno.

Los campos son:

| Campo                  | Descripción                                                     |
|:-----------------------|:----------------------------------------------------------------|
| Enviroment             |Identificador del entorno                                        |
| Ip/host                |ip/host de la máquina                                            |
| Packages               |paquetes instalados                                              |
| Current  installation  |BuildId de la instalación que está instalada en el entorno       |
| Rollback installation  |BuildId de la instalación que se haría en caso de rollback       |


Un entorno puede estar formado por varias máquinas.

Pueden haber ocasiones en el que el número del build Id de rollback sea superior
al de la instalación actual. Esto ocurre cuando realizamos un downgrade de un
determinado entorno. El rollback lo que hace es instalar la versión que había
instalada en el entorno anteriormente.

Pipeline Executions
-------------------

![Pipeline Executions]( ./img/pipelineReport/dp_desc_pipelineExecutions.png "Pipeline Executions")

Esta tabla visualiza las instalaciones que han habido en cada entorno.

Los campos son:

| Campo                  | Descripción                                                                                     |
|:-----------------------|:------------------------------------------------------------------------------------------------|
| Date                   |Fecha en la que se hizo la instalación en el primer entorno (ci)                                 |
| Build Id               |Es el idenficador del build de jenkins que hizo la instalación en el primer entorno (ci)         |
| ci                     |Resultado de la ejecución en el entorno de ci, así como la posiblidad de hacer upgrade/downgrade |
| qa                     |Idem para qa                                                                                     |
| thirdparty             |Idem para thirdparty                                                                             |
| exportRepos            |Da la posibilidad de exportar los paquetes que forman esa build-id a un repositorio              |

Los resultados de la ejecución están formados por la dupla phase-estado. Estas 
duplas son: install-ok,install-ko, smokeTest-ok, smokeTest-ko, acceptanceTest-ok, 
acceptanceTest-ko

En el ejemplo se observa que se pueden hacer upgrade o downgrade de diferentes 
instalaciones. La elección de que sea upgrade o downgrade depende del buildId
que haya instalado en un determinado entorno.

Pipeline Stats
--------------

![Pipeline Stats]( ./img/pipelineReport/dp_desc_pipelineStats.png "Pipeline Stats")

A partir de todos los eventos que se han ejecutado en las diferentes se extraen
una serie de estadísticas.

Pipeline Events
---------------

![Pipeline Events]( ./img/pipelineReport/dp_desc_pipelineEvents.png "Pipeline Events")

Es cada uno de los eventos que se producen en una pipeline.

Los campos son:

| Campo                  | Descripción                                                                                     |
|:-----------------------|:------------------------------------------------------------------------------------------------|
| Date                   |Fecha en la que se hizo la instalación en el primer entorno (ci)                                 |
| pipelineId(host)       |Identificador de la pipeline                                                                     |
| Enviroment             |Identificador del entorno                                                                        |
| Trigger                |Quién ha sido el responsable de disparar ese evento (un cambio en el scm, una ejecución manual o porque la fase anterior de la pipeline se ha ejecutado correctamente)                                                                                                             |
| Event                  |Evento que se ha producido                                                                       |
| Result                 |Evento en ejecución (executing) o una vez acabado (aborted,ok,ko)                                |
| Success                |Porcentaje de éxito de que un evento acabe ok                                                    |




