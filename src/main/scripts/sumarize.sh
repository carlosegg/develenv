#!/bin/bash

function getHostname(){
        IP=`LANG=C /sbin/ifconfig | grep "inet addr" | grep "Bcast" | awk '{ print $2 }' | awk 'BEGIN { FS=":" } { print $2 }' | awk ' BEGIN { FS="." } { print $1 "." $2 "." $3 "." $4 }'`
    MAC_ADDRESSES=`LANG=C /sbin/ifconfig -a|grep HWaddr|awk '{ print $5 }'`
        if [ "$IP" == "" ]; then
            echo -e "\nNo hay conexión de red. Introduce el nombre o la ip de la máquina: \c"
            read HOST
        else
          local j=0
          for i in $IP;
             do
              #Averiguamos si alguna IP tiene asignada nombre de red
          j=$(($j +1 ));
              temp=`LANG=C nslookup $i|grep "name = "|cut -d= -f2| sed 's/.//' | sed 's/.$//'`
              if [ "$temp" != "" ]; then
                 HOST=$temp
                 INTERNALIP=$i
         MAC_ADDRESS=`echo $MAC_ADDRESSES|cut -d' ' -f$j`
              fi
          done
          if [ "$HOST" == "" ]; then
             # Probablemente sea una conexión wifi, y no tenga asignada un nombre en el DNS
             HOST=`hostname`
             INTERNALIP=`echo $IP|cut -d' ' -f1`
         MAC_ADDRESS=`echo $MAC_ADDRESSES|cut -d' ' -f1`
             # Si no hay un nombre de hosts asignado
         if [ "$HOST" == "" ];then
                # Nos quedamos con la primera IP
            HOST=$INTERNALIP
         fi
          fi
        fi
}

function doSumarize(){
    sumarizeFile=/tmp/`date +%Y%m%d%H%M%S`.log
    LANG=C
    getHostname
    echo develenv.version=${PROJECT_VERSION} > ${sumarizeFile}
    wget http://www.softwaresano.com/public/ip.php -O externalIP 2>/dev/null
    externalIP=`cat externalIP|cut -d':' -f1`
    externalHostName=`cat externalIP|cut -d':' -f3`
    rm externalIP
    echo develenv.externalIP=${externalIP} >> ${sumarizeFile}
    echo develenv.externalIP.hostname=$externalHostName >> ${sumarizeFile}
    echo develenv.ip=$INTERNALIP >> ${sumarizeFile}
    echo develenv.hostname=$HOST >> ${sumarizeFile}
    echo develenv.macAddress=$MAC_ADDRESS >> ${sumarizeFile}
    echo develenv.linux.version=`cat /proc/version` >> ${sumarizeFile}
    echo develenv.linux.kernel=`uname -a` >> ${sumarizeFile}
    echo develenv.linux.description=`cat /etc/issue|head -n1` >> ${sumarizeFile}
    if  [ "$JAVA_HOME" != "" ]; then
        $JAVA_HOME/bin/java -version 2>javaVersion
            echo develenv.java.version=`cat javaVersion` >> ${sumarizeFile}
        rm javaVersion
    fi
    $LOCAL_SOFTWARESANO;wget --post-file=${sumarizeFile} http://www.softwaresano.com/public/postFile.php -O deleteme 2>/dev/null
    rm -Rf deleteme
    rm -Rf ${sumarizeFile}
}

if [ -z $PROJECT_HOME ]; then
   . $(dirname $(readlink -f $0))/setEnv.sh
else
   . $PROJECT_HOME/bin/setEnv.sh
fi

if [ "$1" == "start" ]; then
   if [ -f "$FIRST_EXECUTION_FILE" ]; then
      doSumarize
      rm -Rf "$FIRST_EXECUTION_FILE"
   fi
else
   doSumarize
fi

