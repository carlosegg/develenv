BUILD
=====

La fase de *build* es ejecutada por el job **-build**. Este job  generará los 
objetos que se utilizarán en la fase de [package](./index.html#Package).

Este job puede ejecutar un [build](https://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_build.sh )
por defecto para los siguientes tipos de proyectos:

* [Proyectos Ant] (#Proyectos_Ant)
* [Proyectos Maven] (#Proyectos_Maven)
* [Proyectos Web estáticos] (#Proyectos_Web_estticos)
* [Proyectos Python] (#Proyectos_Python)
* [Proyectos Makefile] (#Proyectos_Makefile)
* [Proyectos Sin Build] (#Proyectos_Sin_Build)
* [Proyectos a medida] (#Proyectos_a_medida)

La *deployment pipeline* recomienda una [estructura de directorios por defecto](#Estructura_de_directorios_por_defecto_recomendada_por_la_pipeline)
para los proyectos que se despliegan la pipeline, para evitar tener que hacer 
scripts a medida.

La ejecución de la fase de build comprende una serie de [tareas](./dp_build_tasks.html): **compilación** 
en el caso que sea necesario, **ejecución de test unitarios**, 
**extracción de métricas de calidad del código** y **generación de documentación**. 

La fase de build será exitosa si todas las tareas anteriores sean ejecutado
correctamente.

Proyectos Ant
-------------
Si en la raíz del proyecto hay un fichero **build.xml**, se ejecutará se ejecutará el script 
[dp_build_type_ant.sh](https://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_build_type_ant.sh),
que ejecutará *ant* con el target que se haya definido por defecto.

# Estructura recomendada de un proyecto con ANT
```
.
├── build.xml
├── RELEASE_NOTES
├── src
│   ├── main
│   │   ├── filters
│   │   ├── java
│   │   ├── resources
│   │   ├── rpm
│   │   │   ├── SOURCES
│   │   │   │   ├── enviroments
│   │   │   │   │   ├── staging    --> Ficheros de configuración especificos del entorno de staging
│   │   │   │   │   └── production --> Ficheros de configuración especificos del entorno de producción
│   │   │   │   └── backend        --> Ficheros de configuración comunes para todos los entornos
│   │   │   └── SPECS
│   │   │       └── backend.spec
│   │   └── webapp
│   └── test
│       ├── java
│       └── resources
└── VERSION.txt
```

Proyectos Maven
---------------
Si en la raíz del proyecto hay un fichero **pom.xml**, se ejecutará el script 
[dp_build_type_maven.sh](https://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_build_type_maven.sh). 

# Estructura recomendada de un proyecto con Maven
```
.
├── pom.xml
├── README.md
├── src
│   ├── main
│   │   ├── filters
│   │   ├── java
│   │   ├── resources
│   │   ├── rpm
│   │   │   ├── SOURCES
│   │   │   │   ├── enviroments
│   │   │   │   │   ├── staging    --> Ficheros de configuración especificos del entorno de staging
│   │   │   │   │   └── production --> Ficheros de configuración especificos del entorno de producción
│   │   │   │   └── backend        --> Ficheros de configuración comunes para todos los entornos
│   │   │   └── SPECS
│   │   │       └── backend.spec
│   │   └── webapp
│   └── test
│       ├── java
│       └── resources
└── VERSION.txt
```
# Compilación

[dp_compile_type_maven.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_compile_type_maven.sh) que lanza

```
mvn clean compile
```
# Tests unitarios

[dp_unitTest_type_maven.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_unitTest_type_maven.sh) que lanza

```
function execute(){
   local mavenArguments=""
   [[ "$(grep "cobertura-maven-plugin" pom.xml)" != "" ]] && \
      mavenArguments="$mavenArguments cobertura:cobertura -Dcobertura.report.format=xml"
   _log "[INFO] mvn install $mavenArguments"
   mvn install $mavenArguments
}
```
# Métricas de calidad del código

[dp_metrics_with_sonar.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_metrics_with_sonar.sh) que lanza

```
function execute(){
   local mavenArguments=""
   init
   [[ -f target/site/cobertura/coverage.xml ]] && \
      mavenArguments="$mavenArguments -Dsonar.dynamicAnalysis=reuseReports"
  _log "[INFO] mvn sonar:sonar $mavenArguments"
   mvn sonar:sonar $mavenArguments
   return $?
}
```
# Generación documentación

[dp_docs_type_maven.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_docs_type_maven.sh) que lanza

```
function execute(){
   local mavenArguments=""
   sed 1,`expr $(cat pom.xml|grep -n "<distributionManagement>"|cut -d':' -f1) - 1`d pom.xml >.deleteme 2>/dev/null
   if [ "$?" == "0" ]; then
      sed -i `expr $(cat .deleteme|grep -n "</distributionManagement>"|cut -d':' -f1) + 1`,10000d .deleteme 2>/dev/null
      if [ "`cat .deleteme|grep \"</site>\"`" != "" ]; then
         mavenArguments="$mavenArguments site:site site:deploy"
      fi
   fi
   rm -Rf .deleteme
   if [ "$mavenArguments" != "" ]; then
      _log "[INFO] mvn $mavenArguments"
      mvn $mavenArguments
   fi
}
```
Proyectos Web estáticos
-----------------------


# Estructura recomendada de un proyecto Web

Al tratarse de un proyecto web estático se puede utilizar la 
[Estrutura de directorios pro defecto recomendada por la pipeline](#Estructura_de_directorios_por_defecto_recomendada_por_la_pipeline)
En el caso de que haya test de javascript habrá que añadir en la raíz del proyecto
un *build.sh* que será el que invoque dichos tests.

Estructura de directorios por defecto recomendada por la pipeline
-----------------------------------------------------------------

```
.
├── README.md
├── RELEASE_NOTES
├── src
│   ├── main
│   │   ├── filters
│   │   ├── java
│   │   ├── resources
│   │   ├── rpm
│   │   │   ├── SOURCES
│   │   │   │   ├── enviroments
│   │   │   │   │   ├── staging    --> Ficheros de configuración especificos del entorno de staging
│   │   │   │   │   └── production --> Ficheros de configuración especificos del entorno de producción
│   │   │   │   └── frontend       --> Ficheros de configuración comunes para todos los entornos
│   │   │   └── SPECS
│   │   │       └── frontend.spec
│   │   └── webapp
│   └── test
│       ├── java
│       └── resources
└── VERSION.txt
```

Proyectos Python
----------------

# Estructura recomendada de un proyecto Python

Estructura de directorios por defecto recomendada por la pipeline
-----------------------------------------------------------------

```
.
├── README.md
├── setup.py
├── package
│   ├── __init__.py
│   ├── module_a.py
│   └── module_b.py
├── tests
│   ├── module_b-Test.py
│   └── module_a-Test.py
├── conf/*.cfg
└── VERSION.txt
```
# Tests unitarios

[dp_unitTest_type_python.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_unitTest_type_python.sh) que lanza

```
function execute(){
   nosetests --cover-erase --with-cov  --cov-report=xml \
         --cov-config=$pythonDirConf/coverage.rc \
         --with-xunit --xunit-file=$TEST_REPORTS -sv
}
```
[coverage.rc](http://code.google.com/p/develenv-python-plugin/source/browse/trunk/python_plugin/plugin/app/plugins/python_plugin/conf/coverage.rc) viene con la instalación del 
[python plugin para develenv](http://code.google.com/p/develenv-python-plugin/)

```
function execute(){
   ...
   nosetests --cover-erase --with-cov  --cov-report=xml \
         --cov-config=$pythonDirConf/coverage.rc \
         --with-xunit --xunit-file=$TEST_REPORTS -sv
   ...
}
```


# Métricas de calidad del código

[dp_metrics_with_sonarRunner.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_metrics_with_sonarRunner.sh) publica las
métricas de calidad del código en sonar reutilizando los informes de los tests
unitarios que se han generado

Proyectos Makefile
------------------

# Estructura recomendada de un proyecto Python

Estructura de directorios por defecto recomendada por la pipeline
-----------------------------------------------------------------

```
.
├── README.md
└── Makefile
```
# Tests unitarios

En el *Makefile* debe definirse el target test

# Métricas de calidad del código

En el *Makefile* debe definirse el target metrics

Proyectos a medida
-------------------

Para el tipo de proyectos que no están contemplados por la
deployment pipeline se puede realizar una implementación a
medida. Para ello es necesario definir en el raiz del proyecto
el fichero *.dpSetup*, con el siguiente contenido:

```
#!/bin/bash
DP_BUILD_TYPE="morfeo"
DP_PACKAGE_TYPE="morfeo"
```

y a continuación se deberían implementar los siguientes 
scripts:

```
/home/develenv/app/plugins/pipeline_plugin/dp_build_type_morfeo.sh
/home/develenv/app/plugins/pipeline_plugin/dp_compile_type_morfeo.sh
/home/develenv/app/plugins/pipeline_plugin/dp_unitTest_type_morfeo.sh
/home/develenv/app/plugins/pipeline_plugin/dp_metrics_type_morfeo.sh
/home/develenv/app/plugins/pipeline_plugin/dp_docs_type_morfeo.sh
```
que ha de seguir las plantillas:

[dp_build_type_maven.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_build_type_maven.sh)
[dp_compile_type_maven.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_compile_type_maven.sh)
[dp_unitTest_type_maven.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_unitTest_type_maven.sh)
[dp_metrics_type_maven.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_metrics_type_maven.sh)
[dp_docs_type_maven.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_docs_type_maven.sh)
[dp_package_type_morfeo.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_package_type_redhat.sh)

# Estructura recomendada de un proyecto a medida

Estructura de directorios para un proyecto a medida
---------------------------------------------------

```
.
├── .dpSetup
├── src
└── README.md
```

Proyectos Sin Build
-------------------

Son proyectos que no necesitan fase de build. Pero si que necesitan una fase de 
package. Actualmente sólo se considera la fase de package para proyectos que
soporten rpms.

# Estructura recomendada de un proyecto sin build

Estructura de directorios por defecto recomendada por la pipeline
-----------------------------------------------------------------

```
.
├── conf
│   └── redis.conf
├── LICENSE
├── README.markdown
└── spec
    └── redis.spec
```
