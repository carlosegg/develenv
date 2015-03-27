class develenv::packages($develenv_version) {
  package {
    'google-chrome-stable':         ensure => present;
    'ss-develenv-core':             ensure => $develenv_version;
    'ss-develenv-jenkins-examples': ensure => installed;
  }
}
