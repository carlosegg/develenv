#!/bin/bash
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}

function getParameter(){
   param="$1"
   shift
   count=1
   value=""
   until [ "$*" == "" ] 
   do
      parameter=$1
      shift
      count=`expr $count + 1`
      if [ "$value" == "" ]; then
         if [ "${parameter:0:${#param}}" == "${param}" ]; then
            value=${parameter:${#param}}
         fi
      fi
   done
   echo $value
}

function isRPMinstallation(){
   [ "$rpmPhase" != "" ] && yumInstallation="true" || yumInstallation="false"
   _log "[INFO] Yum Installation: $yumInstallation $rpmPhase"
}

function getRpmPhase(){
   rpmPhase=$(getParameter "-DrpmPhase=" $*)
}

function removeProject(){
   # Files to be deleted with yum update or rpm -U
   existRepo=$(ls $PROJECT_HOME/app/repositories/rpms/noarch/ss-develenv-repo-*.rpm* 2>/dev/null)
   if  [ ! -z "$existRepo" ]; then
   	chattr -i $existRepo
   fi
   _log "[INFO] Uninstall develenv configuration for apache"
   rm -Rf /etc/httpd/conf.d/apache /etc/${PROJECT_NAME}/apache
   if [ -z "$(grep "Red Hat" /proc/version)" ]; then
      _log "[INFO] Removing apache configuration for Ubuntu"
      rm -Rf /etc/apache2/conf.d/${APPNAME}.conf
      rm -Rf /etc/apache2/conf.d/${APPNAME}.conf.d
      rm -Rf /etc/httpd/
   fi
   # Deleting other needed dirs
   rm -Rf /var/${PROJECT_NAME}/repositories \
          /var/${PROJECT_NAME}/sites /var/${PROJECT_NAME}/sonar/extensions/deprecated/ \
          /var/${PROJECT_NAME}/sonar/temp /var/${PROJECT_NAME}/sonar/logs \
          /var/tmp/${PROJECT_NAME}/tomcat/temp /var/tmp/${PROJECT_NAME}/tomcat/work
   #Disabling service even it don't exists
   _log "[INFO] Disabling $PROJECT_NAME service"
   $BOOT_COMMAND_UNDO 2>/dev/null
   # Only delete this files if we are removing develenv manually"
   if [ "$yumInstallation" != "true" ]; then
      _log "[INFO] This is an uninstall.sh manual execution."
      rm -Rf ${APACHE_CONF_DIR}/${PROJECT_NAME}*.conf \
          ${APACHE_CONF_DIR}/conf.d/${PROJECT_NAME}.conf.d \
          /etc/httpd/conf.d/${PROJECT_NAME}.conf.d
      rm -Rf /home/${PROJECT_USER}
      rm -Rf /var/${PROJECT_NAME}
      rm -Rf /var/tmp/${PROJECT_NAME}
      rm -Rf /var/log/${PROJECT_NAME}
      rm -Rf /etc/${PROJECT_NAME}
      rm -Rf /etc/init.d/${PROJECT_NAME}
      rm -Rf /opt/${ORG_ACRONYM}/${PROJECT_NAME}
      rm -Rf /etc/yum/repos.d/${ORG_ACRONYM}-thirdparty-${APPNAME}*.*
      userdel -f -r ${PROJECT_USER} 2>/dev/null
   fi
   # Reload apache after remove directives
   if [ -f "/etc/init.d/${APACHE2_SCRIPT_INIT}" ]; then
      service ${APACHE2_SCRIPT_INIT} reload
   fi
}
currentDir
. $DIR/setEnv.sh
getRpmPhase $*
isRPMinstallation
installationIn${distribution}
service $PROJECT_NAME stop 2>/dev/null
removeProject