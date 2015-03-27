#!/bin/sh
if [ -z $PROJECT_HOME ]; then
 . $(dirname $(readlink $0))/setEnv.sh
else
 . $PROJECT_HOME/bin/setEnv.sh
fi
_log "[INFO] Starting Tomcat..."
OLD_DIR=$PWD
cd $PROJECT_HOME/platform/tomcat/bin
CATALINA_BASE=""
CATALINA_HOME=""
TOMCAT_HOME=""
pidfile=$PROJECT_HOME/$PROJECT_NAME.pid
if [ -f $pidfile ]; then
   PID=$(cat $pidfile)
   exists=$(ps -ef|grep java|awk '{ print $2 }' | grep $PID)
   if [ "$exists" != "" ]; then
       kill -9 $PID
   fi
   rm -Rf $pidfile
fi

./startup.sh
cd $OLD_DIR
