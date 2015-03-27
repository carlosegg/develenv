class development::homedir( $userid = ['vagrant'] ){
  $homepath = "/home/$userid"

  file {"$homepath/.gitconfig":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    source   => 'puppet:///modules/development/.gitconfig'
  } 
  file {"$homepath/.git-completion.bash":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    source   => 'puppet:///modules/development/.git-completion.bash'
  }
  file {"$homepath/.git-prompt.sh":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    source   => 'puppet:///modules/development/.git-prompt.sh'
  }
  file {"$homepath/.bashrc":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    source   => 'puppet:///modules/development/.bashrc'
  }
  file {"$homepath/.bash_profile":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    source   => 'puppet:///modules/development/.bash_profile'
  }
  file {"$homepath/.motd":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    source   => 'puppet:///modules/development/.motd'
  }
  file {"$homepath/.ssh/config":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    mode     => '600',
    source   => 'puppet:///modules/development/.ssh/config'
  }
  file {"$homepath/.ssh/id_dsa_contint":
    owner    => $userid,
    group    => $userid,
    backup   => false,
    mode     => '600',
    source   => 'puppet:///modules/development/.ssh/id_dsa_contint'
  }
 # Directories used by rpm construction and installation
  $tmpDirs =       [ "/var/tmp/",
                     "/var/tmp/rpm",
                   ]

  file { $tmpDirs:
    owner   => 'vagrant',
    group   => 'vagrant',
    mode     => 777,
    ensure   => directory,
    require => User['vagrant'],
  }
  # Set git config properties from hostname
  exec { 'git_config_user':
    user        => 'vagrant',
    path        => "/usr/bin:/bin",
    onlyif      => ["test $(hostname|cut -d- -f1) = dev" , "test -n $(hostname|cut -d- -f3)" ],
    environment => "HOME=/home/vagrant",
    command     => "git config --global user.name $(hostname|cut -d- -f3) && git config --global user.email $(hostname|cut -d- -f3)@gmail.com",
    require     =>  File ["$homepath/.gitconfig"],
  }
}