#!/bin/sh
if [ -z $PROJECT_HOME ]; then
   . $(dirname $(readlink $0))/setEnv.sh
else
   . $PROJECT_HOME/bin/setEnv.sh
fi

SHUTDOWNFILE=/var/tmp/shutdonwOutput
pidfile=$PROJECT_HOME/$PROJECT_NAME.pid
killProject(){
  if [ -f "$pidfile" ]; then
    ISALIVE=`cat $pidfile`
    if [ "$ISALIVE" != "" ]; then
      kill -9 $ISALIVE 2>/dev/null
      rm -Rf $pidfile
    fi
  fi
  ISALIVE=`ps -ef|grep "org.apache.catalina.startup.Bootstrap"|grep -v grep|\
           grep "$PROJECT_USER"|cut -d' ' -f2`
  if [ "$ISALIVE" != "" ]; then
    kill -9 $ISALIVE 2>/dev/null
  fi
}

_log "[INFO] Shuting down Tomcat..."
$PROJECT_HOME/platform/tomcat/bin/shutdown.sh > $SHUTDOWNFILE
grep "^Tomcat did not stop in time" $SHUTDOWNFILE >/dev/null
[ $? -eq 0 ] && killProject
rm $SHUTDOWNFILE
