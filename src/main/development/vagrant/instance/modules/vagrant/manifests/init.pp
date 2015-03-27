class vagrant {
  include vagrant::users
  include vagrant::packages
  include vagrant::sudoers
  include vagrant::directory
}
