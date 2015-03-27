#!/bin/bash
if [ -z $PROJECT_HOME ]; then
   . $(dirname $(readlink -f $0))/setEnv.sh
else
   . $PROJECT_HOME/bin/setEnv.sh
fi
selenium="on"
_log "\n
+++++++++++++++++++++++++++++++
   Inicializando ${project.artifactId}
+++++++++++++++++++++++++++++++"
if [ -f "$PROJECT_HOME/.adminDevelenv" ]; then
   _log  "[ERROR] ${project.artifactId} isn't started because now is updating"
   exit 1
fi
su - develenv -c "Xvfb :20 -ac -screen 0 1024x768x8 2>>/var/log/develenv/X20 &"
su - develenv -c "export DISPLAY=\":20.0\";. $PROJECT_HOME/bin/setEnv.sh;$PROJECT_HOME/bin/startupTomcat.sh"
if [ "$selenium" == "on" ]; then
   $PROJECT_HOME/platform/selenium/bin/selenium.sh start
fi
#Para el caso de que se utilice un proxy para el acceso a internet comentar la línea anterior y configurar el proxy en la siguiente linea.
#su - develenv -c "export http_proxy=http://carlosg:mipassword@proxy.softwaresano.com;export DISPLAY=":20.0";$PROJECT_HOME/bin/startupTomcat.sh"
