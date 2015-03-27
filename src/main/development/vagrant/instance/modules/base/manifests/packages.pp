class base::packages {
  package {
    'mlocate':          ensure => present;
    'bind-utils':       ensure => present;
    'jdk':              ensure => present;
  }	
}