class development::users {
   file {'/home/develenv':
    ensure     => 'directory',
    owner      => 'develenv',
    group      => 'develenv',
    mode       => 755,
    require    => User['develenv'],
  }

  user {'develenv':
    ensure     => 'present',
    shell      => '/bin/bash',
    managehome => true,
  }
}