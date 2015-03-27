#!/bin/bash
source $(readlink -f $0)/bin/setEnv.sh
externalHost="oriente.hi.inet"
remoteAccessDir=//${externalHost}/artifacts
mountDir=/mnt/$PROJECT_NAME/repos/rpms
function help(){
   _message "

Usage:
   $0  <password> <externalDir>
Example:
   $0  myPassword /enabling/tdaf/infra/udo
    "
}

function isMounted(){
   grep "^\/\/${externalHost}\/artifacts" /etc/mtab
}

function mountFS(){
   if [ "$(grep "^\/\/${externalHost}\/artifacts" /etc/mtab)" != "" ]; then
      _log "[WARNING] Mounted"
   fi

   local password=$1
   local externalDir=$2
   if [ "$(grep "^\/\/${externalHost}\/artifacts" /etc/fstab)" == "" ]; then
      mkdir -p ${mountDir}
      chown -R $(id -g $PROJECT_USER):$(id -u $PROJECT_USER) ${mountDir}
      echo "${remoteAccessDir} ${mountDir} cifs rw,username=contint,password=${password},domain=hi,gid=$(id -g $PROJECT_USER),uid=$(id -u $PROJECT_USER),nobrl     0           0" >> /etc/fstab
   fi
   mount -a
   if [ "$?" == "0" ]; then
      _log "[INFO] Mounted $remoteAccessDir in $mountDir"
      moveRepos $2
   else
      _log "[ERROR] Imposible mount $remoteAccessDir in $mountDir"
      sed -i s:"${remoteAccessDir}.*":"":g /etc/fstab
   fi
} 

function moveRepos(){
   local externalDir=$1
   if ! [ -d ${mountDir}/${externalDir} ]; then
      _log "[INFO] Copying the original rpms to ${mountDir}/${externalDir}/"
      mkdir -p ${mountDir}/${externalDir}
      cd ${mountDir}/${externalDir}/
      cp -R /var/${PROJECT_NAME}/repositories/rpms/* .
      cd -
      # Movemos el directorio con los rpms ya que este está montado
      local mountRepoDir=/var/${PROJECT_NAME}/repositories/rpms
      mv $mountRepoDir ${mountRepoDir}Unmounted
      [[ -L $mountRepoDir ]] && unlink ${mountRepoDir}
      ln -s ${mountDir}/${externalDir}/ ${mountRepoDir}
   fi
}

function checkUser(){
   local userExecution=$(id -un)
   if [ "$userExecution" != "root" -a "$userExecution" != "$PROJECT_USER" ]; then
      _log "[ERROR] Only root or $PROJECT_USER can be execute this script"
      exit 1
   fi
}
if [ "$#" != 2 ]; then
   _log "[ERROR] Number of parameters is incorrect"
   help
   exit 1
fi
checkUser
installationIn${distribution}
isMounted
if [ $? == 0 ]; then
   _log "[WARNING] $remoteAccessDir is already mounted in $mountDir"
   exit 1
fi
$INSTALL_PACKAGE cifs-utils -y
mountFS $*

