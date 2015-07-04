%{!?mysql_dependency: %global mysql_dependency %([[ "$(cat /etc/redhat-release |sed s:'.*release ':'':g|awk '{print $1}'|cut -d '.' -f1)" == "7" ]] && echo mariadb || echo mysql)}

mysql_package
Name:       sonar-db
Version:    5.1.1
Release:    2542.4
Summary:    Sonar database
Group:      develenv
License:    http://www.sonarsource.org/support/license/
Packager:   softwaresano.com
URL:        http://www.sonarsource.org
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   %{mysql_dependency}-server >= 5.1 ss-develenv-user
Vendor:     tid.es
AutoReqProv:no

%define package_name sonar-db
%define target_dir /var/develenv/sonar
%define projectName develenv 

%description
Sonar database


%install
%{__mkdir_p} %{buildroot}/%{target_dir}
cd %{buildroot}/%{target_dir}

# Copying scriptDB
cp %{_sourcedir}/../../scripts/installSonarDB.sh %{buildroot}/%{target_dir}
chmod u+x %{buildroot}/%{target_dir}/installSonarDB.sh
%clean
[ %{buildroot} != "/" ] && rm -rf %{buildroot}


%files
%defattr(-,%{projectName},%{projectName},-)
%{target_dir}

%post

# In this section we are gonna put the creation of the database executing an 
# script that we have installed on the install section!
if ! [ -f /etc/%{projectName}/%{projectName}.properties ]; then
   _log "[WARNING] Aplicando Configuración por defecto de %{projectName}"
   _log "[WARNING]    administrator.id=%{projectName}"
   _log "[WARNING]    password=%{projectName}"
   _log "[WARNING]    organization=default_organization"
   mkdir -p /etc/%{projectName} 
   echo "-Dadministrator.id=\"%{projectName}\" -Dpassword=\"%{projectName}\"" > /etc/%{projectName}/%{projectName}.properties
   chown develenv:develenv /etc/%{projectName}/%{projectName}.properties
fi
password=$(sed s:".*-Dpassword=":"":g /etc/%{projectName}/%{projectName}.properties |awk '{ print $1 }'|sed s:"\"":"":g)
administratorId=$(sed s:".*-Dadministrator.id=":"":g /etc/%{projectName}/%{projectName}.properties |awk '{ print $1 }'|sed s:"\"":"":g)
cd %{target_dir}
sed -i s:"\${projectName}":"%{projectName}":g installSonarDB.sh
sed -i s:"\${sonar.user}":"$administratorId":g installSonarDB.sh
sed -i s:"\${sonar.jdbc.password}":"$password":g installSonarDB.sh
if [ "$1" = "1" ]; then
   _log "[INFO] Creating sonarDB"
   ./installSonarDB.sh
else
   _log "[WARNING] This is an update. If you update the sonar db, you execute:"
   _log "[WARNING]     sudo %{target_dir}/installSonarDB.sh "
   _log "[WARNING] The old database will be remove. You can do a backup with:"
   _log "[WARNING]     sudo mysqldump --opt --password=<password> --user=root sonar"
fi

%changelog
