#!/bin/bash -x
# DOCs: http://franmr.com/post/68326582664/running-jenkins-jobs-every-time-you-do-a-pull-request

GITHUB_API=https://pdihub.hi.inet/api/v3/repos
TOKEN=923e2a765846fb680ed907fe0eddc13995bc4186

function get_id_jenkins_hooks(){
   organization=$1
   repo=$2
   id_hooks=$(curl -v -k -H "Authorization: token $TOKEN" $GITHUB_API/$organization/$repo/hooks|grep "\"id\""|sed s#".*:"#""#g|sed s:",":"":g|awk '{print $1}')
   echo $id_hooks
}

function get_jenkins_hook_id(){
   organization=$1
   repo=$2
   hook_id=$3
   curl -v -k -H "Authorization: token $TOKEN" $GITHUB_API/$organization/$repo/hooks/$3 >borrame.json
   
   sed -i s:"/hudson/":".hi.inet/hudson/":g borrame.json
   sed -i s:"\.hi\.inet\.hi\.inet":".hi.inet":g borrame.json
   cat borrame.json
}

function update_pr_hook(){
   organization=$1
   repo=$2
   hook_id=$3
   curl -v -k -H "Authorization: token $TOKEN" $GITHUB_API/$organization/$repo/hooks/$3 -d @borrame.json
}
id_hooks=$(get_id_jenkins_hooks $*)
for id_hook in $id_hooks; do
   rm -Rf borrame.json
   get_jenkins_hook_id $* $id_hook
   update_pr_hook $* $id_hook
done;
echo "Warning: This scripts only works with happy paths!"
