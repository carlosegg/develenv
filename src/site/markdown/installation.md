INSTALACIÓN A PARTIR DE RPMS
============================

* [Introducción] (#INTRODUCCIN)
* [Configuración repositorios de rpms] (#CONFIGURACIN_DE_REPOSITORIOS_DE_RPMS)
* [Configuración inicial] (#CONFIGURACIN_INICIAL)
* [Instalación] (#INSTALACIN)
* [Actualización] (#ACTUALIZACIN)
* [Instalación con puppet] (#INSTALACIN_CON_PUPPET)
* [Instalación en máquina vagrant] (#INSTALACIN_EN_MQUINA_VAGRANT)


INTRODUCCIÓN
------------
[Develenv](http://develenv.softwaresano.com) puede ser instalado y actualizado 
vía sistema de paquetes rpms.

La instalación de  [Develenv](http://develenv.softwaresano.com) ha sido probada 
en  Centos y Redhat 6.5, para el resto de versiones (inferiores a la 6 o superiores)
no se garantiza el funcionamiento.


CONFIGURACIÓN DE REPOSITORIOS DE RPMS
-------------------------------------
Los paquetes que componen [develenv](http://develenv.softwaresano.com) se 
encuentran en [develenvms.softwaresano.com](http://develenvms.softwaresano.com/public/downloads/repos/develenv). Para ello se han de instalar los siguientes
rpms:

```
carlosg@ironman:~$ sudo rpm -Uvh http://develenvms.softwaresano.com/public/downloads/repos/ss-develenv-repo-1.0-0.0.noarch.rpm
carlosg@ironman:~$ sudo rpm -Uvh http://thirdparty4-develenv-softwaresano.googlecode.com/svn/trunk/develenv/src/site/resources/tools/rpms/noarch/ss-thirdparty-develenv-repo-1.0-0.0.noarch.rpm
carlosg@ironman:~$ sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
carlosg@ironman:~$ sudo yum clean all
```


CONFIGURACIÓN INICIAL
---------------------

Como [develenv](http://develenv.softwaresano.com) instala toda una serie de 
servicios (jenkins, nexus, sonar) que requieren cierta configuración de usuarios, 
exiten diversas maneras de abordar este tema:

* [Configuración por defecto] (#CONFIGURACIN_POR_DEFECTO)
* [Configuración para autenticación en google] (#CONFIGURACION_PARA_AUTENTICACIN_EN_GOOGLE)
* [Configuración interna de TID] (#CONFIGURACIN_INTERNA_TID)


Configuración por defecto
-------------------------

En la configuración por defecto el usuario administrador es develenv y el password 
es develenv en todos los servicios que se han instalado en la máquina 
(jenkins, sonar, nexus).


Configuración para autenticación en google
------------------------------------------

En cambio si se quiere que la autenticación nos la provea nuestro usuario en 
google debemos, antes de instalar develenv en la máquina, hacer lo siguiente:

```
carlosg@ironman:~$ mkdir -p /etc/develenv
carlosg@ironman:~$ echo "-Dadministrator.id=carlosg -Dpassword=develenv \
-Dorg=http://develenv.softwaresano.com/develenv/src/main/filters/google.properties" >\ 
etc/develenv/develenv.properties
```

Una vez hemos creado el fichero procedemos a instalar develenv mediante los pasos 
que se detallan a continuación

Configuración interna de TID
----------------------------

Finalmente, si se quiere que la máquina este administrada desde algún usuario 
interno de tid el procedimiento es el siguiente:

```
carlosg@ironman:~$ mkdir -p /etc/develenv
carlosg@ironman:~$ echo "-Dadministrator.id=carlosg -Dpassword=develenv \
-Dorg=http://develenv.googlecode.com/svn/trunk/develenv/src/main/filters/tid.properties" >\ 
etc/develenv/develenv.properties
```

INSTALACIÓN
-----------

Para instalar [develenv](http://develenv.softwaresano.com) completamente 
debemos instalar lo siguiente:
 
```
carlosg@ironman:~$ sudo yum install ss-develenv-core
```
como ss-develenv-core tiene dependencias con el resto de paquetes que componen 
el ecosistema este comando nos instalará todo lo necesario, también se puede ver 
una lista completa de los paquetes que componen develenv mediante

```
carlosg@ironman:~$ yum search ss-develenv*
```
Una vez se tiene la lista, si se quiere instalar un sólo paquete (P. ej: sonar)

```
carlosg@ironman:~$ sudo yum install ss-develenv-sonar
```

pero hay que tener en cuenta que ahora mismo y a pesar de que estos paquetes se 
instalan independientemente los ejecutables, librerías y demás complementos del
paquete se instalan todos en el mismo path y que no hay scripts de inicio idependientes, 
por lo que si por ejemplo se instala solo sonar, se instalarán sus dependencias 
pero se deberá configurar varias cosas para hacerlo funcionar (tomcat, mysql, etc...)

ARRANQUE
--------

Si la instalación ha sido correcta, inmediatamente se inicializará la ejecución
 de [develenv](http://develenv.softwaresano.com). Al final de la instalación 
 aparecerán unos mensajes, indicando todas las URLs que forman
[develenv](http://develenv.softwaresano.com), junto con los usuarios y los 
passwords para acceder a cada una de las herramientas.
 
```
Los usuarios/password para ${project.artifactId} son:
Admin ${project.artifactId}:
   Usuario=${project.artifactId} 
   Password=${project.artifactId}
   Role=Administrador de tomcat
   Url=http://develenv_host/${project.artifactId}/admin/
Jenkins:
   Usuario=${project.artifactId} 
   Password=${project.artifactId} ó Si se ha configurado un LDAP para el acceso a Jenkins será el password que haya definido en LDAP
   Role= Administrador de jenkins
Url=http://develenv_host/jenkins
Nexus:
   Usuario=${project.artifactId}
   Password=develenv  ó Si se ha configurado un LDAP para el acceso a Nexus será el password que haya definido en LDAP
   Role=Administrador de nexus
   Url=http://develenv_host/nexus
Sonar:
   Usuario=${project.artifactId} 
   Password=develenv ó Si se ha configurado un LDAP para el acceso a Sonar será el password que haya definido en LDAP
   Role= Administrador de sonar
   Url=http://develenv_host/sonar
Selenium Grid:
   Url=http://develenv_host/grid
${project.artifactId}: Manuales de ${project.artifactId}
   Usuario=anonymous 
   Password=
   Url=http://develenv_host/docs
Logs de ${project.artifactId} 
   Usuario=anonymous 
   Password=
   Descripción=Acceso a los logs de ${project.artifactId}
   Url=http://develenv_host/${project.artifactId}/logs
Configuración de ${project.artifactId}
   Usuario=anonymous 
   Password=
   Descripción=Acceso en modo lectura a los ficheros de configuración de ${project.artifactId}
   Url=http://develenv_host/${project.artifactId}/config
Repositorios de componentes software
   Usuario=anonymous 
   Password=
   Descripción=Descripción=Repositorios con los componentes(maven, rpms, debian, ...) generados por los diferentes jobs de jenkins
   Url=http://develenv_host/${project.artifactId}/repos/

[NOTAS]
  [1] El arranque de ${project.artifactId} puede tardar varios minutos debido al arranque de sonar. Esto significa que durante el arranque al acceder a cualquier herramienta de ${project.artifactId}, el servidor devolverá 'Service Temporarily Unavailable' 
  [2] En  http://code.google.com/p/develenv-plugins/ existe una lista con los plugins disponibles para ${project.artifactId} (PHP, android, ...)  
  [3] En  http://code.google.com/p/develenv/wiki/newProject existe una guÃ­a para desarrollar tu primer proyecto con ${project.artifactId}
  [4] Las herramientas que componen ${project.artifactId}(sobre todo jenkins y sonar) utilizan plugins para ampliar la funcionalidad de las mismas. Estos plugins pueden consumir bastante memoria. Si ${project.artifactId} no arranca comprobar la memoria que queda libre en la máquina utilizando el comando free -m
  [5] Si no se va a utilizar Selenium Grid, puede desactivarse para rebajar el consumo de memoria. Consulta como hacerlo en http://develenv_host/docs/selenium/seleniumGridOff.html
  [6] ${project.artifactId} puede introducir algunos problemas de seguridad en el sistema. Para saber cuáles son y como elminarlos consulte http://develenv_host/docs/security.html
  [7] Consulta las últimas versiones disponibles de ${project.artifactId} en http://develenv.softwaresano.com
  [8] Cualquier error/sugerencia sobre ${project.artifactId} enviar un mail a ${project.artifactId}@softwaresano.com
```

Para arrancar [develenv](http://develenv.softwaresano.com) manualmente se ejecutará

```
carlosg@develenv_host:~$ sudo service ${project.artifactId} start
```

### Test funcionamiento

En el fichero [README](./README)  se describen las pruebas que se han de realizar para comprobar
que funciona correctamente [develenv](http://develenv.softwaresano.com). En 
 [README](./README) también se describen posibles problemas durante el arranque,
así­ como sus soluciones.

PARADA
------

```
carlosg@develenv_host:~$ sudo service ${project.artifactId} stop
```

ACTUALIZACIÓN
-------------

```
carlosg@ironman:~$ sudo yum update ss-develenv-core
```

INSTALACIÓN CON PUPPET
----------------------

Para hacer la instalación con puppet primero hay que disponer del mismo, se puede 
instalar de la siguiente manera:

```
carlosg@ironman:~$ sudo yum install puppet
```

Descargar el perfil de puppet

```
carlosg@ironman:~$ sudo yum install subversion
carlosg@ironman:~$ svn export http://develenv.googlecode.com/svn/trunk/develenv/src/main/deploy/puppet/
carlosg@ironman:~$ cd puppet
```

Revisar las variables (administratorId, password, profile, develenvVersion y
                       develenvUrlrepo)

```
# Review administratorId, password, profile,develenvVersion and develenv repo variables
$administratorId="develenv"
$password="develenv"
# Configuration profile
#Select a profile (softwaresanoProfile, tidProfile, googleProfile,...)
$profile=$softwaresanoProfile
#Select develenv version
$develenvVersion='latest'
#Select develenv yum repository
$develenvUrlrepo=$develenvProduction
```

una vez tenemos el perfil de puppet correcto se puede instalar 
[develenv](http://develenv.softwaresano.com) 
mediante la siguiente instrucción:

```
carlosg@ironman:~/puppet $ sudo puppet apply manifests/develenv.pp --modulepath=./modules --verbose --debug
```

siendo el contenido de [develenv.pp](http://develenv.googlecode.com/svn/trunk/develenv/src/main/deploy/puppet/manifests/develenv.pp)
 el siguiente:

```
################################################################################ #
# Puppet profile for install develenv                                            #
#--------------------------------------------------------------------------------#
# Review administratorId, password, profile and develenv_version variables       #
# and apply the profile with:                                                    #
# sudo puppet apply manifests/develenv.pp --modulepath modules --debug --verbose #
##################################################################################

# Configuration profile
#----------------------
#Select a profile (softwaresanoProfile, tidProfile, googleProfile,...)
$tidProfile="http://develenv.googlecode.com/svn/trunk/develenv/src/main/filters/tid.properties"
$softwaresanoProfile="http://develenv.googlecode.com/svn/trunk/develenv/src/main/filters/softwaresano.properties"
$googleProfile="http://develenv.googlecode.com/svn/trunk/develenv/src/main/filters/google.properties"

#---------------------------------------------------------
# Develenv repository section
# Select repository where develenv is available.
#---------------------------------------------------------
#Select yum repository for install develenv(develenvWithVagrant, develenvInTid, develenvProduction)
$develenvInTid="http://artifacts.hi.inet/develenv"
# For development develenv in vagrant use
$develenvWithVagrant="file:///home/vagrant/rpmbuild/RPMS"
#Repo with develenv production repo
$develenvProduction="http://develenvms.softwaresano.com/public/downloads/repos/develenv"
$javaurlrepo = "http://servilinux.hi.inet/java/yum/7/\$basearch"


#-------------------------------------------------------------------------------
# Review administratorId, password, profile and develenv_version variables
#-------------------------------------------------------------------------------
class { 'develenv':
   administrator    => "develenv",
   develenv_version => 'installed',           # 'installed','latest','25-6557'
   develenvrepo     => $develenvProduction,   # $develenvProduction, $develenvWithVagrant, $develenvInTid
   profile          => $softwaresanoProfile,  # $tidProfile,$softwaresanoProfile,$googleProfile
   password         => "develenv",
}
```

INSTALACIÓN EN MÁQUINA VAGRANT
------------------------------

Develenv puede ser instalado en una máquina vagrant tal y como se describe en
el proceso de [desarrollo de develenv](./development.html)