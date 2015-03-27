
# rpmbuild -bb SPECS/nexus.spec --define '_topdir '`pwd` -v --clean

Name:       nexus
Version:    2.11.2
Release:    2537.125
Summary:    Nexus manages software "artifacts" required for development.
Group:      develenv
License:    http://www.sonatype.org/nexus/license
Packager:   softwaresano.com
URL:        http://www.sonatype.org/nexus/
Source0:    %{package_name}.war
BuildArch:  noarch
BuildRoot:  %{_topdir}/BUILDROOT
Requires:   ss-develenv-tomcat >= 8.0.20-2535.121
Vendor:     tid.es

%define package_name nexus
%define tomcat_webapps tomcat/webapps
%define target_dir  /opt/ss/develenv/platform/%{tomcat_webapps}/%{package_name}

%description
Nexus manages software "artifacts" required for development. If you develop 
software, your builds can download dependencies from Nexus and can publish 
artifacts to Nexus creating a new way to share artifacts within an organization.
 While Central repository has always served as a great convenience for 
developers you shouldn't be hitting it directly. You should be proxying Central
 with Nexus and maintaining your own repositories to ensure stability within 
your organization. 
With Nexus you can completely control access to, and deployment of, every 
artifact in your organization from a single location.


%install
%{__mkdir_p} %{buildroot}/%{target_dir}
cd %{buildroot}/%{target_dir}
unzip %{SOURCE0}

# Added to avoid conflicts with yum upgrade and ss-develenv-config
#rm -rf %{buildroot}/%{target_dir}/conf 
 

%clean
[ %{buildroot} != "/" ] && rm -rf %{buildroot}

%files
%defattr(-,develenv,develenv,-)
%{target_dir}