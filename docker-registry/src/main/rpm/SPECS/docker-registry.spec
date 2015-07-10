# rpmbuild -bb SPECS/docker-registry.spec  --define '_topdir '`pwd`  -v --clean
%{!?redhat_version: %global redhat_version %(cat /etc/redhat-release |sed s:'.*release ':'':g|awk '{print $1}'|cut -d '.' -f1)}
%define     project_name develenv
%define     org_acronym ss
Name:       docker-registry
Summary:    Docker-Registry
Version:    %{versionModule}
Release:    11.gc28875f.el%{redhat_version}
License:    http://www.apache.org/licenses/LICENSE-2.0
Packager:   softwaresano.com
Group:      develenv
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   docker-registry %{org_acronym}-%{project_name}-user httpd
Vendor:     softwaresano.com

%define package_name docker-registry
%define docker_registry_home /var/develenv/repositories/docker-registry

%description
Wrapper for docker-registry

%install
%{__mkdir_p} %{buildroot}/
cp -R %{_sourcedir}/* %{buildroot}
chcon -Rv --type=httpd_sys_content_t  %{buildroot}

%post
function configure_iptables(){
      if [ -f "/etc/sysconfig/iptables" ]; then
         isRHFirewall=$(grep "\-A RH-Firewall " /etc/sysconfig/iptables)
         if ! [ -z $isRHFirewall ]; then
            ENABLED_5010_PORT=$(grep "\-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 5010 -j ACCEPT" /etc/sysconfig/iptables) 
            if [ "$ENABLED_5010_PORT" == "" ]; then
               sed -i s:"-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT":"-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT\n-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 5010 -j ACCEPT":g /etc/sysconfig/iptables
            fi
         else
            ENABLED_5010_PORT=$(grep "\-A INPUT -p tcp -m state --state NEW -m tcp --dport 5010 -j ACCEPT" /etc/sysconfig/iptables)
            if [ "$ENABLED_5010_PORT" == "" ]; then
               sed -i s:" --dport 22 -j ACCEPT":" --dport 22 -j ACCEPT\n-A INPUT -p tcp -m state --state NEW -m tcp --dport 5010 -j ACCEPT":g /etc/sysconfig/iptables
            fi
         fi
         service iptables restart
      fi

}
sed -i s:"/var/lib/docker-registry":"%{docker_registry_home}":g /etc/docker-registry.yml
sed -i s:"REGISTRY_PORT=.*":"REGISTRY_PORT=5010":g /etc/sysconfig/docker-registry

configure_iptables

if [ "$(service docker-registry status|grep "is stopped...")" != "" ]; then
   service docker-registry start
fi


%files
%defattr(-,develenv,develenv,-)
%{docker_registry_home}

%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*
