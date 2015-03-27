#!/bin/sh
if [ -z $PROJECT_HOME ]; then
 . $(dirname $(readlink -f $0))/setEnv.sh
else
 . $PROJECT_HOME/bin/setEnv.sh
fi

_log "\n
+++++++++++++++++++++++++++++++
   Stopping ${project.artifactId}
+++++++++++++++++++++++++++++++"

su - $PROJECT_USER -c "$PROJECT_HOME/bin/shutdownTomcat.sh"
$PROJECT_HOME/platform/selenium/bin/selenium.sh stop
#Remove Xvfb
if [ -f /tmp/.X20-lock ]; then
  kill -15 `cat /tmp/.X20-lock`
  rm -Rf /tmp/.X20-lock
fi

# Matando todos los procesos java presentes para el usuario develenv
if [ "`grep "^$PROJECT_USER\:" /etc/passwd`" != "" ]; then
  su $PROJECT_USER -c "killall -9 java 2>/dev/null"
fi
