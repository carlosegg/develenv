# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
   . "$HOME/.bashrc"
    fi
fi
[ "$(who -u |grep ^vagrant)" != "" ] && cat .motd
. ./.git-prompt.sh
. ./.git-completion.bash
[[ -f ~/bin/setEnv.sh ]] && source ~/bin/setEnv.sh

check_error_command(){
     if [ $1 != 0 ]; then
       printf -- "ERROR($1) "
     else
       printf -- ""
     fi
}

if [ "$distribution" == "Debian" ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(__git_ps1 " (%s)")\[\033[00m\]\$ '
else
#sets up the prompt color (currently a green similar to linux terminal)
   PS1='\[\033[01;${debian_chroot:+($debian_chroot)}\[\033[01;32m\]$(check_error_command $?)\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)")\[\033[00m\]\$ '
fi

