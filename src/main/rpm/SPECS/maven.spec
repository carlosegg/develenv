
# rpmbuild -bb SPECS/maven.spec --define '_topdir '`pwd` -v --clean
%define project_name develenv
%define org_acronynm ss
Name:       maven
Version:    3.2.5
Release:    2521.107.g2923249.%{os_release}
Summary:    Apache Maven is a software project management and comprehension tool.
Group:      develenv
License:    http://www.apache.org/licenses/LICENSE-2.0.html
Packager:   softwaresano.com
URL:        http://maven.apache.org/
Source0:    apache-%{package_name}-%{version}-bin.tar.gz
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   jdk >= 1.7 %{org_acronynm}-%{project_name}-user
Vendor:     tid.es
#Compatible with rh5.5
%define _binary_filedigest_algorithm  1
%define _binary_payload 1

%define package_name maven
%define target_dir  /opt/ss/develenv/platform/%{package_name}

%description
Apache Maven is a software project management and comprehension tool. Based on 
the concept of a project object model (POM), Maven can manage a project's build, 
reporting and documentation from a central piece of information.

%prep
#-------------------------------------------------------------------------------
# PREP
#-------------------------------------------------------------------------------
%{__mkdir_p} %{buildroot}
%setup -q -n apache-%{package_name}-%{version}

%install
#-------------------------------------------------------------------------------
# INSTALL
#-------------------------------------------------------------------------------
%{__mkdir_p} %{buildroot}/%{target_dir}
%{__mv} * %{buildroot}/%{target_dir}
# Added to avoid conflicts with yum upgrade and ss-develenv-config
rm -rf %{buildroot}/%{target_dir}/conf

%clean
#-------------------------------------------------------------------------------
# CLEAN
#-------------------------------------------------------------------------------
[ %{buildroot} != "/" ] && rm -rf %{buildroot}


%files
%defattr(-,develenv,develenv,-)
%{target_dir}
%post
#-------------------------------------------------------------------------------
# POST-INSTALL
#-------------------------------------------------------------------------------

# If it's maven without develenv. I need configure logging
if [ ! -f "%{target_dir}/conf/logging/simplelogger.properties" ]; then
   _log "[INFO] Configure logging properties"
   mkdir -p %{target_dir}/conf/logging/
   echo "
org.slf4j.simpleLogger.defaultLogLevel=info
org.slf4j.simpleLogger.showDateTime=false
org.slf4j.simpleLogger.showThreadName=false
org.slf4j.simpleLogger.showLogName=false
org.slf4j.simpleLogger.logFile=System.out
org.slf4j.simpleLogger.levelInBrackets=true
org.slf4j.simpleLogger.log.Sisu=info
org.slf4j.simpleLogger.warnLevelString=WARNING" > %{target_dir}/conf/logging/simplelogger.properties
   chown -R develenv:develenv %{target_dir}/conf
fi
#Create link /usr/bin
cd /usr/bin
rm -Rf mvn
_log "[INFO] Create links to /usr/bin"
ln -s %{target_dir}/bin/mvn .


%postun
#Remove broken link
cd /usr/bin
if [ -h "%{package_name}" ]; then
   rm -Rf $(find -L  %{package_name} -type l)
fi