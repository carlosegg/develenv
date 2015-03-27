# rpmbuild -bb SPECS/jenkins-examples.spec --define '_topdir '`pwd` -v --clean
%define project_name develenv
%define org_acronynm ss
Name:       jenkins-examples
Version:    36
Release:    2542
Summary:    Example jenkins jobs
Group:      develenv
License:    http://creativecommons.org/licenses/by/3.0/
Packager:   softwaresano.com
URL:        https://code.google.com/p/develenv/
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   ss-develenv-jenkins-plugins >= 2538-124.1 %{org_acronynm}-%{project_name}-screenshot >= 35-3
Vendor:     tid.es

%define jenkins_jobs_path jenkins/jobs
%define target_dir /var/develenv/%{jenkins_jobs_path}

%description
Example jobs for jenkins with different technologies
#-------------------------------------------------------------------------------
# INSTALL
#-------------------------------------------------------------------------------
%install
%{__mkdir_p} %{buildroot}/%{target_dir}
# Added %{_sourecdir} to avoid conflicts in changes on _topdir
cp -r %{_sourcedir}/../../config/jobs/*  %{buildroot}/%{target_dir}
rm -Rf %{buildroot}/%{target_dir}/backupDevelenv
rm -Rf  %{buildroot}/%{target_dir}/pipeline-ADMIN-01-addPipeline
#-------------------------------------------------------------------------------
# CLEAN
#-------------------------------------------------------------------------------
%clean
[ %{buildroot} != "/" ] && rm -rf %{buildroot}

%files
%defattr(-,develenv,develenv,-)
%{target_dir}

%changelog
