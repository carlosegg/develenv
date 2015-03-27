#!/bin/bash
function currentDir(){
   DIR=`readlink -f $0`
   DIR=`dirname $DIR`
}

rpmType(){
   packageType=i686
   if ! [ -z `echo $rpmFile|grep ".noarch.rpm$"` ]; then
      packageType="noarch"
   else
      if ! [ -z `echo $rpmFile|grep ".x86_64.rpm$"` ]; then
         packageType="x86_64"
      else
         if ! [ -z `echo $rpmFile|grep ".src.rpm$"` ]; then
         packageType="src"
         fi
      fi
   fi
}

currentDir
pushd . >/dev/null
cd $DIR
. ./setEnv.sh
popd >/dev/null


if [ $# != 1 ]; then
   echo "Uso: $0 <rpmFile>"
   exit 1
fi
rpmFile=$1
rpmType
cp $rpmFile $PROJECT_HOME/app/repositories/rpms/$packageType
createrepo -s sha -d --update $PROJECT_HOME/app/repositories/rpms/$packageType
echo "Publicado $rpmFile en http://`hostname`/$PROJECT_NAME/rpms/$packageType"
