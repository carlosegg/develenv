# rpmbuild -bb SPECS/devpi-server.spec  --define '_topdir '`pwd`  -v --clean
%define project_name develenv
%define org_acronynm ss
Name:       devpi-server
Summary:    reliable fast pypi.python.org caching server
Version:    2.1.0
Release:    3
License:    http://opensource.org/licenses/MIT
Packager:   softwaresano.com
Group:      develenv
BuildArch:  x86_64
BuildRoot:  %{_topdir}/BUILDROOT
AutoReqProv:no
Requires:   %{org_acronynm}-%{project_name}-user httpd python-libs glibc bash coreutils
Vendor:     softwaresano.com

%define package_name devpi-server
%define target_dir /opt/ss/develenv/platform/%{package_name}/
%define home_dir   /home
%define config_dir /etc
%define data_dir   /var/develenv/repositories/devpi
%{!?python_dependency: %global python_dependency %([[ "$(cat /etc/redhat-release |sed s:'.*release ':'':g|awk '{print $1}'|cut -d '.' -f1)" == "6" ]] && echo python2.6 || echo python2.7)}


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

%install
function install_library(){
  local source_file=$1
  tar xvfz %{_sourcedir}/${source_file}.tar.gz
  cd $source_file
  echo "Installing $source_file"
  PYTHONPATH=%{buildroot}/%{target_dir}/lib/%{python_dependency}/site-packages/ python setup.py install --prefix %{buildroot}/%{target_dir}
  cd ../
}
PYTHONPATH=""
unset PYTHONPATH
mkdir -p %{buildroot}/%{target_dir}/lib/%{python_dependency}/site-packages/
#for library in supervisor-3.1.3 Pygments-2.0.2 WebOb-1.4.1 PasteDeploy-1.5.2 Chameleon-2.22 pyramid_chameleon-0.3 hgdistver-0.25 pip-6.0.8 pbr-0.10.8 devpi-%{version} devpi-web-2.2.3; do


for library in supervisor-3.1.3 hgdistver-0.25 pip-6.0.8 pbr-0.10.8 devpi-%{version} devpi-web-2.2.3; do
  install_library $library
done


cd %{buildroot}
cp -R %{_sourcedir}/%{config_dir} .
cp -R %{_sourcedir}/%{home_dir} .
cp %{_sourcedir}/../../scripts/init-devpi.sh %{buildroot}/%{target_dir}/bin
mkdir -p %{buildroot}/%{data_dir}
 

%post
#------------------------------------------------------------------------------
# POST-INSTALL
#------------------------------------------------------------------------------
function configure_iptables(){
      if [ -f "/etc/sysconfig/iptables" ]; then
         isRHFirewall=$(grep "\-A RH-Firewall " /etc/sysconfig/iptables)
         if ! [ -z $isRHFirewall ]; then
            ENABLED_HTTP=$(grep "\-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT" /etc/sysconfig/iptables) 
            if [ "$ENABLED_HTTP" == "" ]; then
               sed -i s:"-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT":"-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT\n-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT":g /etc/sysconfig/iptables
            fi
         else
            ENABLED_HTTP=$(grep "\-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT" /etc/sysconfig/iptables)
            if [ "$ENABLED_HTTP" == "" ]; then
               sed -i s:" --dport 22 -j ACCEPT":" --dport 22 -j ACCEPT\n-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT":g /etc/sysconfig/iptables
            fi
         fi
         service iptables restart
      fi
}

function enable_apache(){
    #Redirect apache tomcat (Selinux enabled)
    /usr/sbin/setsebool -P httpd_can_network_connect 1
    configure_iptables
    service httpd restart
}
if ! [ -f /etc/httpd/conf.d/develenv.conf ]; then
   echo "Include ./conf.d/develenv.conf.d/*.conf" > /etc/httpd/conf.d/develenv.conf
   chown develenv:develenv /etc/httpd/conf.d/develenv.conf
fi
enable_apache


#Configure as a service
is_a_service="$(chkconfig --list develenv-devpi 2>/dev/null)"
if [ "$is_a_service" == "" ]; then
   _log "[INFO] Creating develenv-devpi service"
   chkconfig develenv-devpi on
fi
if [ "$(service develenv-devpi status 2>/dev/null|grep '^server is running with pid')" == "" ]; then
  service develenv-devpi start
fi


%preun
#-------------------------------------------------------------------------------
# PRE-UNINSTALL
#-------------------------------------------------------------------------------
_log "[INFO] PreUnInstall $1 $2 $3"

if [ "$1" = "0" ]; then
    _log "[INFO] Pre-uninstall %{name}"
    # Uninstall tasks
    service develenv-devpi stop
fi

%postun
#-------------------------------------------------------------------------------
# POST-UNINSTALL
#-------------------------------------------------------------------------------
_log "[INFO] PostUnInstall $1 $2 $3"

if [ "$1" = "0" ]; then
    _log "[INFO] Post-uninstall %{name}"
    # Uninstall tasks
    _log "[INFO] Doing uninstall tasks..."
    _log "[INFO] Removing develenv-devpi service"
    chkconfig develenv-devpi off
fi

%files
%defattr(-,develenv,develenv,-)
%{target_dir}
%{home_dir}
%{data_dir}
%attr(755,develenv,develenv) /etc/init.d/develenv-devpi
%config(noreplace) %{config_dir}/httpd


%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*

