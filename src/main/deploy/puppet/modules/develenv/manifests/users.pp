class develenv::users {
   file {'/home/develenv':
    ensure     => 'directory',
    owner      => 'develenv',
    group      => 'develenv',
    mode       => 755,
    require    => User['develenv'],
  } 

  user {'develenv':
    ensure     => present,
    home       => '/home/develenv',
    shell      => '/bin/bash',
    managehome => true,
  }


}
