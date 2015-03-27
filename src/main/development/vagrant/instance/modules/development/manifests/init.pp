class development {
  include development::vagrant
  include development::packages
  include development::users
  include development::homedir
  include development::develenv
  include development::deploymentpipeline
  Class ['users'] -> Class [ 'develenv'] -> Class ['deploymentpipeline']
}