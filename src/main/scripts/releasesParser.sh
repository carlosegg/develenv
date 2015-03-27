#!/bin/bash
PACKAGES="ant maven maven2 jmeter tomcat jenkins sonar \
          sonar-plugins sonar-rules nexus soapui selenium \
          selenium-drivers jenkins-plugins jenkins-examples"

function getChange(){
  echo "Getting changes on $1"
  local SPECFILE=$1
  svn st $SPECFILE | grep ^M
  return $?
}

function incRel(){
  local SPECFILE=$1
  local REL=$(cat $SPECFILE | grep ^Release | cut -d: -f2)
  REL=$(($REL + 1))
  _log "[INFO] Incrementing Release to $REL in $SPECFILE"
  sed -i .bk s:"\(^Release\:\).*":"\1    $REL":g $SPECFILE
}

# Doing for a platform packages
DIR=$(dirname $(python -c 'import os,sys;print os.path.realpath(sys.argv[1])' $0))
source $DIR/setEnv.sh
cd $DIR/../../../
for pack in $PACKAGES;
 do
   SPECFILE=$(find . -name $pack.spec)
   getChange $SPECFILE
   [ "$?" == "0" ] &&  incRel $SPECFILE ||\
     _log "[INFO] There's no changes on $SPECFILE, nothing to do with it."
done
