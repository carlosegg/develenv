class yumrepos::javarepo {
  # Google Chrome repo
  yumrepo { 'java-repo':
    baseurl    => $javaurlrepo,
    descr      => 'Oracle java repository',
    enabled    => $enablejavarepo,
    gpgcheck   => '0',
    notify     => Exec['clean_yum_cache'],
  }
}
