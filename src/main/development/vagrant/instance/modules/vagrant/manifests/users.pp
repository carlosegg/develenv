class vagrant::users {
  group {'admin':
    ensure    => 'present',
  }

  group {'vagrant':
    ensure => 'present',
    gid    => 700,
  }

  user {'vagrant':
    ensure     => 'present',
    home       => '/home/vagrant',
    shell      => '/bin/bash',
    managehome => true,
    groups     => 'admin',
    uid        => '700',
    gid        => '700',
    password   => '$1$6KlqfOLV$QHzqKMeh1d/uh51s3Ewco0',
    require    => [Group['vagrant'],Group['admin']],
  }

  user {'root':
    password   => '$1$6KlqfOLV$QHzqKMeh1d/uh51s3Ewco0',
  }

  ssh_authorized_key {'vagrant_sshkey':
    ensure    => 'present',
    type      => 'ssh-rsa',
    key       => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==',
    user      => 'vagrant',
    require => User['vagrant'],
  }
}