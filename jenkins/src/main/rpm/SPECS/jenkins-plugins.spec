# rpmbuild -bb SPECS/jenkins-plugins.spec --define '_topdir '`pwd` -v --clean
%{!?redhat_version: %global redhat_version %(cat /etc/redhat-release |sed s:'.*release ':'':g|awk '{print $1}'|cut -d '.' -f1)}

Name:       jenkins-plugins
Version:    2538.%{versionModule}
Release:    136.26.g336e1b5.%{os_release}
Summary:    Plugins for jenkins
Group:      develenv
License:    http://creativecommons.org/licenses/by/3.0/
Packager:   softwaresano.com
URL:        http://jenkins-ci.org/
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   ss-develenv-jenkins >= 1.644-27.g75d63d9.%{os_release} ss-develenv-sonar-runner >= 2.4-2295.174 graphviz subversion mercurial git lcov sloccount
Vendor:     tid.es

%define jenkins_plugins_path jenkins/plugins
%define target_dir  /var/develenv/%{jenkins_plugins_path}

%description
Plugins for jenkins

#-------------------------------------------------------------------------------
# INSTALL
#-------------------------------------------------------------------------------
%install
%{__mkdir_p} %{buildroot}/%{target_dir}
# Added %{_sourecdir} to avoid conflicts in changes on _topdir
cp %{_sourcedir}/../../config/plugins/*  %{buildroot}/%{target_dir}
#-------------------------------------------------------------------------------
# POST-INSTALL
#-------------------------------------------------------------------------------
%postun
# Deleting all dir on /var/develenv/jenkins/plugins to clean the environment
if [ -d "%{target_dir}" ]; then
  rm -rf $(find "%{target_dir}" -maxdepth 1 -type d |\
         grep -v "%{target_dir}$")
  # Deleting jpi files to put new versions
  rm -Rf "%{target_dir}"/{cvs.jpi,mailer.jpi,maven-plugin.jpi,\
         pam-auth.jpi,ssh-slaves.jpi,subversion.jpi,translation.jpi}
fi
#-------------------------------------------------------------------------------
# CLEAN
#-------------------------------------------------------------------------------
%clean
[ %{buildroot} != "/" ] && rm -rf %{buildroot}

%files
%defattr(-,develenv,develenv,-)
%{target_dir}