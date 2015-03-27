DEPLOYMENT PIPELINE
===================

* [Introducción] (#INTRODUCCIN)
* [Instalación] (#INSTALACIN)
* [Definición Pipeline] (#DEFINICIN_DE_UN_PIPELINE)
* [Primeros Pasos] (#PRIMEROS_PASOS)
* [Ejecución] (#EJECUCIN)
* [Limitaciones del pipeline] (#LIMITACIONES_DEL_PIPELINE)
* [Ejemplos] (#EJEMPLOS)
* [Workshop] (http://develenv-pipeline-plugin.googlecode.com/svn/trunk/docs/pipelineTraining/index.html)

INTRODUCCIÓN
------------
Cada vez que se realice un cambio en el software(commit en el repositorio) 
debería poder ser instalado en cualquier entorno. Para ello es necesario disponer 
de un panel con los diferentes builds que se han generado del proyecto y en qué
entornos ha sido o puede ser instalado.

![Ejemplo Pipeline]( http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/01_pipelineDashBoard.png "Ejemplo Pipeline")

Mediante la utilización **deployment pipeline** se pretende evitar problemas en 
la instalación de un entorno nuevo, puesto que el proceso de instalación del 
software se tiene en cuenta desde el principio.


INSTALACIÓN
-----------

La deployment pipeline viene instalada con [develenv] (http://develenv.softwaresano.com). Para
utilizarla fuera de [develenv] (http://develenv.softwaresano.com) se puede hacer:

* Utilizando el rpm que está disponible en el repositorio de develenv:

```
yum install ss-develenv-dp
```

Revisar que los valores del fichero de configuración **/opt/ss/develenv/dp/config/dp.cfg**
son los adecuados

 * Descargando los fuentes directamente del repositorio

```
svn export http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin
cd pipeline_plugin
export PATH=$PWD:$PATH
```

Revisar que los valores del fichero de configuración **config/dp.cfg**
son los adecuados

Para ver un listado de  todos los comandos disponibles:

```
dp_help
```


DEFINICIÓN DE UN PIPELINE
-------------------------

El pipeline es un [flujo de tareas](http://develenv.googlecode.com/svn/trunk/develenv/deploymentPipeline/src/site/resources/pipelineFlow.png "flujo de tareas") 
que se ejectan secuencialmente, iniciándose cuando se hace una entrega al 
repositorio SCM, y si todo se ejecuta acaba con unas pruebas de aceptación
pasadas correctamente.

![flujo de tareas](http://develenv.googlecode.com/svn/trunk/develenv/deploymentPipeline/src/site/resources/pipelineFlow.png "flujo de tareas")


Todo el pipeline está dirigido por jobs de Jenkins. El nombrado de los jobs 
servirá al pipeline para ejecutar los scripts correspondientes a cada fase del 
pipeline. Así el nombre de un job está formado por

[projectName]-[module]-[order]-[phase]. Donde:

* **projectName**: Es el identificador del proyecto
* **module**: Módulo del proyecto (Ej. frontend ,backend). Existen 2 módulos
 especiales:
 * ALL: Identifica una tarea que se ha de ejecutar con los diferentes módulos 
   del proyecto. (Por ejemplo install,  smokeTest, y acceptanceTest se ejecutarán
   después de que haya un cambio en alguno de los módulos)
 * EXPORT: Exporta el repositorio de componentes(actualmente sólo rpms) a un 
   fichero para poderlo copiar en una máquina en la que no tenemos acceso 
   actualmente.
* **order**: Es ún número de 2 cifras cuya única misión es que aparezcan 
  ordenados los jobs en el pipeline según su orden de ejecución.
* **phase**: Fase de ejecución del pipeline. Estas fases son (build, package, 
  install, smoketest, acceptanceTest)

Habrá varios tipos de jobs,

  * [Pre-deploy (Un job por cada fase y componente)](#Pre-deploy_Jobs)
    * [Build (compile, unit Test, integration Test, Metrics)(Developer)](#Build)
    * [Package (dependendiente del S.O) (Release Engineer)](#Package)
  * [Deploy  (Un job común por fase para todos los componentes)](#Deploy_jobs)
    * [Install (Release Engineer)](#Install)
  * [Post-deploy (Un job común por fase para todos los módulos)](#Post-deploy_Jobs)
    * [Smoke Tests (Comprobar mínimimamente que funcionan cada uno de los módulos) (Release Engineer)](#Smoke_test)
    * [Acceptance Tests (QA Engineer)](#Acceptance_test)
         
Pre-deploy Jobs
---------------

   Este tipo de jobs se debe crear uno por cada componente del proyecto. 
   (En el [ejemplo](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/examples/webCalculator/) 
   hay un job para el backend y otro para el frontend).
   
   A partir de un commit en un repositorio se han de ejecutar una serie de 
   pasos(pueden ser todos en el mismo job). El objetivo final es generar un 
   paquete para ser instalado en el S.O, en este caso un rpm.
   
### Build
El objetivo de este job es generar los objetos que se utilizarán en la fase de 
[package](#Package). Por ejemplo si se desarrolla una apliación web, la salida 
de este job debería ser un fichero  **.war** y los ficheros de configuración 
necesarios para poder configurar la aplicación en cualquier entorno conocido.

Cuando se ejecute este job se buscará inicialmente un script [build.sh](https://code.google.com/p/pimpam/source/browse/trunk/webCalculator-backend/build.sh) 
en la raíz del proyecto. Si no se encuentra entonces se ejecutará el script [dp_build.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_package.sh "dp_build.sh") que integra este
plugin

### Package
Generará el paquete (actualmente sólo rpm) a partir de los objetos generados en 
la fase de [build](#Build)

Cuando se ejecute este job se buscará inicialmente un script **package.sh** en 
la raíz del proyecto. Si no se encuentra entonces se ejecutará el script 
[dp_package.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_package.sh) 
que integra este plugin. Para utiliar de [dp_package.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_package.sh "dp_package.sh") se han de cumplir los requisitos que se recogen
[aquí](./dp_package.html "aquí").


   
Deploy Jobs
-----------
   El objetivo de este tipo de jobs es desplegar el proyecto completo en un 
   entorno determinado. 

### Install

   En este Job se define la tabla de despliegue. Esta tabla recoge la información 
   de que componentes hay instalados en cada una de las máquinas que forman un 
   entorno. Por ejemplo, el entorno de producción está formado por 3 máquinas, y
   en cada máquina se definen todos los componentes que se van a instalar.

```
##################### DEPLOYMENT TABLE ############################
# Organization: ss
# Project: webCalculator
# Enviroments: continous-int qa preproduction production
#--------------+----------------------------+---------------------------------------------------
# Enviroment   | IPs/Hosts                  | Packages
#--------------+----------------------------+---------------------------------------------------
continous-int  | ci-emc2-xp                 | ss-webCalculator-backend ss-webCalculator-frontend
qa             | ci-conelect                | ss-webCalculator-backend ss-webCalculator-frontend
preproduction  | connect-ci                 | ss-webCalculator-backend ss-webCalculator-frontend
production     | wcbackend1.bigdata.hi.inet | ss-webCalculator-backend
production     | wcbackend2.bigdata.hi.inet | ss-webCalculator-backend
production     | wcfrontend.bigdata.hi.inet | ss-webCalculator-frontend
```
*IMPORTANTE* Si se añade un entorno extra a posteriori, no sólo se debería añadir
en la tabla inferior, sino también en el campo **Enviroments**

Puede ser que antes de realizar la instalación de un entorno se deba realizar
alguna tarea anterior. Para ello basta con añadir un script **pre-install.sh**
en el raíz del repositorio de código.

También puede ser necesario realizar alguna acción de postinstalación, como por ejemplo
configurar el entorno. Para ello sólo hay que añadir el script **post-install.sh**
en el raíz del repositorio de código.

Sólo en el primer entorno se pueden definir versiones de paquetes, el resto de 
entornos heredará la versión de paquete que se haya instalado en el primer entorno. 
Esto se ha definido así para obligar que lo que se haya instalado en un entorno
haya pasado primero por el primer entorno.
 
Si algún paquete tiene dependencias de otros paquetes que se construyen dentro
de la pipeline, esas dependencias no se van a actualizar cuando se instalen los
paquetes listados en la deployment table. Para asegurar una instalación completa
de los últimos paquetes se puede hacer o bien listando todos los paquetes en la
deployment table, o bien añadiendo en los specs (campo *Requires*) las 
restricciones de las versiones de los paquetes que depende.

Post-Deploy Jobs
----------------

### Smoke Test
   Este job comprueba que hay connectividad entre los diferentes componentes que
   forman el proyecto. 
   El tipo de tests que debe ejecutar no deberían alterar el estado del proyecto 
   (p.ej no deberían escribir en la DB).
   Este tipo de tests se podrían reutilizar en una herramienta de monitorización
   (tipo [Nagios](http://www.nagios.org/ "Nagios"))
   
   Cuando se ejecute este job se buscará inicialmente un script 
   [smokeTest.sh](http://develenv.googlecode.com/svn/trunk/develenv/smokeTest.sh) 
   en la raíz del proyecto.
   
   [Ejemplo de SmokeTest](http://develenv.googlecode.com/svn/trunk/develenv/smokeTest.sh)
   
   En el ejemplo sólo se hacen comprobaciones sobre peticiones http, para otro 
   tipo de proyectos se deberían revisar el tipo de smokeTests que se realizan.
   
   La invocación de este script debe tener el formato que se indica en la sección
   de ayuda del propio script

```
smokeTest Execution:

Usage:
    ./smokeTest.sh  < -e <environmentId> > [ -t <deploymentTableFile> ] [-p <wait seconds>] [ -h ]


Parameters:
    <environmentId>  environment against smokeTests are run
    <deploymentTableFile> File with the definition of environments and URLs
    <wait seconds> number of seconds to wait for the environment to be ready

Examples:
    ./smokeTest.sh -e int -p 150
    ./smokeTest.sh -e int
    ./smokeTest.sh -t deploymentTableFile.txt -p 120 
    Where a deploymentTableFile.txt looks like this:
#--------------+--------------------------------------------------------------
# Enviroment   | URL 
#--------------+--------------------------------------------------------------
int            | http://int-develenv-01.hi.inet
qa             | http://qa-develenv-01.aislada.hi.inet

```

Cuando el smokeTest se ejecuta dentro de la pipeline la deploymentTable la cogerá
de la configuración del propio job de **smokeTest**, es decir, la pipeline invocará
este script con el parámetro -t agregándole la deployment table que se ha definido
en la configuración del propio job

Para la implementación de estos tests se ha creado una librería [libtest](./libtest.html)


### Acceptance Test 
   Este job realiza las pruebas automáticas funcionales(End2End) de un entorno 
   completo. Cuando se ejecute este job se buscará inicialmente un script 
   [acceptanceTest.sh](http://develenv.googlecode.com/svn/trunk/develenv/acceptanceTest.sh) 
   en la raíz del proyecto.
   
   [Ejemplo de Acceptance Test](http://develenv.googlecode.com/svn/trunk/develenv/acceptanceTest.sh)
 
La ejecución de los acceptanceTest es idéntica a la que se hace para los 
[smoke test](./index.html#Smoke_Test)


PRIMEROS PASOS
--------------
Una vez [instalado](#INSTALACIN) el plugin, se deben seguir los siguientes pasos:

* [Definición del pipeline] (#Definicin_del_pipeline)
    * [Entornos] (#Entornos)
    * [Módulos] (#Mdulos)
* [Creación del pipeline] (#Creacin_del_pipeline)
    * [Línea de comandos] (#Creacin_del_pipeline_Lnea_de_comandos)
    * [Interfaz gráfica] (#Creacin_del_pipeline_Interfaz_Grfica)
* [Configuración del pipeline] (#Configuracin_del_pipeline)

Se recomienta seguir las estructuras recomendadas en la fase de [build](dp_build.html).
para evitar realizar scripts a medida, por ejemplo, 
para utilizar el script de package de la pipeline,


## Definición del pipeline
### Entornos
   Definir el número de entornos donde se va a instalar el proyecto. Por ejemplo
   (ci, qa,thirdparty y demo)
### Módulos
   Módulos que forman el proyecto. Por ejemplo (frontend y backend)
## Creación del pipeline
   Toda la administración de los pipelines se puede hacer tanto por línea de 
   comandos, como a partir de jobs definidos en jenkins.
    
   * [ Línea de comandos ] (#Creacin_del_pipeline_Lnea_de_comandos)
   * [ Interfaz Gráfica ] (#Creacin_del_pipeline_Interfaz_Grfica)

### Creación del pipeline (Línea de comandos)
```
carlosg@ironman:~$ sudo su - develenv
develenv@ironman:~$ cd app/plugins/pipeline_plugin/
develenv@ironman:~/app/plugins/pipeline_plugin$ ./pipelineProject.sh --help
Uso: ./pipelineProject.sh <organization> <project-name> <version> <module [module]*> <enviroment [enviroment]*> [--help]
Creación del deployment pipeline de un proyecto


EJEMPLO:
    ./pipelineProject.sh "ss" "webCalculator" "1.0" "frontend backend" "ci qa thirdparty demo"

Más información en http://code.google.com/p/develenv-pipeline-plugin
develenv@ironman:~/app/plugins/pipeline_plugin$ ./pipelineProject.sh "ss" "webCalculator" "1.0" "frontend backend" "ci qa thirdparty demo"
[INFO] Reload jenkins configuration to aply the last changes (http://ironman/jenkins/reload).
develenv@ironman:~/app/plugins/pipeline_plugin$ # Para añadir un nuevo módulo se haría
develenv@ironman:~/app/plugins/pipeline_plugin$ ./pipelineModule.sh --help
Uso: ./pipelineModule.sh <project-name> <module>[--help]
Creación de un módulo dentro del deployment pipeline de un proyecto. Para crear un módulo es necesario que el proyecto esté creado anteriormente.


EJEMPLO:
    ./pipelineModule.sh "webCalculator" "admin" 
```

### Creación del pipeline (Interfaz Gráfica)
   
![Vista de administración de la pipeline](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/adminPipelineView.png
)
   Para crear un pipeline nuevo se ha de ejecutar el job 
   **pipeline-ADMIN-01-addPipeline**. 
   
![Creación y configuración de un pipeline](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/addPipelineConfiguration.png)
   
## Configuración del pipeline

 Si la ejecución del job ha sido correcta. Se deben seguir los pasos indicados 
 en el link **Next Steps** que aparece después de la creación del pipeline:
 
 * Recargar configuración de jenkins
 * Revisar tabla de despliegues
 * Exportar la clave pública del usuario develenv /home/develenv/.ssh/id_dsa.pub 
   al usuario **AdminUser** de cada una de las máquinas a la que accede el 
   pipeline
 * Configurar repositorio de fuentes para develenv-ALL-02-smokeTest
 * Configurar repositorio de fuentes para develenv-ALL-03-acceptanceTest
 * Configurar repositorio de fuentes para develenv-kernel-01-build
 * Cada módulo puede tener dependencias de librerías, asegurarse que exite el 
   job que genera el build para dichas librerías
 
 
 
![Creación correcta del pipeline](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/addPipelineOk.png
)
 
 Es necesario acabar de configurar los diferentes jobs de jenkins, para hacerlo 
 puedes pinchar en el enlace "Next Steps" que ha aparecido en el menú de la 
 izquierda

![Configuración jobs pipeline](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/addPipelineNextSteps.png
)

### Recargar configuración de jenkins

Cuando se haya recargado la configuración de jenkins aparecerán nuevas vistas en
jenkins. 

![Vista con todos los jobs asociados al pipeline](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/reloadJenkinsAllJobs.png)
![Vista con el pipeline del módulo de backend](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/webCalculatorBackendPipeline.png)
![Vista con el pipeline del módulo de frontend](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/webCalculatorFrontendPipeline.png)

### Revisión de la tabla de despliegue

![Revisión tabla de despliegue](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/reviewDeploymentTable.png)

La deployment pipeline permite que los rpms generados sean accesibles desde una
url externa a develenv. Para ello se han de seguir las instrucciones que aparecen
[aquí](./dp_remote_repo_rpm.html)

### Exportar clave ssh de develenv a las máquinas del pipeline
![Exportar clave ssh de develenv](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/exportSshKey.png)

### Configuración SCM de los diferentes jobs

![Configuración SCM frontend](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/configureScmFrontend.png)
![Configuración SCM backend](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/configureScmBackend.png)
![Configuración SCM smokeTest](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/configureScmSmokeTest.png)
![Configuración SCM acceptanceTest](http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/configureScmAcceptanceTest.png)
 
### NOTAS SOBRE LA CONFIGURACIÓN

 Después de la generación automática es muy importante revisar que toda la 
 configuración que se ha generado de forma automática es correcta:
 * Se ha creado una tabla de deployment automática en el job de 
   **-ALL-01-install**, donde aparecen los nombres de las máquinas sin dominio.
 * Se ha creado una tabla de deployment automática en los jobs de 
   **-ALL-02-smokeTest** y **-ALL-03-acceptanceTest**. Si se utilizan como 
   plantilla los ejemplos de smokeTest y acceptanceTest anteriores, si se borra 
   la deployment Table coge la deployment Table que hay entregada en el 
   repositorio.

Hay que seguir extrictamente el formato de la deployment table para que la 
ejecución de los scripts de la pipeline no fallen. Por ejemplo no se puede 
eliminar la línea
 ```
 ##################### DEPLOYMENT TABLE ############################
 ```
 ya que esta línea es la que se utiliza como separador entre el script y la deployment table
 

EJECUCIÓN
---------
Cada vez que se haga un commit en alguno de los módulos que forman parte 
proyecto del pipeline se invocará el pipeline. Si la construcción del build, 
el empaquetado y los tests son correctos el proyecto quedará instalado en el 
entorno de ci, y listo para ser instalado en el siguiente entorno 
(por ejemplo en qa). En cada uno de los jobs que forman la pipeline
aparece el link **Deployment Pipeline** (http://ironman/sites/pipelines/webCalculator/pipeline.html) 
que apunta a una página del siguiente estilo.


![Deployment Report] (http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/sites/plugins/pipeline_plugin/deploymentReport.png)



LIMITACIONES DEL PIPELINE
-------------------------
Actualmente este plugin está desarrollado para proyectos instalados bajo
distribuciones Redhat/CentOS(Se ha testeado para RH 5.8, Centos 6.2, Centos 6.3
y Centos 6.4 aunque puedeque funcione para otras versiones).Esto implica que cualquier 
componente de un proyecto debe estar paquetizado en formato rpm. Tal y como se 
ha desarrollado el pipeline permite una fácil extensión para otro tipo de 
distribuciones.

Para poder realizar la instalación en cada uno de los entornos, debe existir 
connectividad http y ssh entre la máquina donde está instalado develenv y cada 
una de las máquinas que forman el pipeline. Si no existe conectividad siempre 
existe la opción de exportar el repositorio (job EXPORT).

En cada paquete debe ir la configuración de los diferentes entornos. En el caso 
de que no se conozca la configuración o no se desee poner dentro del paquete 
existen 2 posibilidades:

* Asegurarse que las máquinas disponen de la configuración correcta antes de 
  realizar la instalación de los paquetes
* Realizarlo mediante Puppet


No se puede añadir un proyecto multiconfiguración de jenkins, por:
* Se ha de replicar el WS del proyecto padre con los diferentes hijos (solucionado)
* Después de la ejecución de cada hijo se debería invocar al siguiente job (Bloqueante). 
Solución ejecutar en el mismo job las diferentes configuraciones

PRECAUCIONES CON LA PIPELINE
----------------------------

Todo el proceso de instalación de paquetes se hace a partir de repositorios de
rpms, cualquier proceso con el acceso a dichos repositorios aboratará la instalación. 

La mayoría de las herramientas que se utilizan para trabajar con rpms (yum, createrepo, ...)
utilizan python, por tanto no modificar el python que viene instalado en el sistema
operativo.

EJEMPLOS
--------

* [Develenv](../pipelines/)
