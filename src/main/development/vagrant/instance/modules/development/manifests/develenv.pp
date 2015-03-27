class development::develenv {
  $userid="develenv"
  $userhome="/home/$userid"

  file {"$userhome/.gitconfig":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    source   => 'puppet:///modules/development/.gitconfig',
  } 
   
  file {"$userhome/.git-completion.bash":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    source   => 'puppet:///modules/development/.git-completion.bash',
  }
  file {"$userhome/.git-prompt.sh":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    source   => 'puppet:///modules/development/.git-prompt.sh',
  }
  file {"$userhome/.bashrc":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    source   => 'puppet:///modules/development/.bashrc',
  }
  
  file {"$userhome/.bash_profile":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    source   => 'puppet:///modules/development/.bash_profile',
  }
  
  file {"$userhome/.ssh/":
    owner    => $userid,
    group    => $userid,
    ensure   => 'directory',
    mode     => 700,
  }  

  file {"$userhome/.ssh/config":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    mode     => '600',
    source   => 'puppet:///modules/development/.ssh/config',
    require  => File["$userhome/.ssh"],
  }
  
  file {"$userhome/.ssh/id_dsa_contint":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    mode     => '600',
    source   => 'puppet:///modules/development/.ssh/id_dsa_contint',
    require  => File["$userhome/.ssh"],
  }

  file { "$userhome/bin":
    ensure => "directory",
    owner    => $userid,
    group    => $userid,
    backup   => false,
    require  => User[$userid],
    notify   => Exec['develenv_setEnv'],
  }

  exec { 'develenv_setEnv':
    user     => $userid,
    cwd      => "$userhome/bin",
    command  => '/usr/bin/wget http://develenv.googlecode.com/svn/trunk/develenv/src/main/scripts/setEnv.sh -O setEnv.sh && chmod 755 setEnv.sh',
    refreshonly => true,
    require  => File["$userhome/bin"],
  }
}