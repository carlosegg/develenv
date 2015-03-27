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

currentDir
. $DIR/setEnv.sh
manageSelenium $1 hub

