#!/bin/bash
set +e
if [ "$DEBUG_DEVELENV" == "TRUE" ] || [ -f /tmp/DEBUG_DEVELENV ]; then
   set -x
else
   set +x
fi

function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}

function help(){
   _message "Uso: $0 -Dadmnistrator.id=[administrator] -Dpassword=[password] [-Dmultienviroment] [-Dorg=[organization]] [--help]
Configuración paquete $PROJECT_NAME


OPCIONES:
   -Dadministrator.id Usuario administrador para jenkins(http://$HOSTNAME/jenkins)  y para la administración de $PROJECT_NAME(http://$HOSTNAME/admin)
   -Dpassword Password para la administración de $PROJECT_NAME(http://$HOSTNAME/admin)
   -Dorg=[url] Url con los parámetros de configuración de la organización donde se instala $PROJECT_NAME
      Ej: -Dorg=http://develenv.googlecode.com/svn/${URL_DEVELENV_REPO}/src/main/filters/softwaresano.properties Configura $PROJECT_NAME con los parámetros de Softwaresano
   --help: Esta pantalla de ayuda.

EJEMPLO:
    $0 -Dadministrator.id=$PROJECT_NAME -Dpassword=$PROJECT_NAME

Más información en http://develenv.softwaresano.com/docs/installation.html"
}


function installPackages(){
   . ./setEnv.sh
   [ "$yumInstallation" == "true" ] && return 0
   installationIn${distribution}
   echo $CONFIGURE_REPOS >configureRepos.sh
   chmod 755 configureRepos.sh
   ./configureRepos.sh
   rm -Rf configureRepos.sh
   $INSTALL_PACKAGE $NEW_PACKAGES -y
   if [ "$?" != 0 ]; then
      _log "[ERROR] No se pueden instalar los paquetes ${NEW_PACKAGES}. Puede que no haya conexión a internet o quizás haya que configurar el proxy para acceder a internet."
      exit 1
   fi
   $APACHE2_MODULES
}
# No todas las distribuciones añaden el hostname al /etc/hosts.  Para evitar problemas se añade
function addHostnameToEtcHost(){
       #Si no se ha añadido el hostname al /etc/hosts se añade
       if ! [ -z "$HOSTNAME" ]; then
          isAddedHostname=$(grep -w "\( |\t\)*$HOSTNAME\( |\t|$\)*" /etc/hosts)
          if [ -z "$isAddedHostname" ]; then
             echo -e "127.0.0.1\t$HOSTNAME" >> /etc/hosts
          fi
       fi
}
function installRedHat(){
      installationInRedHat
      if [ -f "/etc/sysconfig/iptables" ]; then
         isRHFirewall=$(grep "\-A RH-Firewall " /etc/sysconfig/iptables)
         if ! [ -z $isRHFirewall ]; then
            ENABLED_HTTP=$(grep "\-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT" /etc/sysconfig/iptables) 
            if [ "$ENABLED_HTTP" == "" ]; then
               sed -i s:"-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT":"-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT\n-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT":g /etc/sysconfig/iptables
            fi
         else
            ENABLED_HTTP=$(grep "\-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT" /etc/sysconfig/iptables)
            if [ "$ENABLED_HTTP" == "" ]; then
               sed -i s:" --dport 22 -j ACCEPT":" --dport 22 -j ACCEPT\n-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT":g /etc/sysconfig/iptables
            fi
         fi
         service iptables restart
      fi
      service mysqld restart
      chkconfig httpd on
      chkconfig mysqld on
      # Para que funciona el firefox sin X
      ! [ -f "/var/lib/dbus/machine-id" ] && dbus-uuidgen --ensure
}

function installDebian(){
   installationInDebian
   service apache2 restart
   JAVA_HOME=${java_dir}

   if [ `uname -m` == "x86_64" ]; then
      PACKAGES_INSTALLATION=""
   else
      PACKAGES_INSTALLATION=""
   fi
   if [ "$PACKAGES_INSTALLATION" != "" ]; then
      wget $PACKAGES_INSTALLATION
      dpkg -i *.deb
      rm -Rf *.deb
      apt-get clean
   fi
}

function configureSelinux(){
   #Configure selinux
   _log "[Start] Selinux configuration"
   #http://wiki.centos.org/HowTos/SELinux (5.1) Relabeling files
   SELinux=$(sestatus |grep "SELinux status:"|cut -d':' -f2|awk '{print $1}')
   _log "[INFO] Selinux: $SELinux"
   if [ "$SELinux" == "enabled" ]; then
      # Changing security context of files (SELinux)
      _log "[INFO] Enabling http access in selinux"
      chcon -Rv --type=httpd_sys_content_t /var/$PROJECT_NAME/
      chcon -Rv --type=httpd_sys_content_t /var/log/$PROJECT_NAME
      chcon -Rv --type=httpd_sys_content_t /etc/$PROJECT_NAME
      chcon -Rv --type=ssh_home_t /home/$PROJECT_NAME/.ssh
      #Redirect apache tomcat
      /usr/sbin/setsebool -P httpd_can_network_connect 1
   fi
}

function postInstallRedHat(){
   #Permitimos la redirección apache a tomcat
   _log "[Start] RedHat PostInstallation"
   configureSelinux
   chkconfig --add develenv
   _log "[Finish] RedHat PostInstallation"
}

function postInstallDebian(){
   #nothing
   _log "[Start] Debian PostInstallation"
   rm -Rf /etc/yum.repos.d
   _log "[Finish] Debian PostInstallation"
}

function linksToConfigurations(){
   local toolName="$1"
   local toolDir="$2"
   su $PROJECT_USER -c "mkdir -p `dirname \"$toolDir\"` && cd `dirname \"$toolDir\"` && rm -Rf `basename \"$toolDir\"` && ln -s /etc/$APPNAME/$toolName/ `basename \"$toolDir\"`"
}

function linksToEtcJenkins(){
   su $PROJECT_USER -c "mkdir -p /etc/$APPNAME/jenkins"
   for jenkinsConfFile in `find "$PROJECT_HOME/app/jenkins" -maxdepth 1 -name "$1"`; do
      su $PROJECT_USER -c "cd /etc/$APPNAME/jenkins && rm -Rf `basename $jenkinsConfFile` && ln -s $jenkinsConfFile"
   done;
}

#Create Links to $targetLink directory
function linkFiles(){
   local targetLink=$1
   local resources=$2
   local currentDir=$PWD
   cd $targetLink
   if [ "$resources" != "" ]; then
      for resource in $resources; do
         linkResource="/$targetLink/$(echo $resource|sed s:"^\./":"":g)"
         # Delete if link is broken
         rm -Rf $(find -L  $linkResource -type l 2>/dev/null)
         if [ ! -f "$linkResource" ]; then
            mkdir -p $(dirname $linkResource) 
            ln -s $currentDir/$resource $linkResource
         fi
      done;
   fi
}

#Configure deployment pipeline links
function configure_dp(){
   local pipeline_home=/home/$APPNAME/app/plugins/pipeline_plugin/
   # Si la instalación no ha sido via rpms entonces la dp está en $pipeline_home
   if [ ! -f "$pipeline_home/dp_package.sh" ]; then
      return;
   fi
   _log "[INFO] Configure deployment pipeline links"
   pushd .>/dev/null
   cd $pipeline_home
   resources=$(find . -maxdepth 1 -name '*.sh')
   linkFiles /usr/bin/ "$resources"
   cd /usr/bin
   rm -f pipeline.sh
   ln -s $pipeline_home/admin/pipeline.sh
   popd >/dev/null
}


function configureLinks(){
   su $PROJECT_USER -c "cd /opt/${ORG_ACRONYM}/$APPNAME/bin && rm -Rf setEnv.sh && ln -s /etc/$APPNAME/setEnv.sh"
   su $PROJECT_USER -c "cd $PROJECT_HOME && rm -Rf bin && ln -s /opt/${ORG_ACRONYM}/$APPNAME/bin && rm -Rf platform && ln -s /opt/${ORG_ACRONYM}/$APPNAME/platform && rm -Rf README && ln -s /opt/${ORG_ACRONYM}/$APPNAME/README && rm -Rf RELEASE_NOTES && ln -s /opt/${ORG_ACRONYM}/$APPNAME/RELEASE_NOTES && rm -Rf LICENSE && ln -s /opt/${ORG_ACRONYM}/$APPNAME/LICENSE && rm -Rf install && ln -s /opt/${ORG_ACRONYM}/$APPNAME/install"
   su $PROJECT_USER -c "cd $PROJECT_HOME && rm -Rf docs && ln -s /var/$APPNAME/docs"
   su $PROJECT_USER -c "mkdir -p $PROJECT_HOME/app/ && cd $PROJECT_HOME/app/ && rm -Rf $SITES && ln -s /var/$APPNAME/$SITES $SITES"
   su $PROJECT_USER -c "cd $PROJECT_HOME/app/ && rm -Rf repositories && ln -s /var/$APPNAME/repositories repositories"
   su $PROJECT_USER -c "cd $PROJECT_HOME/app/ && rm -Rf maven && ln -s /var/$APPNAME/maven maven"
   su $PROJECT_USER -c "cd $PROJECT_HOME/platform/tomcat && rm -Rf logs && ln -s /var/log/$APPNAME/tomcat logs"
   linksToConfigurations "tomcat" "$PROJECT_HOME/platform/tomcat/conf/"
   linksToConfigurations "nexus" "$PROJECT_HOME/sonatype-work/nexus/conf/"
   su $PROJECT_USER -c "cd /var/$APPNAME/nexus/ && mkdir -p indexer proxy storage timeline"
   su $PROJECT_USER -c "cd $PROJECT_HOME/sonatype-work/nexus && rm -Rf indexer && ln -s /var/$APPNAME/nexus/indexer && rm -Rf proxy  && ln -s /var/$APPNAME/nexus/proxy && rm -Rf storage && ln -s /var/$APPNAME/nexus/storage && rm -Rf timeline && ln -s /var/$APPNAME/nexus/timeline && rm -Rf plugin-repository && ln -s /var/$APPNAME/nexus/plugin-repository"
   su $PROJECT_USER -c "cd $PROJECT_HOME/sonatype-work/nexus && mkdir -p /var/log/$APPNAME/nexus && rm -Rf logs && ln -s /var/log/$APPNAME/nexus logs"
   su $PROJECT_USER -c "mkdir -p $PROJECT_HOME/app/nexus/ && cd $PROJECT_HOME/app/nexus/ && rm -Rf sonatype-work && ln -s $PROJECT_HOME/sonatype-work"
   ## Start of Jenkins links conf
   ## Hudson to Jenkins
   su $PROJECT_USER -c "mkdir -p $PROJECT_HOME/app/jenkins && cd $PROJECT_HOME/app/ && rm -Rf hudson && ln -s jenkins hudson"
   ## Links to dirs (Jenkins)
   su $PROJECT_USER -c "mkdir -p /var/$APPNAME/jenkins/fingerprints /var/$APPNAME/jenkins/updates /var/$APPNAME/jenkins/userContent && cd $PROJECT_HOME/app/jenkins/ && rm -Rf fingerprints && ln -s /var/$APPNAME/jenkins/fingerprints && rm -Rf updates && ln -s /var/$APPNAME/jenkins/updates && rm -Rf userContent && ln -s  /var/$APPNAME/jenkins/userContent"
   su $PROJECT_USER -c "cd $PROJECT_HOME/app/jenkins && rm -Rf jobs && ln -s /var/$APPNAME/jenkins/jobs jobs"
   su $PROJECT_USER -c "cd $PROJECT_HOME/app/jenkins && rm -Rf plugins && ln -s /var/$APPNAME/jenkins/plugins plugins"
   su $PROJECT_USER -c "cd $PROJECT_HOME/app/jenkins && rm -Rf users && ln -s /var/$APPNAME/jenkins/users users"
   su $PROJECT_USER -c "mkdir -p /var/log/$APPNAME/jenkins && cd $PROJECT_HOME/app/jenkins/ && rm -Rf log && ln -s /var/log/$APPNAME/jenkins log"
   ### START: configuration links
   ### Jenkins' Links
   ### Doing this because Jenkins breaks the symlinks from /etc/develenv/jenkins 
   linksToEtcJenkins "*.xml"
   linksToEtcJenkins "*.conf"
   ## End of Jenkins links conf
   su $PROJECT_USER -c "rm -Rf $PROJECT_HOME/.jenkins && ln -s $PROJECT_HOME/app/jenkins/ $PROJECT_HOME/.jenkins"
   su $PROJECT_USER -c "rm -Rf $PROJECT_HOME/.hudson && ln -s $PROJECT_HOME/app/jenkins/ $PROJECT_HOME/.hudson"
   #Standalone sonar-runner 
   su $PROJECT_USER -c "
      mkdir -p /opt/ss/develenv/platform/sonar-runner/conf/ &&
      cd /opt/ss/develenv/platform/sonar-runner/conf/ &&
      rm -Rf sonar-runner.* &&
      ln -s /etc/$APPNAME/sonar-runner/sonar-runner.properties"
   su $PROJECT_USER -c "cd $PROJECT_HOME/platform/tomcat/webapps/sonar/WEB-INF/classes && rm -Rf sonar-war.properties && ln -s /etc/develenv/sonar/sonar-war.properties ."
   linksToConfigurations "sonar" "/var/$APPNAME/sonar/conf/"
   linksToConfigurations "maven" "$PROJECT_HOME/platform/maven/conf/"
   linksToConfigurations "maven2" "$PROJECT_HOME/platform/maven2/conf/"
   ### END: configuration links
   su $PROJECT_USER -c "cd $PROJECT_HOME && rm -Rf conf && ln -s /etc/$APPNAME conf"
   su $PROJECT_USER -c "mkdir -p /var/log/$APPNAME/sonar && cd /var/$APPNAME/sonar && rm -Rf logs && ln -s /var/log/$APPNAME/sonar logs"
   su $PROJECT_USER -c "mkdir -p $PROJECT_HOME/app/ && cd $PROJECT_HOME/app/ && rm -Rf sonar && ln -s /var/$APPNAME/sonar"
   su $PROJECT_USER -c "cd $PROJECT_HOME && rm -Rf logs && ln -s /var/log/$APPNAME logs"
   su $PROJECT_USER -c "cd $PROJECT_HOME/app/repositories && rm -Rf nexus && ln -s /var/$APPNAME/nexus/storage nexus"
   su $PROJECT_USER -c "mkdir -p $PROJECT_HOME/app/repositories/nexus/groups && cd $PROJECT_HOME/app/repositories/nexus/groups && rm -Rf public && ln -s /var/$APPNAME/nexus/storage/public public"
   su $PROJECT_USER -c "cd $PROJECT_HOME/app/repositories/nexus/groups && rm -Rf public-snapshots && ln -s /var/$APPNAME/nexus/storage/public-snapshots public-snapshots"
   su $PROJECT_USER -c "mkdir -p /var/$APPNAME/plugins && cd $PROJECT_HOME/app && rm -Rf plugins && ln -s /var/$APPNAME/plugins"
   # /var/develenv/temp --> /var/tmp/develenv
   su $PROJECT_USER -c "cd /var/$APPNAME/ && rm -Rf temp && ln -s /var/tmp/$APPNAME temp"
   # /home/develenv/temp --> /var/tmp/develenv
   su $PROJECT_USER -c "mkdir -p /var/tmp/$APPNAME && cd $PROJECT_HOME && rm -Rf temp && ln -s /var/tmp/$APPNAME temp"
   # Logrotate
   pushd . >/dev/null
   cd /etc/logrotate.d/ && rm -Rf $APPNAME && ln -s /etc/$APPNAME/logrotate.d/$APPNAME
   su $PROJECT_USER -c "cd /etc/logrotate.d/ && rm -Rf $APPNAME && ln -s /etc/$APPNAME/logrotate.d/$APPNAME" 
   popd >/dev/null
   # /var/tmp with write permissions for everyone
   chmod -R 777 /var/tmp
   su $PROJECT_USER -c "cd $PROJECT_HOME/platform/tomcat/ && rm -Rf temp/* && mkdir -p /var/tmp/$APPNAME/tomcat/temp && ln -s /var/tmp/$APPNAME/tomcat/temp temp"
   su $PROJECT_USER -c "cd $PROJECT_HOME/platform/tomcat/ && rm -Rf work/* && mkdir -p /var/tmp/$APPNAME/tomcat/work && ln -s /var/tmp/$APPNAME/tomcat/work work"
   # Apache
   [ -z "$(grep Red\ Hat /proc/version)" ] && pushd . >/dev/null && cd /etc/apache2/conf.d && rm -Rf $APPNAME.conf && rm -Rf ${APPNAME}.conf.d && ln -s /etc/httpd/conf.d/${APPNAME}.conf && ln -s /etc/httpd/conf.d/${APPNAME}.conf.d && popd >/dev/null
   su $PROJECT_USER -c "cd $PROJECT_HOME/conf && rm -Rf apache && ln -s /etc/httpd/conf.d/${APPNAME}.conf.d apache"
   configure_dp
}


function installDevelenvPlugins(){
   cd $PROJECT_HOME/bin
   _log "Instalando plugins de $PROJECT_HOME"
   ./installPlugin.sh python_plugin http://develenv-python-plugin.googlecode.com/files/python_plugin-20.dp
   ./installPlugin.sh php_plugin http://develenv-php-plugin.googlecode.com/files/php_plugin-12.dp
   #Cpp plugin sólo esta testeado en distribuciones debian
   if [ "$distribution" == "Debian" ]; then
      ./installPlugin.sh cpp_plugin http://develenv-cpp-plugin.googlecode.com/files/cpp_plugin-16.dp
   fi

}

function defaultInstallation(){
   _message "================================================================================
$PROJECT_NAME puede instalarse con las opciones por defecto (administrator.id=$PROJECT_NAME password=$PROJECT_NAME )
¿Deseas instalar $PROJECT_NAME con las opciones por defecto? (s/n):\c"
   read ANSWER
   case $ANSWER in
      'S'|'s'|'')
            $0 -Dadministrator.id=$PROJECT_NAME -Dpassword=$PROJECT_NAME
            exit $?
      ;;
       'N'|'n')
            exit 0
           ;;
       *)  _message "Debes teclar s ó n"
      exit 1
   esac
}


function areYouSure(){
   _message "¿Estás seguro que quieres desinstalar $PROJECT_NAME? (S/n):\c"
   read ANSWER
   case $ANSWER in
      'S'|'s'|'')
         _message "Eliminando $PROJECT_NAME-$PROJECT_VERSION"
         $DIR/uninstall.sh
      ;;
      'N'|'n')
         _message "Desinstalación $PROJECT_NAME-$PROJECT_VERSION cancelada"
         exit 2
      ;;
       *)  _message "Debes teclar s ó n"
      exit 1
   esac
}

function getHostname(){
   IP=`LANG=C /sbin/ifconfig | grep "inet addr" | grep "Bcast" | awk '{ print $2 }' | awk 'BEGIN { FS=":" } { print $2 }' | awk ' BEGIN { FS="." } { print $1 "." $2 "." $3 "." $4 }'`
   MAC_ADDRESSES=`LANG=C /sbin/ifconfig -a|grep HWaddr|awk '{ print $5 }'`
   if [ "$IP" == "" ]; then
      echo -e "\nNo hay conexión de red. Introduce el nombre o la ip de la máquina: \c"
      read HOST
   else
      local j=0
      for i in $IP; do
         #Averiguamos si alguna IP tiene asignada nombre de red
         j=$(($j +1 ));
         temp=`LANG=C nslookup $i|grep "name = "|cut -d= -f2| sed 's/.//' | sed 's/.$//'`
         if [ "$temp" != "" ]; then
            HOST=$temp
            INTERNALIP=$i
            MAC_ADDRESS=`echo $MAC_ADDRESSES|cut -d' ' -f$j`
            # Avoid problem with virtuals ips
            if [ "$(echo $temp|cut -d'.' -f1)" == "$(echo $(hostname)|cut -d'.' -f1)" ]; then
                break
            fi
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

function getOrganizationConfigurationFile(){
   if [ "$organization" != "" ]; then
     echo $organization|egrep "http://|https://:|ftp://|file://"
     wget -q $organization -O /opt/${ORG_ACRONYM}/$APPNAME/install/conf/default_organization.properties
     if [ "$?" != 0 ]; then
        _log "[ERROR] No se encuentra el fichero de configuración $organization"
        exit 1
     fi
     [ "`grep \"projectName=\" /opt/${ORG_ACRONYM}/$APPNAME/install/conf/default_organization.properties`" == "" ] && _log "[ERROR] Fichero de configuración [$organization] incorrecto" && exit 1
   fi
   profileorg="-Dorg=default_organization"
}

function getOrganization(){
   organization=$(getParameter "-Dorg=" $*)
}

function getAdministratorId(){
   administratorId=$(getParameter "-Dadministrator.id=" $*)
}

function getAdminPassword(){
   adminPassword=$(getParameter "-Dpassword=" $*)
}

function getRpmPhase(){
   rpmPhase=$(getParameter "-DrpmPhase=" $*)
}

function isRPMinstallation(){
   [ "$rpmPhase" != "" ] && yumInstallation="true" || yumInstallation="false"
}

function internetAccess(){
   # Comprobando la conexión a internet
   if [ -z $LOCAL_SOFTWARESANO ]; then
      IntAcc=$(wget -q -S http://www.softwaresano.com -O /dev/null 2>&1 |\
               grep "HTTP/" | tail -1| grep "OK"| awk '{ print $2 }')
      if [ "$IntAcc" == "200" ]; then
         echo "true"
      else 
         echo "false"
      fi
   else
      echo "true"
   fi
}

function isJavaOk(){
   [ "$yumInstallation" == "true" ] && JAVA_HOME="/usr/java/default" && return 0
   if [ "$distribution" != "Debian" ]; then
      if [ "$JAVA_HOME" == "${DEFAULT_JAVA_HOME}" ]; then
         _log "[ERROR] No está definida la variable JAVA_HOME"
         help
         return 1
      fi
      if [ "$JAVA_HOME" == "" ]; then
         JAVA_HOME="$(dirname $(dirname $(readlink $(which javac 2>/dev/null) 2>/dev/null) 2>/dev/null) 2>/dev/null)"
         if [ "$JAVA_HOME" != "" ]; then
            _log "[INFO] Default JAVA_HOME [$JAVA_HOME] is assigned"
         else
            return 1
         fi
      else
         temp=`find "$JAVA_HOME/bin" -name "javac"`
         if [ "$temp" == "" ]; then
            _log "[ERROR] En la ubicación $JAVA_HOME/bin/javac no existe la máquina virtual de java"
            return 1
         fi
      fi
   fi
   return 0
}

function uninstall(){
   #Evitar que se haya abortado una instalación o desinstalación a medio (la instalación podría crear links simbólicos cíclicos)
   rm -Rf /etc/httpd/conf.d/$APPNAME.conf && rm -Rf /etc/httpd/conf.d/${APPNAME}.conf.d
   existRepo=$(ls $PROJECT_HOME/app/repositories/rpms/noarch/ss-develenv-repo-*.rpm* 2>/dev/null)
   if  [ ! -z "$existRepo" ]; then
   	chattr -i $existRepo
   fi
   [ "$yumInstallation" == "true" ] && return 0
   ###
   # Desinstalando cualquier version anterior
   # Si ya estaba instalado se desinstala
   if [ -d "/home/$PROJECT_USER" ]; then
      areYouSure
   else
      $DIR/uninstall.sh
   fi
}

function addUserIfNotExits(){
   [ "`grep \"^$PROJECT_USER:\" /etc/passwd`" == "" ] && useradd $PROJECT_USER
   sed -i s:"$PROJECT_HOME\:/bin/sh":"$PROJECT_HOME\:/bin/bash":g /etc/passwd
}

function decompress(){
   [ "$yumInstallation" == "true" ] && return 0
   FILE_TAR_GZ=$PROJECT_NAME-$PROJECT_VERSION-install.tar.gz
   cd /
   _log "Descomprimiendo $FILE_TAR_GZ..."
   tar xfz $DIR/$FILE_TAR_GZ
   if [ "$?" != 0 ]; then
      _log "[ERROR] Error en la descompresión de $FILE_TAR_GZ"
      exit 1
   fi
   if [ "$DEBUG_DEVELENV" == "TRUE" ] || [ -f /tmp/DEBUG_DEVELENV ]; then
      _log "[WARNING] $DIR/$FILE_TAR_GZ was not removed because DEBUG_DEVELENV=TRUE"
   else
      rm -Rf xfz $DIR/$FILE_TAR_GZ
   fi
   chown -R $PROJECT_USER:$PROJECT_USER /var/$APPNAME
   chown -R $PROJECT_USER:$PROJECT_USER /var/tmp/$APPNAME
   chown -R $PROJECT_USER:$PROJECT_USER /var/log/$APPNAME
   chown -R $PROJECT_USER:$PROJECT_USER /etc/$APPNAME
   chown -R $PROJECT_USER:$PROJECT_USER /etc/httpd/conf.d/${APPNAME}.conf.d
   chown -R $PROJECT_USER:$PROJECT_USER /home/$APPNAME
   chown -R $PROJECT_USER:$PROJECT_USER /opt/${ORG_ACRONYM}/$APPNAME
   chown -R $PROJECT_USER:$PROJECT_USER /etc/yum.repos.d/${ORG_ACRONYM}-thirdparty-${APPNAME}*
   chown -R $PROJECT_USER:$PROJECT_USER /etc/yum.repos.d/${ORG_ACRONYM}-*
}

function deleteUnnecessaryFiles(){
   # Se borran los ficheros utilizados temporalmente para realizar la instalación
   if [ "$DEBUG_DEVELENV" == "TRUE" ] || [ -f /tmp/DEBUG_DEVELENV ]; then
      _log "[WARNING] Installation files were not removed because DEBUG_DEVELENV=TRUE"
   else
      rm -Rf $PROJECT_HOME/install
      rm -Rf $PROJECT_HOME/bin/configure*.sh
      rm -Rf $PROJECT_HOME/bin/installSonarDB.sh
      rm -Rf $PROJECT_HOME/bin/apacheAutoIndex.sh
      cd $ORIGINAL_DEVELENV_DIR
   fi
   rm -Rf $PROJECT_HOME/.adminDevelenv

   
}

function getParameters(){
   getOrganization $*
   getAdminPassword $*
   getAdministratorId $*
   getRpmPhase $*
   [[ "$*" =~ "--help" ]] && help && exit 1
}

function areParametersOk(){
   if [ "$administratorId" == "" ]; then
      _message "Falta definir el administrador de [$PROJECT_NAME]"
   fi
   if [ "$adminPassword" == "" ]; then
      _message "Falta el password para el administrador de [$PROJECT_NAME]"
   fi
}

function areReqOk(){
   which wget >/dev/null 2>&1
   if [ "$?" == "0" ]; then
      echo "true"
   else
      echo "false"
   fi
}

function getParametersOfConfigurationFile(){
   cat /etc/$APPNAME/$APPNAME.properties
}

function setSOLimits(){
   mkdir -p /etc/security/limits.d/
   if [ -f /etc/security/limits.d/80-nofile.conf ]; then
      echo "*          -    nofile    16384">/etc/security/limits.d/80-nofile.conf
   else 
      echo "*          -    nofile    16384">/etc/security/limits.d/80-nofile.conf
   fi
}
function preInstall(){
   # Es necesario ser root para instalar este ${project.artifactId}
   if [ "`id|grep \"uid=0\"`" == "" ]; then
      _log "[ERROR] Para instalar $PROJECT_NAME es necesario ser root"
      exit 2
   fi
   isJavaOk
   [ $? != 0 ] && exit 1
   [ $(internetAccess) == "false" ] && _log "[ERROR] No hay acceso a internet" && exit 1
   uninstall
   addUserIfNotExits
   setSOLimits
   # Instalando paquetes
   installPackages
}

function install(){
   decompress
   install$distribution
}

function postInstall(){
   PROJECT_HOME=$prefix
   develenv_status=$(service develenv status 2>/dev/null|sed s:".* develenv is ":"":g)
   if [[ "$develenv_status" =~ "running" ]]; then
      service develenv stop
      wait_seconds=5
      _log "waiting up to $wait_seconds seconds for the develenv to end"
      sleep $wait_seconds
   fi;
         # Ensure develenv is stopped
   kill -9 $(ps -ef|grep $APPNAME|grep $PROJECT_HOME/platform/tomcat|tail -1|awk '{print $2}') 2>/dev/null
   cd $PROJECT_HOME
   _log "Configurando Links"
   #Remove this broken
   rm -Rf $PROJECT_HOME/app/hudson/jenkins/queue.xml
   configureLinks
   cd $prefix/bin
   current_time=`date +%T`
   crond="`date -u -d$current_time-0015 '+%M %H'`"
   getOrganizationConfigurationFile
   _log "Configurando $PROJECT_NAME ..."
   if [ -z $LOCAL_SOFTWARESANO ]; then
      INSTALL_DIR_LOG=/var/log/$APPNAME
   else
      INSTALL_DIR_LOG=/tmp
   fi
   isJavaOk
   getHostname
   addHostnameToEtcHost
   HOSTNAME=$HOST
   enviroment=native
   pushd . >/dev/null
   cd $PROJECT_HOME/conf/
   # Remove broken links. Ant fails if there are any broken link
   rm -Rf $(find -L * -type l)
   popd >/dev/null
   su $PROJECT_USER -c "../platform/ant/bin/ant -l $INSTALL_DIR_LOG/${PROJECT_NAME}.log -buildfile $PROJECT_HOME/install/buildfile \
            -Ddevelenv.host=$HOSTNAME -Ddevelenv.port="" \
            -Ddevelenv.prefix="$prefix" -Denv=$enviroment \
            -Ddevelenv.crond=\"$crond\" \
            -Ddevelenv.projectName=$PROJECT_NAME \
            -Ddevelenv.projectVersion=$PROJECT_VERSION \
            -Ddevelenv.projectHome=$PROJECT_HOME \
            -Ddevelenv.java.home=$JAVA_HOME replaceUser $* $profileorg >$INSTALL_DIR_LOG/${PROJECT_NAME}.error.log"
   if [ "$?" != "0" ]; then
      _log "[ERROR] Error durante la personalización.
Revisa $INSTALL_DIR_LOG/${PROJECT_NAME}.error.log y $INSTALL_DIR_LOG/${PROJECT_NAME}.log"
      exit 1
   fi
   su $PROJECT_USER -c "../platform/ant/bin/ant -l $INSTALL_DIR_LOG/${PROJECT_NAME}.1.log -buildfile $PROJECT_HOME/install/buildfile \
            -Ddevelenv.host=$HOSTNAME -Ddevelenv.port="" \
            -Ddevelenv.prefix="$prefix" -Denv=$enviroment \
            -Ddevelenv.projectName="$PROJECT_NAME" \
            -Ddevelenv.projectVersion="$PROJECT_VERSION" \
            -Ddevelenv.projectHome=$PROJECT_HOME \
            -Ddevelenv.crond=\"$crond\" \
            -Ddevelenv.java.home=$JAVA_HOME $* $profileorg >$INSTALL_DIR_LOG/${PROJECT_NAME}.1.error.log"
   if [ "$?" != "0" ]; then
      _log "[ERROR] Error durante la personalización.
Revisa $INSTALL_DIR_LOG/${PROJECT_NAME}.error.log y $INSTALL_DIR_LOG/${PROJECT_NAME}.log"
      exit 1
   fi
   # Fix problem with permissions in replace task ant
   find ../ -name "*.sh" -exec chmod 755 {} \;
   . ./setEnv.sh
    [[ "$rpmPhase" == "" ]] && ./installSonarDB.sh
   chown -R $PROJECT_USER:$PROJECT_USER /var/tmp/rpm/
   # Create develenv-repo
   su $PROJECT_USER -c "./develenv-repo.sh"
   errorCode=$?
   if [[ "$errorCode" != "0" ]]; then
      _log "[ERROR] Unable create develenv repo. Aborting develenv installation"
      exit 1
   fi
   if [ "$distribution" == "RedHat" ]; then
     chcon -Rv --type=httpd_sys_content_t $PROJECT_HOME/app/repositories/rpms/noarch/ss-develenv-repo-*.rpm
   fi
   chattr +i $PROJECT_HOME/app/repositories/rpms/noarch/ss-develenv-repo-*.rpm
   # In not rpm installation is necessary delete delvenv-repos
   [[ "$rpmPhase" == "" ]] && rm -Rf /etc/yum.repos.d/${ORG_ACRONYM}-$APPNAME-*.repo
   # Eliminando repositorios rpms de la arquitectura diferente al de la máquina
   [ "`arch`" == "x86_64" ] && rm -Rf /etc/yum.repos.d/*-i686.repo || rm -Rf /etc/yum.repos.d/*-x86_64.repo
   ./configureApache.sh
   /etc/init.d/$APACHE2_SCRIPT_INIT reload
   _log "[INFO] Habilitando servicio $PROJECT_NAME"
   rm -Rf /etc/init.d/$PROJECT_NAME
   ln -s $PROJECT_HOME/bin/bootstrap.sh /etc/init.d/$PROJECT_NAME
   $BOOT_COMMAND
   chmod 755 /home/$PROJECT_USER
   chmod -R 700 /home/$PROJECT_USER/.ssh
   chmod  600 /home/$PROJECT_USER/.ssh/id_dsa
   chmod  600 /home/$PROJECT_USER/.ssh/id_dsa.pub
   pushd . >/dev/null
   cd $PROJECT_HOME/docs/$PROJECT_GROUPID/$PROJECT_NAME
   $PROJECT_HOME/bin/apacheAutoIndex.sh
   popd >/dev/null
   # To publish develenv parameters first time
   mkdir -p `dirname $FIRST_EXECUTION_FILE`
   touch $FIRST_EXECUTION_FILE
   touch $PROJECT_HOME/.adminDevelenv
   [ "$yumInstallation" != "true" ] && installDevelenvPlugins
   install$distribution
   postInstall${distribution}
   deleteUnnecessaryFiles
   # For building rpms with deployment pipeline plugin, you need 777 permissions
   # in /var/tmp
   chmod -R 777 /var/tmp
   service $PROJECT_NAME start
   service ${PROJECT_NAME}-sonar start
   _log "$PROJECT_NAME instalado."
   _message "================================================================================
Los usuarios/password para $PROJECT_NAME son:
Admin ${PROJECT_NAME}:
   Usuario=${administratorId} 
   Password=${adminPassword}
   Role=Administrador de tomcat
   Url=http://$HOSTNAME/$PROJECT_NAME/admin/
Jenkins:
   Usuario=${administratorId} 
   Password=${adminPassword} ó Si se ha configurado un LDAP para el acceso a Jenkins será el password que haya definido en LDAP
   Role= Administrador de jenkins
   Url=http://$HOSTNAME/jenkins
Nexus:
   Usuario=${administratorId}
   Password=develenv  ó Si se ha configurado un LDAP para el acceso a Nexus será el password que haya definido en LDAP
   Role=Administrador de nexus
   Url=http://$HOSTNAME/nexus
Sonar:
   Usuario=${administratorId}
   Password=develenv ó Si se ha configurado un LDAP para el acceso a Sonar será el password que haya definido en LDAP
   Role= Administrador de sonar
   Url=http://$HOSTNAME/sonar
Selenium Grid:
   Url=http://$HOSTNAME/grid
$PROJECT_NAME: Manuales de $PROJECT_NAME
   Usuario=anonymous
   Password=
   Url=http://$HOSTNAME/docs
Logs de $PROJECT_NAME 
   Usuario=anonymous
   Password=
   Descripción=Acceso a los logs de $PROJECT_NAME
   Url=http://$HOSTNAME/$PROJECT_NAME/logs
Configuración de $PROJECT_NAME
   Usuario=anonymous
   Password=
   Descripción=Acceso en modo lectura a los ficheros de configuración de $PROJECT_NAME
   Url=http://$HOSTNAME/$PROJECT_NAME/config
Guía de administración de $PROJEC_NAME:
   Url=http://$HOSTNAME/docs/administrationGuide.html
Repositorios de componentes:
   Usuario=anonymous
   Password=
   Url=http://$HOSTNAME/$PROJECT_NAME/repos
   Descripción=Repositorios con los componentes(maven, rpms, debian, ...) generados por los diferentes jobs de jenkins
[NOTAS]
  [1] El arranque de $PROJECT_NAME puede tardar varios minutos debido al arranque de sonar. Esto significa que durante el arranque al acceder a cualquier herramienta de $PROJECT_NAME, el servidor devolverá 'Service Temporarily Unavailable' 
  [2] En  http://code.google.com/p/develenv-plugins/ existe una lista con los plugins disponibles para $PROJECT_NAME (PHP, android, ...)
  [3] En  http://code.google.com/p/develenv/wiki/newProject existe una guía para desarrollar tu primer proyecto con $PROJECT_NAME
  [4] Las herramientas que componen develenv(sobre todo jenkins y sonar) utilizan plugins para ampliar la funcionalidad de las mismas. Estos plugins pueden consumir bastante memoria. Si develenv no arranca comprobar la memoria que queda libre en la máquina utilizando el comando free -m
  [5] Si no se va a utilizar Selenium Grid, puede desactivarse para rebajar el consumo de memoria. Consulta como hacerlo en http://$HOSTNAME/docs/selenium/seleniumGridOff.html
  [6] $PROJECT_NAME puede introducir algunos problemas de seguridad en el sistema. Para saber cuáles son y como elminarlos consulte http://$HOSTNAME/docs/security.html
  [7] Consulta las últimas versiones disponibles de $PROJECT_NAME en http://develenv.softwaresano.com
  [8] Cualquier error/sugerencia sobre develenv enviar un mail a develenv@softwaresano.com"
}

currentDir
ORIGINAL_DEVELENV_DIR=$PWD
OLD_DIR=$PWD
getParameters $*
APPNAME="develenv"
isRPMinstallation
if [ "$yumInstallation" == "true" ]; then
   #Is a rpm installation
   setEnvFile=/etc/$APPNAME/setEnv.sh
else
   setEnvFile=$DIR/setEnv.sh
fi
. $setEnvFile
okParameters=$(areParametersOk)
sed -i s:"^ADMINISTRATOR_ID=.*":"ADMINISTRATOR_ID=$administratorId":g $setEnvFile
ADMINISTRATOR_ID=$administratorId
if [ "$(areReqOk)" == "false" ]; then
   _log "[ERROR] No se puede instalar $APPNAME ya que no cumple los requisitos. \
         wget debería estar instalado."
   exit 1
fi

if [ "$okParameters" != "" ]; then
   if [ "$rpmPhase" == "" ]; then
      if ! [ -f /etc/$APPNAME/${APPNAME}.properties ]; then
         echo -e "${okParameters}" && defaultInstallation && exit $?
      else
         _log "Executing ./$0 $(getParametersOfConfigurationFile)"   
         ./$0 $(getParametersOfConfigurationFile)
         exit $?      
      fi
   else
      _log "Executing ./$0 $(getParametersOfConfigurationFile) -DrpmPhase=$rpmPhase"
      ./$0 $(getParametersOfConfigurationFile) -DrpmPhase=$rpmPhase
      exit $?
   fi
fi

[ "$okParameters" != "" ] && echo -e "${okParameters}" && defaultInstallation && exit $?
[ -z `echo $PROJECT_VERSION|egrep "\-SNAPSHOT$"` ] && URL_DEVELENV_REPO="tags/develenv-${PROJECT_VERSION}" || URL_DEVELENV_REPO="trunk/develenv"
if [ "$prefix" == "" ]; then
   prefix=/home/$PROJECT_NAME
fi
PROJECT_HOME=$prefix
if [ "$rpmPhase" == "" ]; then
   mkdir -p /etc/$APPNAME/
   echo $* > /etc/$APPNAME/$APPNAME.properties
   preInstall
   install
   postInstall $*
   exit $?
else
   $rpmPhase $*
   exit $?
fi
exit 0
