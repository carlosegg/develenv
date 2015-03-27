DEVPI SERVER
============

* [Introducción] (#INTRODUCCIN)
* [Acceso] (#ACCESO)
* [Deploy componentes python] (#DEPLOY_COMPONENTES_PYTHON)

INTRODUCCIÓN
------------
[devpi](http://doc.devpi.net/) es un proxy [pypi](https://pypi.python.org),
que permite deploy de componentes python.

devpi de momento sólo está disponible en instalaciones RH, a partir de rpms


ACCESO
------

[devpi](http://doc.devpi.net/) es accesible a través de la url
http://develenv_host/devpi.

Para acceder en modo proxy, se deben configurar 2 ficheros en el $HOME del usuario:

* Fichero **$HOME/.pip/pip.conf**

```
[global]
index_url = http://develenv_host/devpi/develenv/dev/+simple/
```

* Fichero **$HOME/.pydistutils.cfg**

```
[easy_install]
index_url = http://develenv_host/devpi/develenv/dev/+simple/
```


DEPLOY COMPONENTES PYTHON
-------------------------

Sólo jenkins podrá realizar despliegues de nuevos componentes en este proxy. Se 
ha definido este flujo para evitar que se desplieguen componentes python que no
hayan pasado un proceso de integración contínua.

Para subir un componente python a devpi, basta con ejecutar el comando **devpi-upload.sh**,
desde el directorio dónde se encuentra el ficher **setup.py** del componente.

[Aquí](http://doc.devpi.net/latest/quickstart-releaseprocess.html) está una
información más detallada del proceso de deployment


