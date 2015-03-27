class yumrepos::develenv {
  package {'ss-develenv-repo':
    provider => 'rpm',
    ensure   => installed,
    source   => $develenvrpmrepo,
    require  => Package['ss-thirdparty-develenv-repo'],
    notify   => Exec['clean_yum_cache'],
  }

  package {'ss-thirdparty-develenv-repo':
    provider => 'rpm',
    ensure   => installed,
    source   => "http://thirdparty3-develenv-softwaresano.googlecode.com/svn/trunk/develenv/src/site/resources/tools/rpms/noarch/ss-thirdparty-develenv-repo-1.0-0.0.noarch.rpm",
  }
}
