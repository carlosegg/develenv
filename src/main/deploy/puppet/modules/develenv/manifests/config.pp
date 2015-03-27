class develenv::config (
  $administrator,
  $password,
  $profile,
) {

  if $profile == 'softwaresanoProfile' {
    $profileURL = 'http://develenv.googlecode.com/svn/trunk/develenv/src/main/filters/softwaresano.properties'
  } elsif $profile == 'googleProfile' {
    $profileURL = 'http://develenv.googlecode.com/svn/trunk/develenv/src/main/filters/google.properties'
  } elsif $profile == 'tidProfile' {
    $profileURL = 'http://develenv.googlecode.com/svn/trunk/develenv/src/main/filters/tid.properties'
  } else {
    $profileURL = $profile
  }

  $str = "-Dadministrator.id=${administrator} -Dpassword=${password} -Dorg=${profileURL}"

  file { "/etc/develenv/":
    ensure => directory,
    owner  => 'develenv',
    group  => 'develenv',
  }

  file { "/etc/develenv/develenv.properties":
    owner  => 'develenv',
    group  => 'develenv',
    content => "$str",
    require => File['/etc/develenv'],
  }
}
