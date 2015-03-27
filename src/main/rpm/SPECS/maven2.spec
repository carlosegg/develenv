
# rpmbuild -bb SPECS/maven.spec --define '_topdir '`pwd` -v --clean
%define project_name develenv
%define org_acronynm ss
Name:       maven2
Version:    2.2.1
Release:    2
Summary:    Apache Maven is a software project management and comprehension tool.
Group:      develenv
License:    http://www.apache.org/licenses/LICENSE-2.0.html
Packager:   softwaresano.com
URL:        http://maven.apache.org/
Source0:    apache-%{real_name}-%{version}-bin.tar.gz
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   jdk >= 1.7 %{org_acronynm}-%{project_name}-user
Vendor:     tid.es

%define real_name maven
%define package_name %{real_name}2
%define target_dir  /opt/ss/develenv/platform/%{package_name}

%description
Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can manage a project's build, reporting and documentation from a central piece of information.

%prep
%{__mkdir_p} %{buildroot}
%setup -q -n apache-%{real_name}-%{version}

%install
%{__mkdir_p} %{buildroot}/%{target_dir}
%{__mv} * %{buildroot}/%{target_dir}
# Added to avoid conflicts with yum upgrade and ss-develenv-config
rm -rf %{buildroot}/%{target_dir}/conf 

%clean
[ %{buildroot} != "/" ] && rm -rf %{buildroot}


%files
%defattr(-,develenv,develenv,-)
%{target_dir}


%changelog

