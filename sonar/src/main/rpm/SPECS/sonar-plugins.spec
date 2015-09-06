# rpmbuild -bb SPECS/sonar-plugins.spec --define '_topdir '`pwd` -v --clean

Name:       sonar-plugins
Version:    2544.37
Release:    142.19.g1b2740a.%{os_release}
Summary:    Plugins for sonar
Group:      develenv
License:    http://www.gnu.org/licenses/quick-guide-gplv3.html
Packager:   softwaresano.com
URL:        http://docs.codehaus.org/display/SONAR/Plugin+Library
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   ss-develenv-sonar >= 5.1.2-19.g1b2740a.%{os_release}
Vendor:     tid.es

%define sonar_plugins_path sonar/extensions/plugins
%define target_dir  /var/develenv/%{sonar_plugins_path}

%description
Plugins for Sonar 


%install
# ------------------------------------------------------------------------------
# INSTALL
# ------------------------------------------------------------------------------
%{__mkdir_p} %{buildroot}/%{target_dir}
# Added %{_sourecdir} to avoid conflicts in changes on _topdir
cp %{_sourcedir}/plugins/*  %{buildroot}/%{target_dir}


%clean
# ------------------------------------------------------------------------------
# CLEAN
# ------------------------------------------------------------------------------
[ %{buildroot} != "/" ] && rm -rf %{buildroot}

%files
%defattr(-,develenv,develenv,-)
%{target_dir}

%pre
# ------------------------------------------------------------------------------
# PRE-INSTALL
# ------------------------------------------------------------------------------

# Remove old java ecosystem
if [ -d "%{target_dir}" ]; then
    cd %{target_dir}
    _log "[INFO] Remove old java ecosystem plugins"
    rm -f sonar-checkstyle-plugin-*.jar
    rm -f sonar-cobertura-plugin-*.jar
    rm -f sonar-findbugs-plugin-*.jar
    rm -f sonar-jacoco-plugin-*.jar
    rm -f sonar-java-plugin-*.jar
    rm -f sonar-pmd-plugin-*.jar
    rm -f sonar-squid-java-plugin-*.jar
    rm -f sonar-surefire-plugin-*.jar
fi

%changelog
