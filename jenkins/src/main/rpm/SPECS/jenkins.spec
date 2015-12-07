# rpmbuild -bb SPECS/jenkins.spec --define '_topdir '`pwd` -v --clean

Name:       jenkins
Version:    1640
Release:    26.g336e1b5.%{os_release}
Summary:    An extendable open source continuous integration server
Group:      develenv
License:    http://creativecommons.org/licenses/by/3.0/
Packager:   softwaresano.com
URL:        http://jenkins-ci.org/
Source0:    %{package_name}.war
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   ss-develenv-tomcat >= 8.0.20-2535.121
Vendor:     tid.es

%define package_name jenkins
%define tomcat_webapps tomcat/webapps
%define target_dir  /opt/ss/develenv/platform/%{tomcat_webapps}/%{package_name}

%description
Jenkins is an award-winning application that monitors executions of repeated jobs,
 such as building a software project or jobs run by cron. Among those things, 
current Jenkins focuses on the following two jobs:

1 - Building/testing software projects continuously, just like CruiseControl or 
DamageControl. In a nutshell, Jenkins provides an easy-to-use so-called 
continuous integration system, making it easier for developers to integrate
changes to the project, and making it easier for users to obtain a fresh build. 
The automated, continuous build increases the productivity.

2 - Monitoring executions of externally-run jobs, such as cron jobs and procmail
jobs, even those that are run on a remote machine. For example, with cron, all 
you receive is regular e-mails that capture the output, and it is up to you to
 look at them diligently and notice when it broke. Jenkins keeps those outputs
and makes it easy for you to notice when something is wrong.

# ------------------------------------------------------------------------------
# CLEAN
# ------------------------------------------------------------------------------
%clean
[ %{buildroot} != "/" ] && rm -rf %{buildroot}

# ------------------------------------------------------------------------------
# INSTALL
# ------------------------------------------------------------------------------
%install
%{__mkdir_p} %{buildroot}/%{target_dir}
cd  %{buildroot}/%{target_dir}
unzip %{SOURCE0}
# Remove pinned plugins except maven-plugin
cd WEB-INF/plugins/
rm $(ls |grep -v maven-plugin.*)


# ------------------------------------------------------------------------------
# PRE-INSTALL
# ------------------------------------------------------------------------------
%pre
# Deleting jenkins dir on tomcat to assure the update of jenkins
 rm -Rf %{target_dir}

%files
%defattr(-,develenv,develenv,-)
%{target_dir}

%changelog

