FUTUROS DESARROLLOS
===================

* [Discusión] (#DISCUSIN)
* [Bugs] (#BUGS)


DISCUSIóN
=========

PIPELINE-COMPLETO?? (Desde desarrollo a producción)
=================

Siempre que no tengamos la configuración exacta de cada uno de los entornos es 
muy arriesgado automatizar todo el proceso de configuración. Nos quedamos en la 
instalación del software, pero no en su configuración para los entornos de 
producción.


CONFIGURACIÓN-RPM vs PUPPET
===========================

Discusión

En el ejemplo todo está dentro de los rpms. En concreto
* Backend: En el caso del entorno de producción se ha abrir el puerto del conector AJP de tomcat
         http://pimpam.googlecode.com/svn/trunk/webCalculator-backend/src/main/rpm/SPECS/backend.spec
* Frontend: Si es producción se han de balancer las peticiones con los 2 backends.
         http://pimpam.googlecode.com/svn/trunk/webCalculator-frontend/src/main/rpm/SPECS/frontend.spec
         http://pimpam.googlecode.com/svn/trunk/webCalculator-frontend/src/main/rpm/SOURCES/enviroments/production/
   

  

¿QUÉ FALTA POR HACER?
======================
#### TODO --> Funciona cuando sólo hay un job -install. Solución prefijo JOB=PIPELINE_ID
#### TODO --> Tener en cuenta paquetes de mock (se podrían gestionar como los paquetes de entorno)
#### TODO --> En una instalación controlar que se desinstalen paquetes que hayan quedados obsoletos (que no estén puestos en la tabla del pipeline, básicamente comprobar todos los paquetes que hay instalados y que empiecen por el prefijo ss-"
#### TODO --> En caso de que falle un job y se intente reejecutar, no hay que volver a clonar el repo.
#### TODO --> Posibilidad de tener varias releases funcionando dentro del pipeline
#### TODO --> Externalizar el proceso de install para poder incluir puppet
#### TODO --> Añadir el usuario AdminUser como parámetro de configuración de la pipeline


BUGS
=====

## Activos
* Recargar la configuración de jenkins para que aparezcan (Pulsar aquí)
* Arreglar nombre de las máquinas (todo en mayúsculas)
* Exportar la clave ssh al usuario (root), cambiarlo por el usuario administrador
* Agregar el dominio bigdata para las máquinas de tashi
* Acceder con el usuario develenv a la máquina (recordar que develenv no tiene 
  password). ¿Qué pasa cuando hay puppet (sudo su)? sudo passwd
* El clonado del workspace lo ha de hacer el proyecto padre hacia el hijo, y
  no el hijo hacia el padre
    

## Cerrados