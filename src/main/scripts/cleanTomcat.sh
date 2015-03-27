#!/bin/bash
DIR=$(dirname $(readlink -f $0))
source ${DIR}/setEnv.sh
echo $PROJECT_NAME
function clean(){
   _log "[INFO] Eliminando ficheros temporales de tomcat"
   rm -Rf $PROJECT_HOME/platform/tomcat/logs/* $PROJECT_HOME/platform/tomcat/temp/* \
   $PROJECT_HOME/platform/tomcat/work/* $PROJECT_HOME/platform/conf/Catalina
}
source ${DIR}/cleanTool.sh
cleanTool

