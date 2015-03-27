class develenv::yumrepos ($develenvrepo, $javaurlrepo) {

  if $domain == 'hi.inet' {
    $enablejavarepo = "1"
  } else {
    $enablejavarepo = "0"
  }

  yumrepo { 'java-repo':
    baseurl  => $javaurlrepo,
    descr    => 'Oracle java repository',
    enabled  => $enablejavarepo,
    gpgcheck => '0',
    notify   => Exec['clean_yum_cache'],
  }

  yumrepo { 'ss-thirdparty-develenv-noarch':
    baseurl    => 'http://thirdparty3-develenv-softwaresano.googlecode.com/svn/trunk/develenv/src/site/resources/tools/rpms/noarch',
    descr      => 'Repositorio de RPMs generados con thirdparty-develenv',
    enabled    => '1',
    gpgcheck   => '0',
    notify     => Exec['clean_yum_cache'],
  }

  yumrepo { "ss-thirdparty-develenv-${architecture}":
    baseurl  => 'http://thirdparty3-develenv-softwaresano.googlecode.com/svn/trunk/develenv/src/site/resources/tools/rpms/$basearch',
    descr    => 'Repositorio de RPMs generados con thirdparty-develenv',
    enabled  => '1',
    gpgcheck => '0',
    notify   => Exec['clean_yum_cache'],
  }

  yumrepo { "ss-thirdparty-develenv-src":
    baseurl  => 'http://thirdparty3-develenv-softwaresano.googlecode.com/svn/trunk/develenv/src/site/resources/tools/rpms/src',
    descr    => 'Repositorio de source RPMs generados con thirdparty-develenv',
    enabled  => '1',
    gpgcheck => '0',
    notify   => Exec['clean_yum_cache'],
  }

  yumrepo { "ss-develenv-noarch":
    baseurl  => "$develenvrepo/noarch",
    descr    => 'ss-develenv',
    enabled  => '1',
    gpgcheck => '0',
    notify   => Exec['clean_yum_cache'],
  }

  yumrepo { "ss-develenv":
    baseurl  =>  "$develenvrepo/\$basearch",
    descr    => 'ss-develenv',
    enabled  => '1',
    gpgcheck => '0',
    notify   => Exec['clean_yum_cache'],
  }
  
  yumrepo { 'epel':
    mirrorlist     => "https://mirrors.fedoraproject.org/metalink?repo=epel-${operatingsystemmajrelease}&arch=\$basearch",
    failovermethod => 'priority',
    descr          => 'epel',
    enabled        => '1',
    gpgcheck       => '0',
    notify         => Exec['clean_yum_cache'],
  }

  exec { 'clean_yum_cache':
    command     => '/usr/bin/yum clean all',
    refreshonly => true,
  }

}
