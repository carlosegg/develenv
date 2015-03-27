#!/bin/bash


currentDir(){
   DIR=`readlink -f "$0"`
   DIR=`dirname "$DIR"`
}
noDevelenvEnviroment(){
   SCRIPT_LOG_METHOD_SUCESS=echo
   SCRIPT_LOG_METHOD_DAEMON=echo
}

isJavaInstalled(){
   set +u

   TMP_JAVA_HOME=`which java`
   if [ -n "$TMP_JAVA_HOME" ]; then
     JAVA_BIN=`dirname $TMP_JAVA_HOME`
   fi
   if [ -z "$JAVA_HOME" ]; then
      if [ -z "$JAVA_BIN" ]; then
         echo "Introduce el path de la distribution de JAVA"
         echo -e "(i.e. /usr/lib/jvm/jdk): \c"
         read PATH_TO_JAVA
         if [ -d $PATH_TO_JAVA ]; then
            JAVA_HOME=$PATH_TO_JAVA
            JAVA_BIN=$JAVA_HOME/bin
            export JAVA_HOME
            echo -e "Desearías $JAVA_HOME/bin en el PATH en el script de inicio de sesión? (S/n): \c"
            read ANSWER_JAVA
            case $ANSWER_JAVA in
               'S'|'s'|'')
                  echo "Trying to write in ~/.bashrc ..."
                  if [ -w ~/.bashrc ]; then
                     echo >> ~/.bashrc
                     echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
                     echo "export PATH=$JAVA_HOME/bin:\$PATH" >> ~/.bashrc
                     echo "Hecho."
                  else
                     echo "Fallo."
                     exit 1
                  fi
               ;;
               'N'|'n') ;;
               *)  echo "Debes teclar s  o n"
                  exit 1
            esac
            export JAVA_BIN
         else
            echo "'$PATH_TO_JAVA' no existe o no es un directorio"
            echo "Debes revisar el directorio donde tienes instalada tu distribución de java"
            exit 1
         fi
      fi
   else
      JAVA_BIN=$JAVA_HOME/bin
      export JAVA_BIN
   fi
}
manageSelenium(){
   HTTP_GRID_PORT="4445"
   if [ "$#" != 2 ]; then
      $SCRIPT_LOG_METHOD_SUCESS "Usage: manageSelenium {start|stop} {hub|node}"
      exit 1
   fi
   startOrStop=$1
   processType=$2
   if [ `id -n -u` == "develenv" ]; then                    #Se ejecuta desde dentro de develenv
      SELENIUM_HOME=${PROJECT_HOME}/platform/selenium
      seleniumDirLog=/var/log/develenv/selenium/
   else
      currentDir
      SELENIUM_HOME="$DIR/.."
      seleniumDirLog="../log/selenium/"
   fi
   seleniumLog="$seleniumDirLog/selenium-$processType.log"
   seleniumPid="$seleniumDirLog/selenium-$processType.pid"
   seleniumMessage=$processType
   echo $startOrStop
   case $startOrStop in
       start)
         $SCRIPT_LOG_METHOD_DAEMON "Starting ${seleniumMessage}"
         mkdir -p "${seleniumDirLog}"
         if [ ! -z "${seleniumPid}" ]; then
            if [ -f "${seleniumPid}" ]; then
               if [ -s "${seleniumPid}" ]; then
                  echo "Existing PID file found during start."
                  if [ -r "${seleniumPid}" ]; then
                     PID=`cat "${seleniumPid}"`
                     ps -p $PID >/dev/null 2>&1
                     if [ $? -eq 0 ] ; then
                        echo "${seleniumMessage} appears to still be running with PID $PID."
                        exit 0
                     else
                        echo "Removing/clearing stale PID file."
                        rm -f "${seleniumPid}" >/dev/null 2>&1
                        if [ $? != 0 ]; then
                           if [ -w "${seleniumPid}" ]; then
                              cat /dev/null > "${seleniumPid}"
                           else
                              echo "Unable to remove or clear stale PID file. Start aborted."
                              exit 1
                           fi
                        fi
                     fi
                  else
                     echo "Unable to read PID file. Start aborted."
                     exit 1
                  fi
               else
                  rm -f "${seleniumPid}" >/dev/null 2>&1
                  if [ $? != 0 ]; then
                     if [ ! -w "${seleniumPid}" ]; then
                        echo "Unable to remove or write to empty PID file. Start aborted."
                        exit 1
                     fi
                  fi
               fi
            fi
         fi
         $SCRIPT_LOG_METHOD_DAEMON "Starting ${seleniumMessage}"
         if [ $processType == "hub" ]; then
            java -jar "$SELENIUM_HOME/selenium-server-standalone.jar" -role hub -port ${HTTP_GRID_PORT} >>  "${seleniumLog}" 2>&1 &
         else
            # Si se ejecuta con el usuario develenv conservamos el puerto 5556, con el resto de usuarios 5557.
            # Permitimos que se levanten mas nodos en la máquina donde se ejecute develenv
            if [ `id -un` == "develenv" ]; then
               node_client_port=5556
            else
               node_client_port=5557
            fi
            java -jar "$SELENIUM_HOME/selenium-server-standalone.jar" -role webdriver \
                 -hub ${URL_GRID}/register -port $node_client_port \
                 $SELENIUM_BROWSERS \
                 -maxSession 3 >> ${seleniumLog} 2>&1 &
         fi
         if [ ! -z "${seleniumPid}" ]; then
            echo $! > "${seleniumPid}"
            sleep 1
            if [ ! -z "`ps -ef|grep $(cat ${seleniumPid})|grep -v grep`" ]; then
               $SCRIPT_LOG_METHOD_SUCESS "${seleniumMessage} has been initialized. The log is in ${seleniumLog}"
            else
               echo Error in initialization node initialization. Review the log in ${seleniumLog}
               echo 1   
            fi
         fi
      ;;
      stop)
         $SCRIPT_LOG_METHOD_DAEMON "Stopping ${seleniumMessage}"
         if [ ! -z "${seleniumPid}" ]; then
            if [ -f "${seleniumPid}" ]; then
               if [ -s "${seleniumPid}" ]; then
                  kill -9 `cat "${seleniumPid}"` >/dev/null 2>&1
                  if [ $? -gt 0 ]; then
                     echo "PID file found but no matching process was found. Stop aborted."
                     exit 1
                  fi
               else
                  echo "PID file is empty and has been ignored."
               fi
            else
               echo "${seleniumPid} was set but the specified file does not exist. Is ${seleniumMessage} running? Stop aborted."
               exit 1
            fi
        fi
      ;;
      restart)
         $SCRIPT_LOG_METHOD_DAEMON "Restarting ${seleniumMessage}"
         $0 stop
         $0 start
      ;;
      *)
         $SCRIPT_LOG_METHOD_SUCESS "Usage: $0 {start|stop|restart}"
         exit 1
         ;;
   esac
}
isJavaInstalled
if [ `id -u` == "0" ]; then
 echo "Root no puede ejecutar $0"
 exit 1
fi
