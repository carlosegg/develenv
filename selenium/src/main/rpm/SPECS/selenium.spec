# rpmbuild -bb SPECS/selenium.spec  --define '_topdir '`pwd`  -v --clean
%define project_name develenv
%define org_acronynm ss
Name:       selenium
Summary:    Selenium automates browsers
Version:    2.46.0
Release:    2536.8.%{os_release}
License:    http://www.apache.org/licenses/LICENSE-2.0
Packager:   softwaresano.com
Group:      develenv
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   jdk >= 1.7 %{org_acronynm}-%{project_name}-user firefox google-chrome-stable = 26.0.1410.63
Vendor:     tid.es
Source0:    %{package_name}-server-standalone-%{version}.jar

%define package_name selenium
%define target_dir /opt/ss/develenv/platform/%{package_name}

%description
Selenium automates browsers. That's it. What you do with that power is entirely
up to you. Primarily it is for automating web applications for testing purposes,
 but is certainly not limited to just that. Boring web-based administration 
tasks can (and should!) also be automated as well.

Selenium has the support of some of the largest browser vendors who have taken
(or are taking) steps to make Selenium a native part of their browser. It is
also the core technology in countless other browser automation tools, 
APIs and frameworks.

%install
%{__mkdir_p} %{buildroot}/%{target_dir} 
%{__cp} %{SOURCE0} %{buildroot}/%{target_dir}/%{package_name}-server-standalone.jar

# Copying scripts
%{__mkdir_p} %{buildroot}/%{target_dir}/bin
%{__cp} -r %{_sourcedir}/../../scripts/* %{buildroot}/%{target_dir}/bin
# Added to filter script that is done via ant on sh install
sed -i s:"\${PROJECT_HOME}":"/home/develenv":g %{buildroot}/%{target_dir}/bin/%{package_name}.sh

%files
%defattr(-,develenv,develenv,-)
%{target_dir}

%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*
