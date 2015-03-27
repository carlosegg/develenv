#!/bin/bash
PACKAGES="ant maven maven2 jmeter tomcat jenkins sonar nexus soapui sonar-runner"
EXTERNALS="jenkins/src/main/config/plugins sonar/src/main/rpm/SOURCES/plugins\
           sonar/src/main/rpm/SOURCES/rules"
FILE=pom.xml

function getVersion(){
   if [ "$2" == "pack" ]; then
      cat $FILE | grep \<$1.version\> | cut -d\> -f2 | cut -d\< -f1
   else
      LANG=C svn info $1 | grep "Last Changed Rev" | cut -d: -f2
   fi
}

function replace(){
  local VER=$1
  local SPECFILE=$2
  if [ -z "$VER" -o -z "$SPECFILE" ]; then
     _log "[ERROR] Version [$VER]  or specfile [$SPECFILE] empty"
     exit 1
   else
     _log "[INFO] Parsing $SPECFILE and putting Version: $VER"
     sed -i s/"\(^Version\:\).*"/"Version:    $VER"/g $SPECFILE
  fi

}

# Doing for a platform packages

DIR=$(dirname $(python -c 'import os,sys;print os.path.realpath(sys.argv[1])' $0))
source $DIR/setEnv.sh
cd $DIR/../../../
for pack in $PACKAGES;
 do
   VER=$(getVersion $pack pack)
   SPECFILE=$(find . -name $pack.spec)
   replace $VER $SPECFILE
done

# Doing for external URLs
for ext in $EXTERNALS;
   do
     VER=$(getVersion $ext)
     SPECFILE_TMP=$(echo $ext| sed 's/\([a-z]*\).*\/\([a-z]*\)$/\1-\2.spec /' )
     SPECFILE=$(find . -name $SPECFILE_TMP)
     replace $VER $SPECFILE
done
_log "[INFO] Updated versiones correctly"
