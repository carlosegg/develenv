# rpmbuild -bb SPECS/soapui.spec  --define '_topdir '`pwd`  -v --clean
%define project_name develenv
%define org_acronynm ss
Name:       soapui 
Summary:    develenv soapui
Version:    5.1.3
Release:    1
License:    None
Packager:   softwaresano.com
Group:      http://www.soapui.org/Developers-Corner/soapui-license.html
BuildArch:  noarch
Requires:   jdk >= 1.7 %{org_acronynm}-%{project_name}-user
Source:     SoapUI-%{version}-linux-bin.tar.gz
Vendor:     tid.es
BuildRoot:  %{_topdir}/BUILDROOT

%define     package_name soapui
%define     base_dir /opt/ss/develenv/platform
%define     target_dir %{base_dir}/%{package_name}/


%description
SoapUI is a free and open source cross-platform Functional Testing solution. With an easy-to-use graphical interface, and enterprise-class features, SoapUI allows you to easily and rapidly create and execute automated functional, regression, compliance, and load tests. In a single test environment, SoapUI provides complete test coverage and supports all the standard protocols and technologies. There are simply no limits to what you can do with your tests. Meet SoapUI, the world's most complete testing tool!

%prep
#-------------------------------------------------------------------------------
# PREP
#-------------------------------------------------------------------------------
%{__mkdir_p} %{buildroot}
%setup -q -n SoapUI-%{version}


%clean
[ "%{buildroot}" != "/" ] && %{__rm} -Rf "%{buildroot}"

%install
#-------------------------------------------------------------------------------
# INSTALL
#-------------------------------------------------------------------------------
%{__mkdir_p} %{buildroot}/%{target_dir} 
%{__mv} * %{buildroot}/%{target_dir}

%files
%attr (-,develenv,develenv) %{target_dir}
