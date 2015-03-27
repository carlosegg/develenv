#!/bin/sh
### BEGIN INIT INFO
# Provides:          $PROJECT_NAME-$PROJECT_VERSION
# Short-Description: Start/stop
# chkconfig: 2345 86 14
# description: Start, stops $PROJECT_NAME-$PROJECT_VERSION
### END INIT INFO
#
# ${project.artifactId}       This init.d script is used to start ${project.artifactId}.


ENV="env -i LANG=C PATH=/usr/local/bin:/usr/bin:/bin"
DEVELENV_HOME=$(dirname $(dirname $(readlink -f $0)))
. $DEVELENV_HOME/bin/setEnv.sh

$INIT_FUNCTIONS

case $1 in
    start)
        $SCRIPT_LOG_METHOD_DAEMON "Starting $PROJECT_NAME-$PROJECT_VERSION"
        $DEVELENV_HOME/bin/sumarize.sh start
        $DEVELENV_HOME/bin/startupAll.sh
    ;;
    stop)
        $SCRIPT_LOG_METHOD_DAEMON "Stopping $PROJECT_NAME-$PROJECT_VERSION"
        $DEVELENV_HOME/bin/shutdownAll.sh
    ;;
    restart)
        $SCRIPT_LOG_METHOD_DAEMON "Restarting $PROJECT_NAME-$PROJECT_VERSION"
        $SCRIPT_LOG_METHOD_DAEMON "Stopping $PROJECT_NAME-$PROJECT_VERSION"
        $DEVELENV_HOME/bin/shutdownAll.sh
        $SCRIPT_LOG_METHOD_DAEMON "Starting $PROJECT_NAME-$PROJECT_VERSION"
        $DEVELENV_HOME/bin/startupAll.sh
    ;;
    status)
         pidfile=$DEVELENV_HOME/$PROJECT_NAME.pid
         if [ -f $pidfile ]; then
            PID=$(cat $pidfile)
            exists=$(ps -ef | grep java | awk '{ print $2 }' | grep $PID)
            [ "$exists" != "" ] && _log "[INFO] $PROJECT_NAME is running" && exit 0 ||\
            rm -f $pidfile
         fi
         _log "[INFO] $PROJECT_NAME is stopped"
    ;;
    *)
        _message "Usage: /etc/init.d/$0 {start|stop|restart|status}"
        exit 1
    ;;
esac
