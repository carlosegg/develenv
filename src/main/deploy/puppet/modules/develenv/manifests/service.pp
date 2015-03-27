class develenv::service {
  service { 'develenv':
    ensure     => running,
    enable     => true,
  }
  file { '/etc/init.d/develenv':
    ensure => link,
    target => '/home/develenv/bin/bootstrap.sh',
  }
  service { 'docker-registry':
    ensure     => running,
    enable     => true,
  }
  service { 'develenv-sonar':
    ensure     => running,
    enable     => true,
  }
}

