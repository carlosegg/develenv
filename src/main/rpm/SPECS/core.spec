#rpmbuild -v  --clean  --define '_buildshell '/bin/bash' --define '_topdir \
#'/home/carlosg/workspace/develenv/target/.rpm --define 'versionModule '1 \
#--define 'releaseModule '2  -bb /var/tmp/rpm/ss-develenv-core-1-2/ss-develenv-core.spec

%{!?xorg_dependency: %global xorg_dependency %([[ "$(cat /etc/redhat-release |sed s:'.*release ':'':g|awk '{print $1}'|cut -d '.' -f1)" == "7" ]] && echo "" || echo "xorg-x11-xdm")}

%define project_name develenv
%define org_acronynm ss
Name:      core
Summary:   Ecosistema de integración contínua (Todo en un único paquete)
Version:   %{versionModule}
Release:   %{releaseModule}
License:   GPL 3.0
Packager:  ss
Group:     develenv
BuildArch: noarch
BuildRoot: %{_topdir}/BUILDROOT
Requires:  %{org_acronynm}-%{project_name}-user >= 33-2409, bind-utils,httpd,php,wget,xorg-x11-server-Xvfb,libXfont %{xorg_dependency} curl,openssh-clients,rpm-build,rpmdevtools,createrepo,ss-develenv-config = %{versionModule}-%{releaseModule}, ss-develenv-devpi-server >= 2.1.0-1, ss-develenv-devpi-client >= 2.0.5-1 ,ss-develenv-jmeter >= 2.12-97.1 ,ss-develenv-soapui >= 5.0.0-2250.142, ss-develenv-ant >= 1.9.4-2270.157, ss-develenv-maven >= 3.2.5-2521, ss-develenv-maven2 >= 2.2.1-2, ss-develenv-jenkins-plugins >= 2538.%{versionModule}-130.1, ss-develenv-nexus >= 2.11.2-2537.125, ss-develenv-sonar-plugins >= 2544-127.1, ss-develenv-sonar-rules >= 3-2054.1, ss-develenv-selenium-drivers >= 26.0.1383-2236.130, ss-develenv-docs = %{versionModule}-%{releaseModule}, ss-develenv-screenshot >= %{versionModule} ss-develenv-docker-registry >= %{versionModule} ss-develenv-dp-jenkins, ss-develenv-dp-dashboard
Vendor:    SoftwareSano.com



%define _binaries_in_noarch_packages_terminate_build 0
%define package_name allInOne

%description
%{project_name} proporciona una solución para la automatización del proceso de construcción, testing y despliegue de software.
Consulta http://develenv.softwaresano.com
#-------------------------------------------------------------------------------
# CLEAN
#-------------------------------------------------------------------------------
%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*

#-------------------------------------------------------------------------------
# PREP
#-------------------------------------------------------------------------------
%prep
_log "Building package %{name}-%{version}-%{release}"
source_file="`find $PWD/../../../site/assemblies/ -name \"%{project_name}-*.sh\"`"
[ "${source_file}" == "" ] && _log "[ERROR] $PWD/../../../site/assemblies/%{project_name}-*.sh doesn't exit" && exit 1
sLines=$(head -n4 $source_file | grep scriptLines| cut -d= -f2)
head -n$sLines $source_file|egrep "size|tail"|grep -v /dev/null|sed s:"\$0":"$source_file":g > .rpmDecompress.sh
chmod 755 .rpmDecompress.sh
./.rpmDecompress.sh
rm -Rf .rpmDecompress.sh
rm -Rf $RPM_BUILD_ROOT
%{__mkdir_p} %{buildroot}/
baseFile=`basename $source_file|sed s:"\.sh":"":g`
cd $RPM_BUILD_ROOT
tar xvfz $RPM_BUILD_DIR/$baseFile/${baseFile}-install.tar.gz
rm -Rf $RPM_BUILD_DIR/$baseFile/${baseFile}-install.tar.gz
# Config in package config
rm -rf %{buildroot}/etc/
# Borramos lo que ya que tenemos en los rpms construidos.
rm -rf %{buildroot}/opt/ss/develenv/platform/jmeter
rm -rf %{buildroot}/opt/ss/develenv/platform/soapui
rm -rf %{buildroot}/opt/ss/develenv/platform/ant
rm -rf %{buildroot}/opt/ss/develenv/platform/maven
rm -rf %{buildroot}/opt/ss/develenv/platform/maven2
rm -rf %{buildroot}/opt/ss/develenv/platform/selenium
rm -rf %{buildroot}/opt/ss/develenv/platform/sonar-runner
rm -rf %{buildroot}/var/develenv/jenkins/plugins
rm -rf %{buildroot}/var/develenv/jenkins/jobs
rm -rf %{buildroot}/var/develenv/sites/pipelines
rm -rf %{buildroot}/var/develenv/sites/plugin/pipeline_plugin
rm -rf %{buildroot}/var/develenv/plugins/pipeline_plugin


# Eliminamos toda la documentación ya que lo icluimos en paquete a parte
rm -rf %{buildroot}/var/develenv/docs %{buildroot}/var/develenv/.htaccess
# Limpiamos tomcat ya que instalamos casi todas las herramientas vía RPM
cd %{buildroot}/opt/ss/develenv/platform/tomcat/
# Nos lo cargamos todo excepto el fichero bin/setenv.sh
# borramos todos los ficheros LICENSE, RELEASE_NOTES, etc...
rm $(find . -maxdepth 1 -name "*" -type f)
# borramos los directorios temporales
rm -rf conf lib work temp logs
# entramos en bin y borramos todo menos setenv.sh
cd bin
rm $(ls |grep -v setenv.sh)
# Borramos todas las webapps
rm -Rf ../webapps/
# Borrar ficheros asociados a sonar
rm -rf %{buildroot}/var/develenv/sonar

cd $RPM_BUILD_ROOT
# Deleting etc/yum.repos. because this package depends of ss-develenv-repo.
rm -Rf etc/yum.repos.d
#cp $(ls -t %{_rpmdir}/noarch/%{org_acronynm}-%{project_name}-repo*.rpm|head -n1) var/%{project_name}/repositories/rpms/noarch


%pre
#-------------------------------------------------------------------------------
# PRE-INSTALL
#-------------------------------------------------------------------------------
if ! [ -f /etc/%{project_name}/%{project_name}.properties ]; then
   _log "[WARNING]  Default  %{project_name} configuration is applying"
   _log "[WARNING]    administrator.id=%{project_name}"
   _log "[WARNING]    password=%{project_name}"
   _log "[WARNING]    organization=default_organization"
   echo "-Dadministrator.id=\"%{project_name}\" -Dpassword=\"%{project_name}\"" > /etc/%{project_name}/%{project_name}.properties
   chown -R develenv:develenv /etc/%{project_name}/%{project_name}.properties
fi

[ "`grep \"^%{project_name}:\" /etc/passwd`" == "" ] && useradd %{project_name}
sed -i s:"/home/%{project_name}\:/bin/sh":"/home/%{project_name}\:/bin/bash":g /etc/passwd
_log "[INFO] Stoping %{project_name} if it is running"
if [ "$(chkconfig --list |grep %{project_name})" != "" ]; then
   if [ "$(service %{project_name} status 2>/dev/null|grep 'is running')" != "" ]; then
      _log "[INFO] Stoping %{project_name}"
      service %{project_name} stop
      _log "[INFO] develenv stopped $?"
   fi
fi
_log "[DEBUG] End pre-install"
exit 0
%post
#-------------------------------------------------------------------------------
# POST-INSTALL
#-------------------------------------------------------------------------------

restoreRPMSave(){
   cd /home/%{project_name}/app/jenkins/
   for fileConf in $(find . -maxdepth 1 -name "*.rpmsave" -maxdepth 1); do
      nameFile=$(echo $fileConf|sed s:".rpmsave$":"":g)
      cp ${nameFile} ${nameFile}.newconfig
      cp ${fileConf} ${nameFile}
   done;
}

cd /opt/%{org_acronynm}/%{project_name}/bin/
./install.sh -DrpmPhase=postInstall
errorInstall=$?
if [ "$errorInstall" != "0" ]; then
   _log "[ERROR] install.sh has failed in post-install phase but RPM has been installed"
   exit $errorInstall
fi
restoreRPMSave
#-------------------------------------------------------------------------------
# PRE-UNINSTALL
#-------------------------------------------------------------------------------
%preun
# Only do this if it's a remove
_log "[INFO] preUnInstall $1 $2 $3"
if [ "$1" = "0" ]; then
   _log "[INFO] preuninstall phase" 
   cd /opt/%{org_acronynm}/%{project_name}/bin/
   ./uninstall.sh -DrpmPhase=preUninstall
   errorUnInstall=$?
   if [ "$errorUnInstall" != "0" ]; then
      _log "[ERROR] uninstall.sh has failed in pre-un install phase but RPM has been removed"
      exit $errorUnInstall
   fi
fi

#-------------------------------------------------------------------------------
# POST-UNINSTALL
#-------------------------------------------------------------------------------
%postun
_log "[INFO] PostUnInstall $1 $2 $3"

# If this is an upgrade we need to maitain the jobs config files
if [ "$1" = "1" ]; then
   _log "[INFO] Post-uninstall Upgrade %{name}"
   # Buscar rpmsave en /home/develenv/app/jenkins/ y renombrarlos para que sean los 
   # ficheros de conf, luego verificar que no hay links rotos y borrar los que se encuentren
   RPMSAVED=$(find /home/%{project_name}/app/jenkins -name "*.rpmsave") 2>/dev/null

   cd /home/%{project_name}/app/jenkins
   for file in $RPMSAVED;
   do
      file=$(basename $file)
      fileNew=$(echo $file | sed s:\.rpmsave::g)
      mv $file $fileNew
      if [ ! -h "/etc/develenv/jenkins/$(basename $fileNew)" ]; then
         _log "[DEBUG] Create sinmbolic link for $fileNew"
         ln -s $fileNew /etc/%{project_name}/jenkins
      fi
   done
else
   if [ "$1" = "0" ]; then
      _log "[INFO] Post-uninstall Uninstall %{name}"
      # Uninstall tasks
      _log "[INFO] Doing uninstall tasks..."
      if [ -d "/home/%{project_name}" ]; then
         cd /home/%{project_name}
         _log "[INFO] Deleting broken links"
         rm -Rf $(find -L . -type l)
      fi
   fi
fi

#-------------------------------------------------------------------------------
# FILES
#-------------------------------------------------------------------------------
%files
%defattr(-,%{project_name},%{project_name},-)
/home/%{project_name}/
/var/%{project_name}/
/var/tmp/%{project_name}/tomcat/
/var/log/%{project_name}/tomcat/
/opt/ss/%{project_name}/
# Jenkins config files that we need to keep between updates
# General jenkins config
%config(noreplace) /home/%{project_name}/app/jenkins/config.xml
# Backup jenkins config
%config(noreplace) /home/%{project_name}/app/jenkins/backup.xml
# thinBackup jenkins config
%config(noreplace) /home/%{project_name}/app/jenkins/thinBackup.xml
# Console Parser plugin config
%config(noreplace) /home/%{project_name}/app/jenkins/consoleParser.conf
# Global Build Stats Plugin
%config(noreplace) /home/%{project_name}/app/jenkins/global-build-stats.xml
# Hudson pluings/models/tasks
%config(noreplace) /home/%{project_name}/app/jenkins/hudson.plugins.emailext.ExtendedEmailPublisher.xml
%config(noreplace) /home/%{project_name}/app/jenkins/hudson.plugins.google.analytics.GoogleAnalyticsPageDecorator.xml
%config(noreplace) /home/%{project_name}/app/jenkins/hudson.plugins.logparser.LogParserPublisher.xml
%config(noreplace) /home/%{project_name}/app/jenkins/hudson.plugins.sonar.SonarPublisher.xml
%config(noreplace) /home/%{project_name}/app/jenkins/hudson.plugins.sonar.SonarRunnerInstallation.xml
%config(noreplace) /home/%{project_name}/app/jenkins/hudson.scm.SubversionSCM.xml
%config(noreplace) /home/%{project_name}/app/jenkins/hudson.tasks.Ant.xml
%config(noreplace) /home/%{project_name}/app/jenkins/hudson.tasks.Mailer.xml
%config(noreplace) /home/%{project_name}/app/jenkins/hudson.tasks.Maven.xml
%config(noreplace) /home/%{project_name}/app/jenkins/hudson.tasks.Shell.xml
%config(noreplace) /home/%{project_name}/app/jenkins/sidebar-link.xml

