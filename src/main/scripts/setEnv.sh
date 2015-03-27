#!/bin/bash
set +e
_message(){
   _error_color="\\033[47m\\033[1;31m"
   _warning_color="\\033[37m\\033[1;33m"
   _default_log_color_pre="\\033[0m\\033[1;34m"
   _default_log_color_suffix="\\033[0m"
   isError=$(echo "$1"|grep -i "\\[ERROR\\]")
   isWarning=$(echo "$1"|grep -i "\\[WARNING\\]")
   isDash=`echo -en|grep "\-en"`
   if ! [ -z "$isError" ]; then 
      messageColor=${_error_color} 
   else
      if ! [ -z "$isWarning" ]; then 
         messageColor=${_warning_color}
      else
         messageColor=${_default_log_color_pre}
      fi
   fi 
   if [ -z "$isDash" ]; then
      if [ -z "$isError" ]; then
         echo -en "${messageColor}$1${_default_log_color_suffix}\n"
      else
         # 1>&2 FIX problem with sudo execution
         echo -en "${messageColor}$1${_default_log_color_suffix}\n" 1>&2
      fi
   else 
      if [ -z "$isError" ]; then
         echo "${messageColor}$1${_default_log_color_suffix}\n"
      else
         echo "${messageColor}$1${_default_log_color_suffix}\n" 1>&2
      fi
   fi
}


_log(){
   _message "[`date '+%Y-%m-%d %X'`] $1"
}

commons_RedHat(){
   APACHE2_SCRIPT_INIT="${redhat.apache2.script.init}"
}
commons_Debian(){
   APACHE2_SCRIPT_INIT="${debian.apache2.script.init}"
}
installationInRedHat6(){
   CONFIGURE_REPOS=""
}
installationInOthersRedHat(){
   if [ `uname -m` == "i686" ]; then
      CONFIGURE_REPOS="rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm"
   else
      CONFIGURE_REPOS="rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/`uname -m`/epel-release-5-4.noarch.rpm"
   fi
}
isCentos6(){
    issueFile="`head -n1 /etc/issue`"
    centos6Distribution=`echo $issueFile|egrep "CentOS.*6\.[0-9]+ "`
}
# setup enviroment ${project.artifactId}
installationInRedHat(){
    APACHE_CONF_DIR=${redhat.apache.conf.dir}
    APACHE_HTML_DIR=${redhat.apache.html.dir}
    BOOT_COMMAND="${redhat.boot.command}"
    BOOT_COMMAND_UNDO="${redhat.boot.command.undo}"
    isCentos6
    if [ "$centos6Distribution" != "" ]; then
        CONFIGURE_REPOS="LANG=C"
    else
        if  [ "`head -n1 /etc/issue|grep '(Santiago)'`" == "" ]; then
            #No es una RedHat6
            installationInOthersRedHat
        else
            installationInRedHat6
        fi
        [ "$CONFIGURE_REPOS" == "" ] &&\
        CONFIGURE_REPOS="yum update yum -y;yum install mysql-server -y" ||\
        CONFIGURE_REPOS="$CONFIGURE_REPOS;yum update yum -y;yum install mysql-server -y"
    fi
    CONFIGURE_REPOS="$CONFIGURE_REPOS; rpm -Uvh ${url.external.repo}/src/site/resources/tools/rpms/noarch/ss-thirdparty-develenv-repo-1.0-0.0.noarch.rpm"
    INSTALL_PACKAGE="yum install"
    PRE_INSTALLATION_PACKAGES="bind-utils"
    NEW_PACKAGES="bind-utils subversion mercurial git httpd mysql-server php wget xorg-x11-server-Xvfb curl openssh-clients rpm-build rpmdevtools createrepo firefox lcov google-chrome-stable-26 sloccount php-xml"
    APACHE2_MODULES=""
}

installationInDebian(){
    APACHE_CONF_DIR=${debian.apache.conf.dir}
    APACHE_HTML_DIR=${debian.apache.html.dir}
    BOOT_COMMAND="${debian.boot.command}"
    BOOT_COMMAND_UNDO="${debian.boot.command.undo}"
    # Para 11.10 --> add-apt-repository ppa:ferramroberto/java
    debianRelease=`lsb_release -c|awk '{print $2}'`
    debianReleaseNumber=`lsb_release -r|awk {'print $2'}|sed s:"\.":"":g`
    if [ "${debianReleaseNumber}" -ge "1104" ]; then
       ADD_REPOSITORY="ppa:webupd8team/java"
       jdk_package="oracle-jdk7-installer"
       java_dir="/usr/lib/jvm/java-7-oracle"
    else
       ADD_REPOSITORY="\"deb http://archive.canonical.com/ $debianRelease partner\""
       jdk_package="sun-java6-jdk"
       java_dir="/usr/lib/jvm/java-6-sun"
    fi
    CONFIGURE_REPOS="apt-get install python-software-properties;add-apt-repository $ADD_REPOSITORY;apt-get update"
    INSTALL_PACKAGE="apt-get install"
    PRE_INSTALLATION_PACKAGES=""
    NEW_PACKAGES="${jdk_package} openssh-server subversion git-core mercurial mysql-server apache2 php5 sloccount wget firefox chromium-browser xvfb curl lcov createrepo rpm sloccount"
    APACHE2_MODULES="a2enmod proxy proxy_ajp proxy_balancer proxy_http headers autoindex"
    #PHP_PACKAGES="php5 php5-dev php5-cli  php-benchmark php-pear phpunit2 phpunit"
}
log_methods_RedHat(){
   # Las ${redhat.init.functions} modifican el PATH, por lo tanto nos guardamos el path
   # anterior para después agregarlo
   OLD_PATH=$PATH
   ${redhat.init.functions}
   export PATH=$OLD_PATH:$PATH
   SCRIPT_LOG_METHOD_DAEMON=${redhat.script.log.method.daemon}
   SCRIPT_LOG_METHOD_SUCESS=${redhat.script.log.method.sucess}
}

log_methods_Debian(){
   ${debian.init.functions}
   SCRIPT_LOG_METHOD_DAEMON=${debian.script.log.method.daemon}
   SCRIPT_LOG_METHOD_SUCESS=${debian.script.log.method.sucess}
}
myDistribution(){
    distribution="Unknown"
    if [ "`uname -a|grep "Linux"`" != "" ]; then
      linux=false
      dist=$(grep -i "Ubuntu" /proc/version)
      if [ "$dist" != "" ]; then
         distribution="Debian"
      else
         dist=$(grep -i "Red Hat" /proc/version)
         if [ "$dist" != "" ]; then
           distribution="RedHat"
         fi
      fi
    else
      if [ "`uname -a|grep SunOS|cut -f1 -d' '`" != "" ]; then
         distribution=SunOS
      else
         if [ "`uname -a|grep ^Darwin`" != "" ]; then
            distribution=macOS
         fi
      fi
    fi
}

[ "$(echo $0 |egrep "build\.sh|versionsParser\.sh|releasesParser\.sh|createISO\.sh|dp_.*\.sh")" != "" ] && \
   [ "$(grep '\${redhat\.' src/main/scripts/setEnv.sh 2>/dev/null)" != "" ] && \
   return 0
#Si no hay definido ningún JAVA_HOME
if [ -z "$JAVA_HOME" ]; then
   JAVA_HOME=${DEFAULT_JAVA_HOME}
fi

#Configurar variables distribución
myDistribution
export $distribution
commons_${distribution}
# Cuando se ejecuta el setEnv sin filtrar
if [ -z "$APACHE2_SCRIPT_INIT" ]; then
   return 0
fi
log_methods_${distribution}
case $distribution
    in
   CentOS|RedHat)
            #linux_RedHat
       ;;
        SunOS)
            $SCRIPT_LOG_METHOD_SUCESS "Todavía no se ha implementado la distribución para SunOS"
            exit 1
            ;;
        Unknown)
            $SCRIPT_LOG_METHOD_SUCESS "Distribución desconocida"
            exit 2
            ;;
   *)
       #linux_Debian
       ;;
    esac

export PROJECT_HOME=/home/${project.artifactId}
export PROJECT_VERSION=${project.version}
export PROJECT_USER=${project.artifactId}
export PROJECT_NAME=${project.artifactId}
export PROJECT_GROUPID=${project.groupId}
export PROJECT_PLUGINS=$PROJECT_HOME/app/plugins
ORG_ACRONYM=${organization.acronym}
APPNAME=${project.artifactId}
ADMINISTRATOR_ID=${developerId}
SITE_URL=${maven.site.url}
SITES=${maven.site.prefix}
MAVEN_HOME=$PROJECT_HOME/platform/maven
DEVELENV_PATH=$PROJECT_HOME/bin:$PROJECT_HOME/platform/ant/bin:$PROJECT_HOME/platform/jmeter/bin:$PROJECT_HOME/platform/soapui/bin:$MAVEN_HOME/bin:$JAVA_HOME/bin
if [ -z "$(echo $PATH|grep $DEVELENV_PATH)"  ]; then
   export PATH=$DEVELENV_PATH:$PATH
fi
export SONAR_HOME=/var/$APPNAME/sonar
export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=512m"
FIRST_EXECUTION_FILE=/var/$APPNAME/firstExecution
