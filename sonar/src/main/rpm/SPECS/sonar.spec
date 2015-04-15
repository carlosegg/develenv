Name:       sonar
Version:    5.1
Release:    2537.%{versionModule}.131
Summary:    Sonar is an open platform to manage code quality. 
Group:      develenv
License:    http://www.sonarsource.org/support/license/
Packager:   softwaresano.com
URL:        http://www.sonarsource.org
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Source0:    sonarqube-%{version}.zip
Requires:   ss-develenv-sonar-db >= 5.0.1-2537.123 php-xml jdk httpd
Vendor:     tid.es
AutoReqProv:no

%define package_name sonar
%define develenv_sonar_dir /var/develenv/sonar
%define projectName develenv 
%define sonar_upgrading /var/lock/subsys/sonar-upgrading
%{!?sonar_script: %global sonar_script %(echo %{develenv_sonar_dir}/bin/linux-$(uname -p|sed s:"_":"-":g)/sonar.sh)}


%description
Sonar is the central place to manage code quality, offering visual reporting on
and across projects and enabling to replay the past to follow metrics evolution


%clean
#------------------------------------------------------------------------------
# CLEAN
#------------------------------------------------------------------------------
[ %{buildroot} != "/" ] && rm -rf %{buildroot}

%pre
#------------------------------------------------------------------------------
# PRE-INSTALL
#------------------------------------------------------------------------------
if [ -f "%{sonar_script}" ]; then
   if [ "$(%{sonar_script} status|grep 'is running')" != "" ]; then
    _log "[INFO] Stopping sonar for upgrading"
    service develenv-sonar stop
    touch %{sonar_upgrading}
   fi
fi

%install
#------------------------------------------------------------------------------
# INSTALL
#------------------------------------------------------------------------------
%{__mkdir_p} %{buildroot}/%{develenv_sonar_dir}
cd  %{buildroot}/%{develenv_sonar_dir}/..
unzip %{SOURCE0}
rm -rf sonar
mv sonarqube-%{version} sonar
_log "[INFO] Remove bundle-plugins"
rm -rf sonar/lib/bundled-plugins/*
_log "[INFO] develenv sonar adapter"

echo '#!/bin/sh
if [ -d "/etc/develenv/sonar" ]; then
   rm -Rf /var/develenv/sonar/conf
   mkdir -p /var/develenv/sonar/conf
   cp /etc/develenv/sonar/*.* /var/develenv/sonar/conf
   echo "This folder is configured by develenv. To change sonar configuration \
edit /etc/develenv/sonar/sonar.properties and \
it is not configurable">/var/develenv/sonar/conf/README
   chown -R develenv:develenv /var/develenv/sonar/conf
fi' >%{buildroot}/%{sonar_script}.patch
sed '/\/bin\/sh/d' %{buildroot}/%{sonar_script}>>%{buildroot}/%{sonar_script}.patch
rm %{buildroot}/%{sonar_script}
mv %{buildroot}/%{sonar_script}.patch %{buildroot}/%{sonar_script}
sed -i s:"#RUN_AS_USER=.*":"RUN_AS_USER=develenv":g %{buildroot}/%{sonar_script}
chmod 755 %{buildroot}/%{sonar_script}


# Exclude the plugins and rules sonar dirs because are in independent packages (ss-develenv-sonar-plugins
# ss-develenv-sonar-rules)
rm -Rf %{buildroot}/%{develenv_sonar_dir}/extensions/plugins
rm -Rf %{buildroot}/%{develenv_sonar_dir}/extensions/rules
# Deleting download dir to let sonar recreate it
rm -Rf %{buildroot}/%{develenv_sonar_dir}/extensions/downloads/*
cd %{buildroot}/%{develenv_sonar_dir}/conf
rm -rf *
mkdir -p default
cp -r %{_srcrpmdir}/../sonar/src/main/resources/default/conf default
cp %{_srcrpmdir}/../sonar/src/main/resources/develenv-sonar.conf default/conf/

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


# Removing extensions downloads in updating.
# Problems with diferents versions of java java ecosystem
cd %{develenv_sonar_dir}
_log "[INFO] Removing sonar plugins downloads"
rm -Rf extensions/downloads/*

if [ -d /var/log/develenv/sonar ]; then
    _log "[INFO] Applying sonar logs configuration for develenv"
    rm -rf logs
    ln -s /var/log/develenv/sonar logs
fi

if [ -d /var/develenv/temp ]; then
    _log "[INFO] Configure temp sonar directory for develenv"
    rm -rf temp
    mkdir -p /var/develenv/temp/sonar
    chown -R develenv:develenv /var/develenv/temp/sonar
    ln -s /var/develenv/temp/sonar temp
fi

if [ -f /etc/develenv/sonar/sonar.properties ]; then
    _log "[INFO] Applying sonar configuration for develenv"
    sed -i '/sonar\.web\.context/d' /etc/develenv/sonar/sonar.properties
    echo "" >>/etc/develenv/sonar/sonar.properties
    echo "sonar.web.context=/sonar" >> /etc/develenv/sonar/sonar.properties
    rm -rf conf
    ln -s /etc/develenv/sonar conf
else
    _log "[INFO] Applying default sonar configuration"
    cd conf
    cp default/conf/* .
    chown -R develenv:develenv .
    cd ..
fi

if [ -d /etc/httpd/conf.d/develenv.conf.d ]; then
    if [ "$(grep ajp /etc/httpd/conf.d/develenv.conf.d/develenv-sonar.conf)" != "" ]; then
        cp conf/default/conf/develenv-sonar.conf /etc/httpd/conf.d/develenv.conf.d
        chown -R develenv:develenv /etc/httpd/conf.d/develenv.conf.d/develenv-sonar.conf
        enable_apache
    fi
else
    _log "[INFO] Applying default sonar configuration"
    mkdir -p /etc/httpd/conf.d/develenv.conf.d
    cp conf/default/conf/develenv-sonar.conf /etc/httpd/conf.d/develenv.conf.d
    if ! [ -f /etc/httpd/conf.d/develenv.conf ]; then
       echo "Include ./conf.d/develenv.conf.d/*.conf" > /etc/httpd/conf.d/develenv.conf
       chown develenv:develenv /etc/httpd/conf.d/develenv.conf
       
    fi
    enable_apache
fi

#Configure as a service
is_a_service="$(chkconfig --list develenv-sonar 2>/dev/null)"
if [ "$is_a_service" == "" ]; then
   _log "[INFO] Creating develenv-sonar service"
   cd /etc/init.d
   unlink develenv-sonar 2>/dev/null
   ln -s %{sonar_script} develenv-sonar
   chkconfig develenv-sonar on
fi

if [ -f %{sonar_upgrading} ]; then
   rm -rf %{sonar_upgrading}
   service develenv-sonar start
else
   _log "[INFO] Execute service develenv-sonar start] to start sonar"
fi

%preun
#-------------------------------------------------------------------------------
# PRE-UNINSTALL
#-------------------------------------------------------------------------------
_log "[INFO] PreUnInstall $1 $2 $3"

if [ "$1" = "0" ]; then
    _log "[INFO] Pre-uninstall %{name}"
    # Uninstall tasks
    service develenv-sonar stop
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
    if [ -d " %{develenv_sonar_dir}" ]; then
        cd  %{develenv_sonar_dir}
        _log "[INFO] Deleting broken links"
        rm -Rf $(find -L . -type l)
    fi
    _log "[INFO] Removing develenv-sonar service"
    chkconfig develenv-sonar off
    rm -rf /etc/init.d/develenv-sonar
fi

%files
%defattr(-,%{projectName},%{projectName},-)
%{develenv_sonar_dir}