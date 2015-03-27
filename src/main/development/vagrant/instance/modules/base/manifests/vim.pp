class base::vim {
  package { 'vim-enhanced':
    ensure => present,
  }
  file { '/root/.vimrc':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    source => 'puppet:///modules/base/vimrc',
  }
}
