%define project_name develenv
%define org_acronynm ss
Name:       tomcat
Version:    8.0.20
Release:    2535.121
Summary:    Apache Tomcat is an open source software implementation of the Java Servlet and JavaServer Pages technologies.
Group:      develenv
License:    http://www.apache.org/licenses/LICENSE-2.0.html
Packager:   softwaresano.com
URL:        http://tomcat.apache.org/
Source0:    apache-%{package_name}-%{version}.tar.gz
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   jdk >= 1.7 %{org_acronynm}-%{project_name}-user
Vendor:     tid.es

%define package_name tomcat
%define target_dir  /opt/ss/develenv/platform/%{package_name}

%description
Apache Tomcat is an open source software implementation of the Java Servlet and 
JavaServer Pages technologies. The Java Servlet and JavaServer Pages 
specifications are developed under the Java Community Process.

#-------------------------------------------------------------------------------
# CLEAN
#-------------------------------------------------------------------------------
%clean
[ %{buildroot} != "/" ] && rm -rf %{buildroot}

#-------------------------------------------------------------------------------
# PREP
#-------------------------------------------------------------------------------
%prep
%{__mkdir_p} %{buildroot}
%setup -q -n apache-%{package_name}-%{version}

#-------------------------------------------------------------------------------
# INSTALL
#-------------------------------------------------------------------------------
%install
%{__mkdir_p} %{buildroot}/%{target_dir}
rm -rf webapps/examples
rm -rf webapps/docs
rm -rf temp/*
%{__mv} * %{buildroot}/%{target_dir}
# Added to avoid conflicts with yum upgrade and ss-develenv-config
rm -rf %{buildroot}/%{target_dir}/conf 
 
#-------------------------------------------------------------------------------
# POST-INSTALL
#-------------------------------------------------------------------------------
%post
_log "[INFO] Removing cache and temporal files"
rm -rf %{target_dir}/temp/* %{target_dir}/work/* %{target_dir}/conf/Catalina/*
# Disable JasperListner in tomcat 8
if [ -f "/etc/develenv/tomcat/server.xml" ]; then
   sed -i s:'<Listener className="org.apache.catalina.core.JasperListener" />':'':g /etc/develenv/tomcat/server.xml
fi

%files
%defattr(-,develenv,develenv,-)
%{target_dir}