# rpmbuild -bb SPECS/jmeter.spec  --define '_topdir '`pwd`  -v --clean
%define project_name develenv
%define org_acronynm ss
Name:       jmeter
Summary:    application designed to load test functional behavior and mesure performance
Version:    2.13
Release:    1
License:    http://www.apache.org/licenses/LICENSE-2.0
Packager:   softwaresano.com
Group:      develenv
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   jdk >= 1.7 %{org_acronynm}-%{project_name}-user
Vendor:     tid.es
Source0:    apache-%{package_name}-%{version}.tgz

%define package_name jmeter
%define target_dir /opt/ss/develenv/platform/%{package_name}/

#Compatible with rh5.5
%define _binary_filedigest_algorithm  1
%define _binary_payload 1

%description
Apache JMeter™ is a 100% pure Java desktop application
designed to load test functional behavior and measure
performance. It was originally designed for testing
Web Applications but has since expanded to other test
functions.

%prep
%{__mkdir_p} %{buildroot}
%setup -q -n apache-%{package_name}-%{version}

%install
%{__mkdir_p} %{buildroot}/%{target_dir} 
%{__mv} * %{buildroot}/%{target_dir}

%files
%defattr(-,develenv,develenv,-)
%{target_dir}

%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*
