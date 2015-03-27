# rpmbuild -bb SPECS/ant.spec --define '_topdir '`pwd` -v --clean
%define project_name develenv
%define org_acronynm ss
Name:       ant
Version:    1.9.4
Release:    2270.157
Summary:    Tool whose mission is to drive processes described in build files as targets and extension points dependent upon each other.
Group:      develenv
License:    http://www.apache.org/licenses/LICENSE-2.0.html
Packager:   softwaresano.com
URL:        http://ant.apache.org/
Source0:    apache-%{package_name}-%{version}-bin.tar.gz
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   %{org_acronynm}-%{project_name}-user jdk >= 1.7
Vendor:     tid.es

#Compatible with rh5.5
%define _binary_filedigest_algorithm  1
%define _binary_payload 1


%define package_name ant
%define target_dir  /opt/ss/develenv/platform/%{package_name}

%description
Apache Ant is a Java library and command-line tool whose mission is to drive processes described in build files as targets and extension points dependent upon each other. The main known usage of Ant is the build of Java applications. Ant supplies a number of built-in tasks allowing to compile, assemble, test and run Java applications. Ant can also be used effectively to build non Java applications, for instance C or C++ applications. More generally, Ant can be used to pilot any type of process which can be described in terms of targets and tasks.

%prep
%{__mkdir_p} %{buildroot}
%setup -q -n apache-%{package_name}-%{version}

%install
%{__mkdir_p} %{buildroot}/%{target_dir}
%{__mv} * %{buildroot}/%{target_dir}


%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}


%files
%defattr(-,develenv,develenv,-)
%{target_dir}


%changelog

