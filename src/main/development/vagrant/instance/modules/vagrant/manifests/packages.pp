class vagrant::packages {
 # Needed packages to guest additions installation  
  package {
    'kernel':           ensure => installed;
    'kernel-headers':   ensure => installed;
    'kernel-devel':     ensure => installed;
    'gcc':              ensure => installed; 
    'sudo':             ensure => installed;
    'make':             ensure => installed; 
    'perl':             ensure => installed;
    'puppet':           ensure => installed;
    'dkms':             ensure => installed;
    'openssh-clients':  ensure => installed;
  }	
}