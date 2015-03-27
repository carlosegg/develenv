# rpmbuild -bb SPECS/sonar-runner.spec --define '_topdir '`pwd` -v --clean

Name:       sonar-runner
Version:    2.4
Release:    2295.174
Summary:    Sonar client for analyzing code quality
Group:      develenv
License:    http://www.gnu.org/licenses/lgpl.txt
Packager:   softwaresano.com
URL:        http://docs.codehaus.org/display/SONAR/Analyzing+with+SonarQube+Runner
Source0:    %{package_name}-dist-%{version}.zip
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   jdk > 1.7 php-xml
Vendor:     tid.es
#Compatible with rh5.5
%define _binary_filedigest_algorithm  1
%define _binary_payload 1


%define package_name sonar-runner
%define project_parent_name develenv
%define target_dir  /opt/ss/%{project_parent_name}/platform/

%description
The Sonar Runner plugin provides integration with Sonar, a web-based 
platform for monitoring code quality. It is based on the Sonar Runner, a Sonar 
client component that analyzes source code and build outputs, 
and stores all collected information in the Sonar database.


%install
%{__mkdir_p} %{buildroot}/%{target_dir}
cd  %{buildroot}/%{target_dir}
unzip %{SOURCE0}
mv  %{package_name}-%{version} %{package_name}
mv  %{package_name}/conf/%{package_name}.properties \
             %{package_name}/conf/%{package_name}.properties.sample

%clean
[ %{buildroot} != "/" ] && rm -rf %{buildroot}

%pre
#Create develenv user if not exists
# Creating develenv user if the installations is out of develenv
 id -u %{project_parent_name} || useradd -s /bin/bash %{project_parent_name}

%post
# Message configure sonar-runner out of develenv
# Installation out of develenv
[ -f /etc/%{project_parent_name}/%{package_name}/%{package_name}.properties ] || \
  echo "You must configure sonar-runer.
         mv  %{package_name}/conf/%{package_name}.properties.sample \\
             %{package_name}/conf/%{package_name}.properties
         Edit %{package_name}/conf/%{package_name}.properties"

#Create link /usr/bin
cd /usr/bin
rm -Rf %{package_name}
ln -s %{target_dir}/%{package_name}/bin/%{package_name} .

%files
%defattr(-,%{project_parent_name},%{project_parent_name},-)
%{target_dir}

%postun
#Remove broken link
cd /usr/bin
if [ -h "%{package_name}" ]; then
   rm -Rf $(find -L  %{package_name} -type l)
fi

%changelog

