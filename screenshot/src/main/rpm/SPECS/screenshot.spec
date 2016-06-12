# rpmbuild -bb SPECS/screenshot.spec  --define '_topdir '`pwd`  -v --clean
%{!?python_dependency: %global python_dependency %([[ "$(cat /etc/redhat-release |sed s:'.*release ':'':g|awk '{print $1}'|cut -d '.' -f1)" == "6" ]] && echo python2.6 || echo python2.7)}

%define     project_name develenv
%define     org_acronym ss
Name:       screenshot
Summary:    Screenshot of a web page
Version:    %{versionModule}
Release:    2562.g2074459.%{os_release}
License:    http://www.apache.org/licenses/LICENSE-2.0
Packager:   softwaresano.com
Group:      develenv
BuildArch:  x86_64
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   %{org_acronym}-%{project_name}-selenium >= 2.46.0 python php >= 5.3.3  %{org_acronym}-%{project_name}-user
Vendor:     softwaresano.com
Obsoletes:  python26-selenium >= 2.44.0 python26-PIL
AutoReqProv: no
# Redefine post install macros 
%define __os_install_post    \
    /usr/lib/rpm/redhat/brp-compress \
    %{!?__debug_package:/usr/lib/rpm/redhat/brp-strip %{__strip}} \
    /usr/lib/rpm/redhat/brp-strip-static-archive %{__strip} \
    /usr/lib/rpm/redhat/brp-strip-comment-note %{__strip} %{__objdump} \
    %{!?__jar_repack:/usr/lib/rpm/redhat/brp-java-repack-jars} \
%{nil}


%define package_name selenium-screenshot
%define target_dir /var/%{project_name}/%{package_name}

%description
it captures a screenshot of a web page. Also captures a portion of web page

%install
%{__mkdir_p} %{buildroot}/
PYTHONPATH=""
unset PYTHONPATH
mkdir -p %{buildroot}/%{target_dir}/lib/%{python_dependency}/site-packages/
### PIL dependency
tar xvfz %{_sourcedir}/Imaging-1.1.7.tar.gz
cd Imaging-1.1.7
PYTHONPATH=%{buildroot}/%{target_dir}/lib/%{python_dependency}/site-packages/ python setup.py install --prefix %{buildroot}/%{target_dir}
### Selenium Library
tar xvfz %{_sourcedir}/selenium-2.46.0.tar.gz
cd selenium-2.46.0
PYTHONPATH=%{buildroot}/%{target_dir}/lib/%{python_dependency}/site-packages/ python setup.py install --prefix %{buildroot}/%{target_dir}
mkdir -p %{buildroot}/usr/lib/%{python_dependency}/site-packages
echo /var/develenv/selenium-screenshot/lib/%{python_dependency}/site-packages/selenium-2.46.0-py%{python_version}.egg >%{buildroot}/usr/lib/%{python_dependency}/site-packages/selenium.pth
echo /var/develenv/selenium-screenshot/lib64/%{python_dependency}/site-packages >%{buildroot}/usr/lib/%{python_dependency}/site-packages/PIL.pth

cp -R %{_sourcedir}/* %{buildroot}
rm %{buildroot}/*.tar.gz


chcon -Rv --type=httpd_sys_content_t  %{buildroot}



# Copying scripts

%files
%defattr(-,develenv,develenv,-)
/etc/httpd/conf.d/develenv.conf.d/develenv-screenshot.conf
/var/develenv/screenshot
/var/develenv/selenium-screenshot/
/usr/lib/%{python_dependency}/site-packages/selenium.pth
/usr/lib/%{python_dependency}/site-packages/PIL.pth


%clean
[ ${RPM_BUILD_ROOT} != "/" ] && rm -rf ${RPM_BUILD_ROOT}/*
