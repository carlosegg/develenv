#!/bin/bash
function currentDir(){
   DIR=$(dirname `python -c 'import os,sys;print os.path.realpath(sys.argv[1])' $0`)
}
currentDir
. $DIR/setEnv.sh
pushd . >/dev/null

if [ -d  "$DIR/../../../target/site/assemblies/" ]; then
   cd $DIR/../../../target/site/assemblies/
   develenv_file=`ls develenv*.sh`
   if [ "$develenv_file" != "" ]; then
   isoFile=`echo $develenv_file |sed s:"\.sh":"":g`.iso
   dd if=$develenv_file of=$isoFile
        mkdir -p iso
        mv $develenv_file iso
        mkisofs -r -J -o $isoFile iso
   mv iso/* .
        rm -Rf iso
   popd >/dev/null
   exit 0
   fi
fi
_log "[ERROR] Ejecuta $DIR/build.sh  para crear la distribución"
popd >/dev/null


