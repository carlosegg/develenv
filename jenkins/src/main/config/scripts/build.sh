#!/bin/bash
. $HUDSON_HOME/../../bin/setEnv.sh
DIR=$PWD
cd ..
vArtifactId=`basename $PWD`
vGroupId=`hostname`
vSubversionUrl=`cat $PWD/config.xml|grep "<remote>"|cut -f2 -d">"|cut -f1 -d'<'`
vDescription=`cat $PWD/config.xml|grep description|cut -f2 -d">"|cut -f1 -d'<'`

vVersion="1.0.0-SNAPSHOT"
vName="`hostname` - $vArtifactId"
vReportOutputDirectory=$PWD
TOKEN=$vSubversionUrl
i=2
while [ "$TOKEN" != "" ] ; do
    OLD_TOKEN=$TOKEN
   (( i ++ ))
   TOKEN=`echo $vSubversionUrl|cut -f$i -d'/'`
done
cp $PROJECT_HOME/app/hudson/scripts/pom.* $DIR/$OLD_TOKEN
cp $PROJECT_HOME/app/hudson/scripts/sintetic_pom.xml $DIR/$OLD_TOKEN
cd $DIR/$OLD_TOKEN
./pom.sh
cd $DIR
