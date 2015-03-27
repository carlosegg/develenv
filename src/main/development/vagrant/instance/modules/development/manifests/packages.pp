class development::packages {
 # Needed packages to guest additions installation  
  package {
    'git':             ensure => installed;
    'subversion':      ensure => installed;
    'wget':            ensure => installed;
  }	
}