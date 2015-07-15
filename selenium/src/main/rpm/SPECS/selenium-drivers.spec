# rpmbuild -bb SPECS/selenium-drivers.spec  --define '_topdir '`pwd`  -v --clean
%define project_name develenv
%define org_acronynm ss
Name:       selenium-drivers
Summary:    Selenium Webdrivers for Google Chrome
Version:    26.0.1383
Release:    2236.130.%{os_release}
License:    http://opensource.org/licenses/BSD-3-Clause
Packager:   softwaresano.com
Group:      develenv
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   jdk >= 1.7 %{org_acronynm}-%{project_name}-user %{org_acronynm}-%{project_name}-selenium >= 2.41.0-2236.130
Vendor:     tid.es


%define driver0 chromedriver_linux32_%{version}.0.zip
%define driver1 chromedriver_linux64_%{version}.0.zip
%define package_name selenium/drivers
%define target_dir /opt/ss/develenv/platform/%{package_name}/
%define _binaries_in_noarch_packages_terminate_build 0

%description
WebDriver is an open source tool for automated testing of webapps across many 
browsers. It provides capabilities for navigating to web pages, user input, 
JavaScript execution, and more. ChromeDriver is a standalone server which 
implements WebDriver's wire protocol for Chromium. It is being developed 
by members of the Chromium and WebDriver teams.

All code is currently in the open source chromium project. This site hosts 
ChromeDriver documentation, issue tracking, and releases.
#-------------------------------------------------------------------------------
# CLEAN
#-------------------------------------------------------------------------------
%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*

#-------------------------------------------------------------------------------
# INSTALL
#-------------------------------------------------------------------------------
%install
%{__mkdir_p} %{buildroot}%{target_dir}
%{__unzip} %{_sourcedir}/drivers/%{driver1} -d %{buildroot}%{target_dir}
%{__mv} %{buildroot}%{target_dir}/chromedriver \
        %{buildroot}%{target_dir}/chromedriver-x86_64

%files
%defattr(-,develenv,develenv,-)
%{target_dir}

