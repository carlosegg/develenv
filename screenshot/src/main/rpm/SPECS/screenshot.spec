# rpmbuild -bb SPECS/screenshot.spec  --define '_topdir '`pwd`  -v --clean
%define     project_name develenv
%define     org_acronym ss
Name:       screenshot
Summary:    Screenshot of a web page
Version:    %{versionModule}
Release:    3
License:    http://www.apache.org/licenses/LICENSE-2.0
Packager:   softwaresano.com
Group:      develenv
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   %{org_acronym}-%{project_name}-selenium >= 2.44.0 python >= 2.6 python26-selenium >= 2.44.0 python26-PIL php >= 5.3.3  %{org_acronym}-%{project_name}-user
Vendor:     softwaresano.com

%define package_name selenium-screenshot
%define target_dir /var/%{project_name}/%{package_name}

%description
it captures a screenshot of a web page. Also captures a portion of web page

%install
%{__mkdir_p} %{buildroot}/
cp -R %{_sourcedir}/* %{buildroot}
chcon -Rv --type=httpd_sys_content_t  %{buildroot}

# Copying scripts

%files
%defattr(-,develenv,develenv,-)
/

%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*
