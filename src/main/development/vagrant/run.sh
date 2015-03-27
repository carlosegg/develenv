#!/bin/bash
function install_epel_repo(){
   rh_majversion=$(cat /etc/redhat-release|awk '{print $3}'|cut -d'.' -f1)
   case $rh_majversion in
      6) epel_url="http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm";;
      7) epel_url="http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-0.2.noarch.rpm";;
      *) echo "[ERROR] $rh_majversion is not supported"&& exit 1;;
   esac
   rpm -Uvh $epel_url
}
[[ "$(id -u)" != 0 ]] && echo "[ERROR] You need root" && exit 1
cp -R ./etc/yum.repos.d/* /etc/yum.repos.d
yum clean all
yum install puppet bzip2 -y
yum clean all
puppet apply manifests/base.pp --modulepath=modules/ --verbose --debug
echo "[INFO] Host ready for vagrant box."
echo "[WARNING] Execute vagrant plugin install vagrant-vbguest before vagrant up"