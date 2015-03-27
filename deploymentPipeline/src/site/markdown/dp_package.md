EMPAQUETADO POR DEFECTO EN EL DEPLOYMENT PIPELINE (Sólo empaquetado rpm)
========================================================================

* [Requisitos del rpm(.spec)] (#Requisitos_del_rpm_.spec)
* [Transformación del fichero .spec] (#Transformacin_del_fichero_.spec)
* [Obtención de la versión y release] (#Obtencin_de_la_versin_y_release)
* [Depuración del rpm] (#Depuracin_del_rpm)

La construcción de paquetes en la *deployment pipeline* es independiente de la 
construcción de paquetes en si mismo, es decir, los ficheros **.spec** deben
ser funcionales. En otras palabras, si ejecutas rpmbuild dentro de la carpeta 
*src/main/rpm* contra uno de los **.spec** que tú hayas creado debe construirse
el paquete correctamente.

Para generar el rpm dentro de la *deployment pipeline* se ha de definir el fichero 
**.spec** con los requisitos que se detallan a continuación

Requisitos del rpm .spec
------------------------

* De momento no se contemple el uso de macros definidas por proyecto y/o 
usuario, ya que son una fuente potencial de problemas.

* La ubicación del **.spec** es obligatorio que esté en
el directorio *$PROJECT_HOME/{component_name}/rpm/SPECS* aunque en proyectos maven
podría estar en *$PROJECT_HOME/{component_name}/src/main/rpm/SPECS* 

* La ubicación de los *SOURCES* del paquete debe ser un directorio que este a 
la misma altura que la carpeta *SPECS* del punto anterior. No debería establecerse
la macro **_sourcedir** ya que la pipeline la redefine y podría generar conflictos.

* Es obligatorio que el fichero tenga completados los campos 
**License, Vendor, Summary, y description**, sino se abortará la  creación del 
rpm informando del error.
 
* Número de versión configurable a partir de la macro versionModule

```
Version:   %{versionModule}
```

* Número de release a partir de la macro releaseModule

```
Release:   %{releaseModule}
```
* El BuildRoot, se asignará automáticamente el valor %{_topdir}/BUILDROOT. El 
valor de *TOPDIR* asignado es *TOPDIR=$PROJECT_HOME/target/.rpm*

```
BuildRoot:  %{_topdir}/BUILDROOT
```

Para la creación del rpm se invoca el comando **rpmbuild** de la siguiente forma:

```
rpmbuild -v --clean  --define '_buildshell '/bin/bash --define '_topdir '${TOPDIR} \
 --define 'versionModule '1.0 --define 'releaseModule '23 -bb $modifiedSpecFile"
```

Transformación del fichero .spec
--------------------------------

El script [dp_package_type_redhat.sh](http://code.google.com/p/develenv-pipeline-plugin/source/browse/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/dp_package_type_redhat.sh "dp_package_type_redhat.sh") 
modifica el **.spec** con los objetivos siguientes

### Nombre de Paquete 

Al nombre del paquete final se le añadirá un prefijo formado por los campos de 
**organization** y **project** que se han definido en la deployment table.

Para el ejemplo que estamos abordando:

```
Name: frontend 
```
se transforma en 

```
Name: ss-webCalculator-frontend
```
### Repositorio SCM

Para poder saber donde están almacenados las fuentes del paquete que se está 
construyendo en el campo **description** se agrega la información relacionado 
con el SCM

```
%description
Adder application frontend
-------------------------------------SCM----------------------------------------
Path: .
URL: http://pimpam.googlecode.com/svn/trunk/webCalculator-frontend
Repository Root: http://pimpam.googlecode.com/svn
Repository UUID: 4a94ff34-e01e-11dd-987e-d7c0a4ebcf36
Revision: 1555
Node Kind: directory
Schedule: normal
Last Changed Author: carlosegg
Last Changed Rev: 1555
Last Changed Date: 2012-10-25 09:30:50 +0200 (Thu, 25 Oct 2012)
```
### Build
Información del build de jenkins que ha creado el rpm

```
----------------------------------Jenkins---------------------------------------
Build ID: 2012-10-25_09-31-20
Build URL: http://ci-pipeline.hi.inet/hudson/job/webCalculator-frontend-02-package/3/
```
### Versión de develenv
Versión de develenv con la que se ha creado el rpm

```
----------------------------------Develenv--------------------------------------
Version: 17-SNAPSHOT
```

### Ejecución rpmbuild
Comando rpmbuild que ha generado el rpm

```
----------------------------------rpmBuild--------------------------------------
rpmbuild -v --clean --define '_buildshell '/bin/bash \
--define '_topdir '/home/develenv/app/hudson/jobs/webCalculator-frontend-02-package/workspace/target/.rpm \
--define 'versionModule '1.1 --define 'releaseModule '1555 \
-bb /var/tmp/rpm/ss-webCalculator-frontend-1.1-1555/ss-webCalculator-frontend.spec
```

### Macros RPM
Al fichero **.spec** se le añaden [macros](dp_package_rpmmacros.html).
Existen dos tipos de macros:

#### Macros de Logs
En el inicio de cada sección del **.spec** se añade un macro de log, para indicar
que empieza una sección determinada.
Si en dicha sección se quiere añadir un *log*, basta con invocar la macro *_log*, 
como se muestra en el ejemplo siguiente

#### Macros de exclusión de ficheros
En las secciones **install build prep** se ejecuta la macro **_default_exclude_files**. 
Esta macro elimina los ficheros: **.svn .cvs* .hg* .git* .classpath .settings .project *.bak *.pyc *.*~**


Otención de la versión y release
--------------------------------
   
### Obtención de la versión

Al rpm se le ha de añadir tanto la release, como la versión. El cálculo de la 
versión se hace dependiendo si está definido el fichero **VERSION.txt**,del tipo
 de proyecto y del tipo de repositorio SCM utilizado.

#### Fichero VERSION.txt

Un ejemplo de VERSION.txt es:

```
Project: webCalculator
Module: frontend
Version: 1.1
Organization: SoftwareSano
PrefixOrganization: ss
```

Si está definido el fichero anterior, el número de versión  es el definido en el
 fichero **VERSION.txt**. Sino está definido este fichero hay tres casos:

* Si se trata de un proyecto tipo **maven** la versión se extraerá del **pom.xml**.
* Si el proyecto está almacenado en un repositorio **git**, si la rama que se 
  está constuyendo acaba por **release**-X.Y.Z
* Si no es así, se se devuelve el error **"Es necesario definir un fichero VERSION.txt**

### Obtención de la release

Depende del tipo de repositorio SCM donde se almacena el módulo. El objetivo es 
que éste sea un número incrementable.

#### Subversion
El número de release se calcula como el número de revisión del repositorio, más 
el número de revisión de todos los links externos de svn, que se definen en el 
raíz del repositorio.

#### Git
Al ser un tipo de repositorio distribuido no se puede obtener el número release 
como el número de entregas al repositorio, ya que depende de la rama. Por tanto 
el número de release es un timestamp más el hash del último commit.

```
echo $(date '+%Y%m%d_%H%M%S')-$(git --no-pager log --max-count=1|grep "^commit"|awk '{print $2}')
```

En el caso de que se necesite la información sobre la revisión del repositorio
que se utilizó para realizar la rpm, basta con ejecutar:

```
 yum info <nombre_paquete>
```


Depuración del rpm
------------------

Para poder revisar el fichero **.spec** que genera el rpm, y cada uno de los 
scripts que se ejecutan en cada una de las fases se ha de activar la depuración 
del pipeline. Para ello basta con acceder a la configuración del job de INSTALL
del pipeline, y definir la variable **DEBUG_PIPELINE="TRUE"**

```
...
export DEBUG_PIPELINE="TRUE"
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


