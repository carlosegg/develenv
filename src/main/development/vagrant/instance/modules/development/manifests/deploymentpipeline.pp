class development::deploymentpipeline {
  
  $develenv_pipeline_dir = [ "/home/develenv/app",                     
                             "/home/develenv/app/plugins",
                   ]

  file { $develenv_pipeline_dir:
    owner   => develenv,
    group   => develenv,
    mode    => 755,
    ensure  => directory,
    notify  => Exec['install_deployment_pipeline'],
  }

  exec { 'install_deployment_pipeline':
    user     => develenv,
    cwd      => "/home/develenv/app/plugins",
    command  => "/usr/bin/svn co http://develenv-pipeline-plugin.googlecode.com/svn/trunk/pipeline_plugin/plugin/app/plugins/pipeline_plugin/",
    refreshonly => true,
  }
}