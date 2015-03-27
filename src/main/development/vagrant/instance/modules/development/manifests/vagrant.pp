class development::vagrant {
  class {'yumrepos':
    repos   => ['localhost','javarepo']
  }
  $userid="vagrant"
  class {'homedir':
    userid   => $userid,
    require  => User[$userid],
  }
  Class['homedir'] -> Class['yumrepos']
}
