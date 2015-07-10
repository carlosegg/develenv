#rpmbuild -v --clean --define '_buildshell '/bin/bash' \
#--define '_topdir '/home/carlosg/workspace/develenv/target/.rpm \
#--define 'versionModule '1 --define 'releaseModule '2 \
#-bb /var/tmp/rpm/ss-develenv-allInOne-1-2/ss-develenv-config.spec

%define project_name develenv
%define org_acronynm ss
Name: config
Summary: Paquete de configuración de develenv
Version: %{versionModule}
Release: %{releaseModule}
License: GPL 3.0
Packager: ss
Group: develenv
BuildArch: noarch
BuildRoot: %{_topdir}/BUILDROOT
Requires: %{org_acronynm}-%{project_name}-user
Vendor: SoftwareSano.com

%define _binaries_in_noarch_packages_terminate_build 0

%description
%{project_name} proporciona una solución para la automatización del proceso
de construcción, testing y despliegue de software.
Consulta http://develenv.softwaresano.com

%prep
#_log "Building package %{name}-%{version}-%{release}"
source_file="`find $PWD/../../../site/assemblies/ -name \"%{project_name}-*.sh\"`"
[ "${source_file}" == "" ] && _log "[ERROR] $PWD/../../../site/assemblies/%{project_name}-*.sh doesn't exit" && exit 1
sLines=$(head -n4 $source_file | grep scriptLines| cut -d= -f2)
head -n$sLines $source_file|egrep "size|tail"|grep -v /dev/null|sed s:"\$0":"$source_file":g > .rpmDecompress.sh
chmod 755 .rpmDecompress.sh
./.rpmDecompress.sh
rm -Rf .rpmDecompress.sh
rm -Rf $RPM_BUILD_ROOT
%{__mkdir_p} $RPM_BUILD_ROOT/
baseFile=`basename $source_file|sed s:"\.sh":"":g`
cd $RPM_BUILD_ROOT
tar xvfz $RPM_BUILD_DIR/$baseFile/${baseFile}-install.tar.gz
rm -Rf $RPM_BUILD_DIR/$baseFile/${baseFile}-install.tar.gz
# Borramos todo menos la configuración de /etc
rm -rf $RPM_BUILD_ROOT/{home,var,opt}
rm -rf $RPM_BUILD_ROOT/etc/yum.repos.d/
cd $RPM_BUILD_ROOT/etc/
find . -name "*.sh" -exec chmod 755 {} \;

%files
%defattr(-,%{project_name},%{project_name},755)
%config(noreplace) /etc/%{project_name}
%config(noreplace) /etc/httpd/conf.d/%{project_name}.conf
%config(noreplace) /etc/httpd/conf.d/%{project_name}.conf.d

%pre
#-----------------------------------------------------------------------------
# PRE-INSTALL
#-----------------------------------------------------------------------------
[ "`grep \"^%{project_name}:\" /etc/passwd`" == "" ] && useradd %{project_name}
sed -i s:"/home/%{project_name}\:/bin/sh":"/home/%{project_name}\:/bin/bash":g /etc/passwd

%post
#-----------------------------------------------------------------------------
# POST-INSTALL
#-----------------------------------------------------------------------------
restoreRPMSave(){
cd /etc/%{project_name}
for fileConf in $(find . -name "*.rpmsave"); do
nameFile=$(echo $fileConf|sed s:".rpmsave$":"":g)
echo "`date` cp ${nameFile} ${nameFile}.newconfig" >>/tmp/borrame
cp ${nameFile} ${nameFile}.newconfig
echo "`date` cp ${fileConf} ${nameFile}" >>/tmp/borrame
cp ${fileConf} ${nameFile}
done;
}
restoreRPMSave

%postun
#-----------------------------------------------------------------------------
# POST-UNINSTALL
#-----------------------------------------------------------------------------
# If this is an upgrade we need to maitain the jobs config files
if [ "$1" = "1" ]; then
_log "[INFO] This is a upgrade. We need to maintain the job config files"
# Buscar rpmsave en /home/develenv/app/jenkins/ y renombrarlos para que sean los
# ficheros de conf, luego verificar que no hay links rotos y borrar los que se encuentren
jenkins_home="/home/%{project_name}/app/jenkins"
if [ -d "$jenkins_home" ]; then
_log "[INFO] Restoring jenkins configuration"
cd "$jenkins_home"
nRpmSave=$(find "$jenkins_home" -maxdepth 1 -type f -name "*.rpmsave"|wc -l)
if [ "$nRpmSave" != "0" ]; then
while read file
do
file=$(basename "$file")
fileNew=$(echo $file | sed s:\.rpmsave::g)
mv "$file" "$fileNew"
rm -f "/etc/%{project_name}/jenkins/$fileNew"
ln -s "$fileNew" "/etc/%{project_name}/jenkins"
_log "[INFO] Restore /etc/%{project_name}/jenkins/$fileNew"
done <$(find "$jenkins_home" -maxdepth 1 -type f -name "*.rpmsave")
fi
fi
# Upgraded nexus security-configuration.xml
_log "[INFO] Patching develenv configuration"
_log "[INFO] Patching nexus security-configuration.xml"
sed -i s:"<enabled>true</enabled>":"":g /etc/%{project_name}/nexus/security-configuration.xml
sed -i s:"<version>.*</version>":"<version>2.0.7</version>":g /etc/develenv/nexus/security-configuration.xml
# Upgrading tomcat 8.0 configuration
# Disable JasperListner in tomcat 8
if [ -f "/etc/develenv/tomcat/server.xml" ]; then
sed -i s:'<Listener className="org.apache.catalina.core.JasperListener" />':'':g /etc/develenv/tomcat/server.xml
fi
else
if [ "$1" = "0" ]; then
# Uninstall tasks
_log "[INFO] Uninstall develenv"
fi
fi

%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*