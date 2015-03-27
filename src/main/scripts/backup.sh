#!/bin/bash
logCommands=""
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}
addResource(){
   resource=$1
   pushd .
   cd $PROJECT_HOME
   i=1
   TOKEN="0"
   while [ "$TOKEN" != "" ] ; do
   TOKEN=`echo $resource|cut -f$i -d'/'`
   if [ "$TOKEN" != "" ]; then          
      svn add --non-recursive $TOKEN 2>/dev/null
      if [ -d "$TOKEN" ]; then
         cd $TOKEN
      fi
      (( i ++ ))
   fi
   done
   popd >/dev/null

}


backupDir(){
    dirBackup=$1
    command=$2
    addCommand=$3
    CURRENT_DIR=$PWD
    pushd . >/dev/null
    cd $dirBackup
    for i in `$2`; do
   addResource $dirBackup/$i$3
    done
    #Eliminando del svn archivos obsoletos
    svn st 2>/dev/null
    if [ "$?" != "0" ]; then
        for i in `svn st|grep "\!   "|cut -d' ' -f8`; do
           $logCommands svn del $i
        done
    fi
    popd >/dev/null
}


hudsonBackup(){
    pushd . >/dev/null
    cd ../
    backupDir "app/hudson/jobs" "ls" "/config.xml"
    backupDir "app/hudson/plugins" "ls *.hpi" ""
    backupDir "app/hudson/scripts" "ls" ""
    backupDir "app/hudson/users" "ls" "/config.xml"
    backupDir "app/hudson" "ls *.xml" ""
    backupDir "app/hudson" "ls secret.key" ""
    backupDir "app/hudson" "ls .owner" ""
    pushd . >/dev/null
    cd $PROJECT_HOME
    $logCommands svn ci -m "[BACKUP] Automatic hudson backup"
    popd >/dev/null
}
currentDir
. $DIR/setEnv.sh
hudsonBackup

