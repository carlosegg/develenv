Lib Test
========

Esta librería simplifica la invocación de los tests dentro de la pipeline. Además
añade funciones para invocar a diferentes tipos de tests (selenium, jmeter, 
httpOk y soapui)

* [Primeros pasos] (#Primeros_pasos)
* [Funciones librería] (#Funciones_librera)

Primeros pasos
--------------

* [Agregar librería] (#Agregar_librera)
* [Construir el fichero de smoke o acceptanceTest] (#Construir_el_fichero_smokeTest.sh_o_acceptanceTest.sh)
* [Creación de tests] (#Creacin_de_tests)
* [Ejecución de tests] (#Ejecucin_de_tests)

# Agregar librería

Esta librería tiene que ser agregada a la raíz del repositorio, descargándosela
de [aquí](http://develenv.googlecode.com/svn/trunk/develenv/libtest.sh)

Dar permisos de ejecución

```
chmod u+x libtest.sh
```

# Construir el fichero smokeTest.sh o acceptanceTest.sh

El fichero inicial de tests tiene la estructura siguiente:

```
#!/bin/bash

source $(dirname $(readlink -f $0))/libtest.sh
main $*
exit $?

##################### DEPLOYMENT TABLE ############################
#--------------+--------------------------------------------------------------
# Enviroment   | URL 
#--------------+--------------------------------------------------------------
int            | http://int-develenv-01.hi.inet
qa             | http://qa-develenv-01.aislada.hi.inet
```

En el script anterior falta por configurar:
### Deployment table 
Esta tabla describe qué url se invocará en función del entorno donde se vayan
a lanzar los tests.

# Creación de tests

Una vez configurada la deployment table en el script anterior es necesario incluir
los tests a ejecutar. Para ello se necesita añadir una función en el scrpit anterior
por cada tests que se quiera invocar. El nombre de la función ha de comenzar por
el tipo de tests que estamos lanzando, es decir, si hemos creado el script 
**smokeTest.sh** el nombre de la función debe comenzar por **smokeTest**.

```
#return 0 if "$URL_SERVER/docs/index.html" http status code is 200 
function smokeTestIndex(){
   httpOK "$URL_SERVER/docs/index.html"
   return $?
}

function smokeTestJenkins(){
   httpOK "$URL_SERVER/jenkins"
   return $?
}
function smokeTestSonar(){
   httpOK "$URL_SERVER/sonar"
   return $?
}
function smokeTestNexus(){
   httpOK "$URL_SERVER/nexus"
   return $?
}
function smokeTestSeleniumGrid(){
   httpOK "$URL_SERVER/grid/console"
   return $?
}
```
# Ejecución de tests

Si la invocación de este script se hace desde una shell de usuario y no se pasa
ninguna *deploymentTable* utilizará la que venga definida en el mismo script. En
cambio si la ejecución es desde la pipeline, se utilizará la tabla, que se 
define en la configuración del job de jenkins que invoca a este script.

### Ejemplo:
```
./smokeTest.sh -e int 
```

Funciones librería
------------------
Para la realización de los tests se han definido una serie de funciones estandar.
No contemplan todos los casos, pero sirven como ejemplo para realizar otras
funciones.

Todas estas funciones puede utilizar la variable URL_SERVER, que contiene el
valor de la url para acceder al entorno que se esté probando.

#httpOk
Informa si una url es accesible.Devuelve 0 si el http status code es 200

```
Parámetros de Entrada: path con el fichero de tests
Valor de salida: 0 si la ejecución de todos los tests ha sido correcto

```
Ejemplo

```
 httpOK "http://ironman.hi.inet/jenkins"
```

#jmeterExecution
Lanza JMeter, contra una determinada máquina.

```
Parámetros de Entrada: path con el fichero de tests
Valor de salida: 0 si la ejecución de todos los tests ha sido correcto
```
Ejemplo

```
jmeterExecution \
      "$(dirname $(readlink -f $0))/src/test/resources/develenv.jmx" \
      "$URL_SERVER"
```

#seleniumTest
Ejecuta los tests de selenium utilizando maven

```
Parámetros de Entrada: navegador contra el que se lanzan los tests
Valor de salida: 0 si la ejecución de todos los tests ha sido correcto
```

Ejemplo

```
seleniumTest firefox
```
#soapui

