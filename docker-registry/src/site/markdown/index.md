DOCKER-REGISTRY
===============

* [Introducción](#INTRODUCCIN)
* [Configuración](#CONFIGURACIN)
* [Descargase una imagen](#DESCARGARSE UNA IMAGEN)
* [Desplegar develenv en docker](#DESPLEGAR DEVELENV EN DOCKER)

INTRODUCCIÓN
------------

 develenv proporciona un repositorio de imáqgenes de docker

CONFIGURACIÓN
-------------

Una vez instalado el software de docker, es necesario configurarlo para poder 
acceder al repositorio de imágenes. Los pasos a realizar son:

Autorizar el acceso al repositorio vía http
-------------------------------------------

Depende del sistema operativo del host, en caso de que sea CentOS/RedHat, se ha
de editar el fichero /etc/sysconfig/docker y agregar el parámetro **--insecure-registry**
con la url del del servidor de docker

```
DOCKER="/usr/bin/docker"
other_args="  -H unix:///var/run/docker.sock --insecure-registry develenv:5010"
export TMPDIR="/tmp/"
```


Autenticarse en el repositorio
------------------------------

Para autenticarse ejecutar el comando:

```
docker login -e carlosg@softwaresano.com -u carlosg -p carlosg http://develenv:5010/
```

DESCARGARSE UNA IMAGEN
----------------------

```
docker pull <image_name>
```

DESPLEGAR DEVELENV EN DOCKER
----------------------------

TODO
