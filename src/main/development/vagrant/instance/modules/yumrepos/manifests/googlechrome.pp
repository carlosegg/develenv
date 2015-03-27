class yumrepos::googlechrome {
  # Google Chrome repo
  yumrepo { 'google-chrome':
    baseurl    => 'http://dl.google.com/linux/chrome/rpm/stable/$basearch',
    descr      => 'Google Chrome Repository',
    enabled    => '1',
    gpgcheck   => '0',
    notify   => Exec['clean_yum_cache'],
  }
}
