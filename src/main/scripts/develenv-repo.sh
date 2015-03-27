#!/bin/bash
. ./setEnv.sh
if [ "$DEBUG_DEVELENV" == "TRUE" ] || [ -f /tmp/DEBUG_DEVELENV ]; then
   set -x
else
   set +x
fi
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}
function getHostname(){
   local IP MAC_ADDRESSES temp INTERNALIP i j HOST
   IP=`LANG=C /sbin/ifconfig | grep "inet addr" | grep "Bcast" | awk '{ print $2 }' | awk 'BEGIN { FS=":" } { print $2 }' | awk ' BEGIN { FS="." } { print $1 "." $2 "." $3 "." $4 }'`
   MAC_ADDRESSES=`LANG=C /sbin/ifconfig -a|grep HWaddr|awk '{ print $5 }'`
   if [ "$IP" == "" ]; then
      echo -e "\nNo hay conexión de red. Introduce el nombre o la ip de la máquina: \c"
      read HOST
   else
      local j=0
      for i in $IP; do
         #Averiguamos si alguna IP tiene asignada nombre de red
         j=$(($j +1 ));
         temp=`LANG=C nslookup $i|grep "name = "|cut -d= -f2| sed 's/.//' | sed 's/.$//'`
         if [ "$temp" != "" ]; then
            HOST=$temp
            INTERNALIP=$i
            MAC_ADDRESS=`echo $MAC_ADDRESSES|cut -d' ' -f$j`
            # Avoid problem with virtuals ips
            if [ "$(echo $temp|cut -d'.' -f1)" == "$(echo $(hostname)|cut -d'.' -f1)" ]; then
                break
            fi
         fi
      done
      if [ "$HOST" == "" ]; then
         # Probablemente sea una conexión wifi, y no tenga asignada un nombre en el DNS
         HOST=`hostname`
         INTERNALIP=`echo $IP|cut -d' ' -f1`
         MAC_ADDRESS=`echo $MAC_ADDRESSES|cut -d' ' -f1`
         # Si no hay un nombre de hosts asignado
         if [ "$HOST" == "" ];then
            # Nos quedamos con la primera IP
            HOST=$INTERNALIP
         fi
      fi
   fi
   echo $HOST
}

currentDir
rpm_version=1.0
rpm_release=0.0
REPO_BUILD_DIR=/home/$PROJECT_NAME/temp/DEVELENVREPO
REPO_NAME=repo
rpm_file=${ORG_ACRONYM}-${PROJECT_NAME}-${REPO_NAME}-${rpm_version}-${rpm_release}.noarch.rpm
if [ -f "/home/${PROJECT_NAME}/app/repositories/rpms/noarch/$rpm_file" ]; then
   _log "[WARNING] $rpm_file already exists and will not be regenerated"
   exit 0
else
   _log "[INFO] Creating develenv repo"
fi
rm -Rf $REPO_BUILD_DIR
mkdir -p $REPO_BUILD_DIR
SPEC_FILE="$REPO_BUILD_DIR/${REPO_NAME}.spec"
lineSeparator=`grep -n "###### SPEC ######" $0|grep -v "grep" |sed s:"\:###### SPEC ######":"":g`
sed 1,${lineSeparator}d $0 > $SPEC_FILE
cd $REPO_BUILD_DIR
HOST=$(getHostname)
sed -i s:"REPOHOST":"$HOST":g $SPEC_FILE
if [[ -z "$DP_HOME" ]]; then
   DP_HOME=$(dirname $(readlink -f $(which dp_package.sh 2>/dev/null) 2>/dev/null) 2>/dev/null)
   if [[ -z "$DP_HOME" ]]; then
      if [[ -f "$PROJECT_PLUGINS/pipeline_plugin/dp_package.sh" ]]; then
         DP_HOME=$PROJECT_PLUGINS/pipeline_plugin/
         _log "[INFO] Default DP_HOME[$DP_HOME] is assigned"
      else
         _log "[ERROR] DP_HOME must be defined" && exit 1
      
      fi
   fi
   export DP_HOME
fi
$DP_HOME/profiles/package/redhat/dp_package.sh \
        --version $rpm_version \
        --release $rpm_release
errorCode=$?
if [ "$errorCode" != "0" ]; then
   _log "[ERROR] Creating develenv-repo"
else
   rm -Rf $REPO_BUILD_DIR
fi
exit $errorCode
###### SPEC ######
Name:      ss-develenv-repo
Summary:   Repository rpms
Version:   %{versionModule}
Release:   %{releaseModule}
License:   GPL 3.0
Packager:  ss
Group:     develenv
BuildArch: noarch
BuildRoot: %{_topdir}/BUILDROOT
Requires:  curl
Vendor:    SoftwareSano.com

%define package_name repo
%define project_name develenv
%define pipeline_home /opt/pipeline/%{project_name}/enviroment
%define org_acronynm ss
%define component_home /etc/yum.repos.d
%define yum_repos_dir  %{component_home}
%define modify_package_name false
#Compatible with rh5.5
%define _binary_filedigest_algorithm  1
%define _binary_payload 1



%description
%{project_name} repository

%prep
_log "Building package %{name}-%{version}-%{release}"
mkdir -p $RPM_BUILD_ROOT/etc/yum.repos.d/
cd $RPM_BUILD_ROOT/etc/yum.repos.d/


echo "
[ss-%{project_name}-arch]
name=ss-%{project_name}-arch
baseurl=http://REPOHOST/%{project_name}/rpms/\$basearch
enabled=1
gpgcheck=0" > %{org_acronynm}-%{project_name}-arch.repo

echo "
[ss-%{project_name}-noarch]
name=ss-%{project_name}-noarch
baseurl=http://REPOHOST/%{project_name}/rpms/noarch
enabled=1
gpgcheck=0" > %{org_acronynm}-%{project_name}-noarch.repo

%files
%defattr(-,%{project_name},%{project_name},-)
%config(noreplace) /etc


%pre
#-------------------------------------------------------------------------------
# PRE-INSTALL
#-------------------------------------------------------------------------------
http_status_code=$(curl -s -o /dev/null -w '%{http_code}' http://REPOHOST/develenv/rpms/noarch/repodata/repomd.xml)
if [ "$http_status_code" != "200" ]; then
   _log "[ERROR] Desde [$(hostname)] no hay acceso a REPOHOST"
   exit 1
fi
if [ "$(id -u %{project_name} 2>/dev/null)" == "" ]; then
   default_id=600
   id_user=$(grep "^.*:.*:$default_id:" /etc/passwd)
   id_group=$(grep "^.*:.*:$default_id:" /etc/group)
   if [ "$id_user" == "" -a "$id_group" == "" ]; then
      groupadd -g $default_id %{project_name}
      useradd -s /bin/bash -g $default_id -u $default_id %{project_name}
   else
      useradd -s /bin/bash %{project_name}
   fi
fi
%post
#-------------------------------------------------------------------------------
# POST-INSTALL
#-------------------------------------------------------------------------------
_log "[INFO] Remove cache rpm directory"
%{__rm} -Rf %{_var}/yum/cache/*

#-------------------------------------------------------------------------------
# POST-UNINSTALL
#-------------------------------------------------------------------------------
%postun
_log "[INFO] Remove cache rpm directory"
%{__rm} -Rf %{_var}/yum/cache/*

%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*
