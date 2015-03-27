%define project_name develenv
%define org_acronynm ss
Name:      docs
Version:   %{versionModule}
Release:   %{releaseModule}
Summary:   Documentación del Ecosistema de integración contínua
Group:     develenv 
License:   GPL 3.0
Packager:  ss
BuildArch: noarch
BuildRoot: %{_topdir}/BUILDROOT
Vendor:    SoftwareSano.com
Requires:  %{org_acronynm}-%{project_name}-user


%description
%{project_name} proporciona una solución para la automatización del proceso de construcción, testing y despliegue de software. En este paquete se incluye la documentación del mismo.
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
# Deleting everthing except the docs
rm -rf $RPM_BUILD_ROOT/{home,opt,etc}
rm -rf $RPM_BUILD_ROOT/var/%{project_name}/{jenkins,maven,nexus,plugins,repositories,sites,sonar}
rm -rf $RPM_BUILD_ROOT/var/log/%{project_name}
rm -rf $RPM_BUILD_ROOT/var/tmp/%{project_name}


%files
%defattr(-,%{project_name},%{project_name},-)
/var/%{project_name}/docs
/var/%{project_name}/.htaccess

%post
SELinux=$(sestatus |grep "SELinux status:"|cut -d':' -f2|awk '{print $1}')
_log "[INFO] Selinux: $SELinux"
if [ "$SELinux" == "enabled" ]; then
   # Changing security context of files (SELinux)
   _log "[INFO] Enabling http access in selinux"
   chcon -R --type=httpd_sys_content_t /var/%{project_name}/docs
   chcon --type=httpd_sys_content_t /var/%{project_name}/.htaccess
fi
%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*
