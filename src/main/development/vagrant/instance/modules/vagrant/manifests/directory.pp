class vagrant::directory {
  file {'/vagrant':
    owner   => 'vagrant',
    group   => 'vagrant',
    mode     => 774,
    ensure   => directory,
    require => User['vagrant'],
  }
}