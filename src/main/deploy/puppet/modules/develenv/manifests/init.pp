# = Class: develenv
#
# This class installs/configures/manages a Develenv Environment
#
# == Parameters:
#
# $administrator:     It must match an LDAP user. It'll have admin rights on Jenkins (http://hostname/jenkins/login)
# $password:          Tomcat password. develenv by default
# $profile:           Can be tidProfile, googleProfile, softwaresanoProfile. tidProfile by default (if installed within the TID datacenters)
# $javaurlrepo:       Where the java packages are
# $develenvrpmrepo:   The URL for the RPM that configures the develenv yum repos
#
# == Requires:
#
# Nothing.
#
# == Sample Usage:
#
# Simple default usage. Always put the LDAP user of the guy who has requested the machine:
#  class { 'develenv':
#    administrator => 'jorgelg',
#  }
#
# By default the TIDprofile is used. You can change that if you like (only if you know what you're doing!):
#  class { 'develenv':
#    administrator => 'jorgelg',
#    profile       => 'googleProfile',
#  }
#
# You can also specify the ss-develenv-core version. By default it is 24-5896
#  class { 'develenv':
#    administrator    => 'sergiom',
#    develenv_version => '25-6281',
#  }

# You can also specify the ss-develenv-core version. By default it is 24-5896
#  class { 'develenv':
#    administrator    => 'develenv',
#    develenv_version => 'installed',
#    develenvrepo     => 'file:///home/vagrant/rpmbuild/RPMS',
#    profile          => 'softwaresanoProfile',
#  }
#
#
# == Authors:
# Carlos Enrique Gomez Gomez <carlosg@tid.es>
# Xavi Carrillo <epgbcn3@tid.es>
#
# $administrator has no default value, but is mandatory and must be a valid LDAP user (even though we don't check this validity)
#

class develenv (
  $administrator,
  $password         = 'develenv',
  $profile          = 'softwaresanoProfile',
  $develenv_version = 'installed',
  $javaurlrepo      = 'http://servilinux.hi.inet/java/yum/7/$basearch',
  $develenvrepo     = 'file:///home/vagrant/rpmbuild/RPMS',
) {

#  if $administrator == 'develenv' {
#    fail ("Administrator can't be 'develenv'")
#  }

  # The framebuffer (xorg-x11-server-Xvfb) package is a dependency but it won't install
  if $::operatingsystem == 'RedHat' {
    fail ('RedHat is not supported')
  }

  class { 'develenv::config':
    administrator => $administrator,
    password      => $password,
    profile       => $profile,
  }

  class { 'develenv::yumrepos':
    develenvrepo    => $develenvrepo,
    javaurlrepo     => $javaurlrepo,
  }
 
  class { 'develenv::packages':
    develenv_version => $develenv_version,
  }
   
  include develenv::users
  include develenv::service

  Class['users'] -> Class ['config'] -> Class ['yumrepos'] -> Class ['packages'] -> Class ['service']

}
