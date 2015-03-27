#rpmbuild -v  --clean  --define '_buildshell '/bin/bash' --define '_topdir '/home/carlosg/workspace/develenv/target/.rpm --define 'versionModule '1 --define 'releaseModule '2  -bb /var/tmp/rpm/ss-develenv-core-1-2/ss-develenv-core.spec

%define project_name develenv
%define org_acronynm ss
Name:      user
Summary:   Develenv user
Version:   33
Release:   2409
License:   GPL 3.0
Packager:  ss
Group:     develenv
BuildArch: noarch
BuildRoot: %{_topdir}/BUILDROOT
Requires(pre): /usr/sbin/useradd
Vendor:    SoftwareSano.com
#Compatible with rh5.5
%define _binary_filedigest_algorithm  1
%define _binary_payload 1

%description
Develenv user

%prep
%{__mkdir_p} %{buildroot}

%files

%pre
#------------------------------------------------------------------------------
# PRE-INSTAL
#------------------------------------------------------------------------------

#Create develenv user if not exists
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
#------------------------------------------------------------------------------
# POST-INSTALL
#------------------------------------------------------------------------------


%postun

%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*
