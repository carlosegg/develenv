#!/bin/bash
if [[ $DEBUG_PIPELINE == "TRUE" ]]; then
  set -x
fi
source ./src/main/scripts/setEnv.sh
# setup enviroment for develenv
function linux_RedHat(){
    INSTALL_PACKAGE="yum install"
    NEW_PACKAGES="sun-java6-jdk subversion createrepo"
}

function linux_Debian(){
    INSTALL_PACKAGE="aptitude install"
    NEW_PACKAGES="sun-java6-jdk subversion createrepo"
}

function linux_macOS(){
    INSTALL_PACKAGE="port install"
    NEW_PACKAGES="subversion createrepo rpm54 cdrtools"

}
function autoExecutable(){
   pushd . >/dev/null
   LANG=C
   thisFile=$(python -c 'import os,sys;print os.path.realpath(sys.argv[1])' build.sh)
   cd target/site/assemblies
   fileName=`ls *-offline.tar.gz`
   rm -Rf *-install.tar.gz
   rm -Rf *.war
   dirUnTar=`echo ${fileName}|sed s:"-offline.tar.gz":"":g`
   outputFile=${dirUnTar}.sh
   size=`ls -Al ${fileName}|awk '{print $5}'`
   echo "#!/bin/bash" > ${outputFile}
   echo "size=$size" >> ${outputFile}
   echo "dirUnTar=$dirUnTar" >> ${outputFile}
   lineSeparator=`grep -n "#### install ####" $thisFile|grep -v "grep"|cut -d ':' -f1`
   #Agregando el fichero de instalación
   cLines=$(expr $(wc -l <$thisFile) - $lineSeparator + 4)
   echo "scriptLines=$cLines" >> ${outputFile}
   sed 1,${lineSeparator}d $thisFile >> ${outputFile}
   #Agregando el tar.gz
   tail -c $size ${fileName} >>${outputFile}
   chmod u+x ${outputFile}
   rm -Rf ${fileName}
   popd >/dev/null
}
myDistribution
linux_${distribution}

IS_JAVA=`which javac|grep javac`
IS_SVN=`which svn|grep svn`
IS_CREATEREPO=`which createrepo|grep createrepo`
if [ "$IS_JAVA" == "" -o "$IS_SVN" == "" -o  "$IS_CREATEREPO" == "" ]; then
   _log "[ERROR] Faltan instalar paquetes. Ejecuta
   sudo $INSTALL_PACKAGE $NEW_PACKAGES"
   exit 1
fi
externalToolDir="src/main/rpm/SOURCES"
version=$(grep "</\?version>" pom.xml|head -n1|sed s:"</\?version>":"":g|awk '{print $1}')
artifactId=$(grep "</\?artifactId>" pom.xml|head -n1|sed s:"</\?artifactId>":"":g|awk '{print $1}')
url_external_repo=`svn propget svn:externals .|grep "^${externalToolDir}"|awk '{print $2}'|sed s:"/src/site/resources/tools$":"":g`
export MAVEN_HOME=$PWD/${externalToolDir}/platform/maven/
export PATH=$MAVEN_HOME/bin:$PATH
export MAVEN_OPTS="-Xmx512m"
export localRepository=$PWD/maven/repository
export settings_file=$PWD/${externalToolDir}/platform/maven/conf/settings.xml
mkdir -p $localRepository
develenv_host=develenv_host
develenv_port=:11111
develenv_java_home=@develenv.java.home@
develenv_prefix=@develenv.prefix@
MVN_BASE_OPTIONS="--global-settings=$settings_file --settings=$settings_file \
                    clean package -DlocalRepository=$localRepository \
                    -Ddevelenv.host=$develenv_host \
                    -Ddevelenv.port=$develenv_port \
                     site:site site:deploy assembly:assembly \
                    -DrepoSiteUrl=file://localhost$PWD/target/internal-site \
                    -Dprefix=$develenv_prefix \
                    -Durl_external_repo=${url_external_repo} \
                    -Dadministrator.id=@administrator.id@ \
                    -Dpassword=@password \
                    -DDEFAULT_JAVA_HOME=$develenv_java_home"

function get_externals(){
  DEFAULT_EXT_DEVELENV_DIR=../ext-develenv
  DEFAULT_PIPELINE_PLUGIN_DIR=../pipeline_plugin
  
  [[ "$EXT_DEVELENV_DIR" == "" ]] && EXT_DEVELENV_DIR=$DEFAULT_EXT_DEVELENV_DIR
  [[ "$PIPELINE_PLUGIN_DIR" == "" ]] && PIPELINE_PLUGIN_DIR=$DEFAULT_PIPELINE_PLUGIN_DIR
 
  local ext_develenv_dir=
  rsync --delete --exclude .svn -arv $EXT_DEVELENV_DIR/sonar-runner/src/site/resources/ sonar-runner/src/main/rpm/SOURCES
  rsync --delete --exclude .svn -arv $EXT_DEVELENV_DIR/jenkins/src/site/resources/ jenkins/src/main/rpm/SOURCES
  rsync --delete --exclude .svn -arv ./src/main/resources/home src/main/development/vagrant/instance/modules/home/files
  rsync --delete --exclude .svn -arv $PIPELINE_PLUGIN_DIR/plugin/app/hudson/jobs/pipeline-ADMIN-01-addPipeline jenkins/src/main/config/jobs/pipeline-ADMIN-01-addPipeline
  rsync --delete --exclude .svn -arv $EXT_DEVELENV_DIR/jenkins/src/main/config/plugins jenkins/src/main/config/plugins
  rsync --delete --exclude .svn -arv $EXT_DEVELENV_DIR/nexus/src/site/resources nexus/src/main/rpm/SOURCES
  rsync --delete --exclude .svn -arv $EXT_DEVELENV_DIR/sonar/src/site/resources/ sonar/src/main/rpm/SOURCES
  rsync --delete --exclude .svn -arv $EXT_DEVELENV_DIR/selenium/src/site/resources/ selenium/src/main/rpm/SOURCES
  rsync --delete --exclude .svn -arv $EXT_DEVELENV_DIR/jmeter/src/site/resources/ jmeter/src/main/rpm/SOURCES
  rsync --delete --exclude .svn -arv $EXT_DEVELENV_DIR/soapui/src/site/resources/ soapui/src/main/rpm/SOURCES
  rsync --delete --exclude .svn -arv $EXT_DEVELENV_DIR/src/site/resources/tools src/main/rpm/SOURCES
  rsync --delete --exclude .svn -arv $EXT_DEVELENV_DIR/devpi/src/site/resources devpi/src/main/rpm/SOURCES
  rsync --delete --exclude .svn -arv $PIPELINE_PLUGIN_DIR deploymentPipeline/src/main/deploymentPipeline
}
get_externals
_log "Initializing maven build"
mvn $MVN_BASE_OPTIONS
result=$?
# Si no se han creado los assemblies se aborta el build
if [ "$result" == "0" ]; then
   autoExecutable
   if ! [ -z $LOCAL_SOFTWARESANO ]; then
      src/main/scripts/createISO.sh
   fi
   cat src/main/resources/home/.motd
   _log "[BUILD SUCCESS] Para instalar develenv sigue las instrucciones que se indican en $PWD/target/site/installation.html"
   _log "[INFO] Para generar los rpms de develenv.Dos opciones:"
   _log "[INFO] 1"
   _log "[INFO]    export DP_HOME=$(dirname $(readlink -f build.sh))/deploymentPipeline/src/main/deploymentPipeline/plugin/app/plugins/pipeline_plugin"
   _log "[INFO]    \$DP_HOME/dp_package.sh"
   _log "[INFO] 2"
   _log "[INFO]    deploymentPipeline/src/main/deploymentPipeline/plugin/app/plugins/pipeline_plugin/dp_package.sh"
fi
exit $result
#### install ####
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}
function myDistribution(){
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
      fi
   fi
}
function removeTemporalDir(){
   # Por si se hace un control C y pilla en el directorio raiz se hace la comprobación
   if ! [ -z `dirname $PWD|egrep -w  "/var/tmp/develenv20[0-9][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9][0-5][0-9]$"` ]; then
      echo Borrando directorio temporal [`dirname $PWD`] de instalación 
      rm -Rf `dirname $PWD`
   fi
}
function installDevelenv(){
   local minimalHDFree=2048
   if [ "$distribution" == "RedHat" ]; then
      diskFree=$(expr $(echo `df -m|egrep -w '/$|/var$' |awk '{print $3}'`|sed s:" ":" + ":g))
   else
      diskFree=$(expr $(echo `df -m|egrep -w '/$|/var$' |awk '{print $4}'`|sed s:" ":" + ":g))
   fi
   #Al menos un 2G de disco duro libre
   if [ "$minimalHDFree" -ge "$diskFree" ]; then
      echo "[ERROR] Para instalar develenv con los ejemplos hace falta al menos [$minimalHDFree M] de disco libre. Sólo hay disponibles [$diskFree M]"
      exit 1   
   fi 
   tail -c $size $0 |gunzip - >/dev/null 2>&1
   if [ "$?" != 0 ]; then
      echo Gunzip incorrecto. Revisa md5
      exit 1
   fi
   tail -c $size $0 |gunzip - |tar xf -
   if [ $? != 0 ]; then
      echo "ERROR en la descompresión. Comprueba la integridad del fichero (http://develenv.softwaresano.com/downloadOk.php?artifact=$0)"
      removeTemporalDir
      exit 1
   fi
   cd $dirUnTar
   DEVELENV_DIR_DESCOMPRESS=$PWD
   ./install.sh $*
   exitCode=$?
   if [ -d $DEVELENV_DIR_DESCOMPRESS ]; then
      rm -Rf $DEVELENV_DIR_DESCOMPRESS
   fi
   removeTemporalDir
}
#Tests the installations in temporal dir /var/tmp/develenv...
function execInTemporalDir(){
   filePath="`pwd`/`basename $0`"
   if [ -z `dirname $filePath|egrep -w  "/var/tmp/develenv20[0-9][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9][0-5][0-9]$"` ]; then
      #Comprobando si el directorio desde el que se ha invocado existe
      tmpDirInstallation=/var/tmp/develenv`date '+%Y%m%d%H%M%S'`
      mkdir -p /var/tmp/
      chmod 777 /var/tmp/
      chmod u+t /var/tmp/
      mkdir -p $tmpDirInstallation
      if ! [ -w $PWD ]; then
         if [ -d $PWD ]; then 
            execution=$filePath
         else
            execution=$0
         fi
         #Si no tiene permisos de escritura
         cd $tmpDirInstallation 2>/dev/null
         $execution $*
         rm -Rf $tmpDirInstallation
         exit 0  
      fi
      currentDir
      cd $tmpDirInstallation
      $DIR/`basename $0` $*
      exit $?
   fi
}
if [ `id -u` != "0" ]; then
   echo "Sólo el usuario root puede instalar."
   exit 1
fi
myDistribution
execInTemporalDir $*
installDevelenv $*
exit 0

