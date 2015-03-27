#!/bin/bash
if [ -z $PROJECT_HOME ]; then
 . $(dirname $(dirname $(dirname $(dirname $(readlink -f $0)))))/bin/setEnv.sh
else
 . $PROJECT_HOME/bin/setEnv.sh
fi

currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}
if [ `id -u` == "0" ]; then
   currentDir
   su - $PROJECT_USER -c "$DIR/hub.sh $1"
   su - $PROJECT_USER -c "$DIR/node-localhost.sh $1"
   sleep 2
   service $APACHE2_SCRIPT_INIT restart
else
   _log "[ERROR] Solo root puede ejecutar $0"
   exit 1
fi

