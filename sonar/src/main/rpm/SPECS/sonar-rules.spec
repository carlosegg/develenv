
# rpmbuild -bb SPECS/sonar-rules.spec --define '_topdir '`pwd` -v --clean

Name:       sonar-rules
Version:    3
Release:    2054.1.g2923249.%{os_release}
Summary:    Rules for sonar
Group:      develenv
License:    http://www.gnu.org/licenses/quick-guide-gplv3.html
Packager:   softwaresano.com
URL:        http://docs.codehaus.org/display/SONAR/Plugin+Library
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   ss-develenv-sonar >= 4.1-2054.2
Vendor:     tid.es

%define sonar_rules_path sonar/extensions/rules
%define target_dir  /var/develenv/%{sonar_rules_path}

%description
Rules for Sonar 
%install
#-------------------------------------------------------------------------------
# INSTALL
#-------------------------------------------------------------------------------
%{__mkdir_p} %{buildroot}/%{target_dir}
# Added %{_sourecdir} to avoid conflicts in changes on _topdir
cp -r %{_sourcedir}/rules/*  %{buildroot}/%{target_dir}

%clean
#-------------------------------------------------------------------------------
# CLEAN
#-------------------------------------------------------------------------------
[ %{buildroot} != "/" ] && rm -rf %{buildroot}


%files
%defattr(-,develenv,develenv,-)
%{target_dir}


%changelog

