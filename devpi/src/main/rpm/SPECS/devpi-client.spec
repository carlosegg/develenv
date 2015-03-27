# rpmbuild -bb SPECS/devpi-client.spec  --define '_topdir '`pwd`  -v --clean
%define project_name develenv
%define org_acronynm ss
Name:       devpi-client
Summary:    client reliable fast pypi.python.org caching
Version:    2.0.5
Release:    1
License:    http://opensource.org/licenses/MIT
Packager:   softwaresano.com
Group:      develenv
BuildArch:  x86_64
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   %{org_acronynm}-%{project_name}-user httpd
Vendor:     softwaresano.com
Source0:    devpi-client-%{version}.tar.gz


%define package_name devpi-client
%define target_dir /opt/ss/develenv/platform/%{package_name}/
%define home_dir   /home
%define config_dir /etc
%define data_dir   /var/develenv/repositories
%define devpi_scripts devpi devpi-upload.sh


# Redefine post install macros 
%define __os_install_post    \
    /usr/lib/rpm/redhat/brp-compress \
    %{!?__debug_package:/usr/lib/rpm/redhat/brp-strip %{__strip}} \
    /usr/lib/rpm/redhat/brp-strip-static-archive %{__strip} \
    /usr/lib/rpm/redhat/brp-strip-comment-note %{__strip} %{__objdump} \
    %{!?__jar_repack:/usr/lib/rpm/redhat/brp-java-repack-jars} \
%{nil}

%description
reliable fast pypi.python.org caching server

%prep
%setup -q -n devpi-client-%{version}
%{__mkdir_p} %{buildroot}

%install
mkdir -p %{buildroot}/%{target_dir}/bin %{buildroot}/%{target_dir}/lib/python2.6/site-packages/

PYTHONPATH=%{buildroot}/%{target_dir}/lib/python2.6/site-packages/ python setup.py install --prefix %{buildroot}/%{target_dir}


cd %{buildroot}/%{target_dir}/bin
cp %{_sourcedir}/../../scripts/devpi-upload.sh .


%post
#-------------------------------------------------------------------------------
# POST-INSTALL
#-------------------------------------------------------------------------------
#Create link /usr/bin
_log "[INFO] Creating devpi scripts links in /usr/bin" 
cd /usr/bin
for s in %{devpi_scripts}; do
    script="${s}"
    _log "[DEBUG] Creating $script links in /usr/bin" 
    rm -Rf $script
    ln -s %{target_dir}bin/${script}
done;

%postun
#-------------------------------------------------------------------------------
# POST-UNINSTALL
#-------------------------------------------------------------------------------
#Remove broken link
cd /usr/bin
_log "[INFO] Removing devpi scripts symbolic links" 
for s in %{devpi_scripts}; do
    script="${s}"
    if [ -h "$script" ]; then
        rm -Rf $(find -L $script -type l)
    fi
done;


%files
%defattr(-,develenv,develenv,-)
%{target_dir}


%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*
