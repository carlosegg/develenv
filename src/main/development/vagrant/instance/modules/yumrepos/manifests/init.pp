class yumrepos ( $repos = [ 'localhost' ] ) {
  class{ $repos: }
  exec{
    'clean_yum_cache':
      command     => '/usr/bin/yum clean all',
      refreshonly => true,
  }   
}
